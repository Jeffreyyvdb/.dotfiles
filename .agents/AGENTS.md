# Global instructions

Shared across Jeffrey's machines and agent CLIs: this file is tracked in the dotfiles repo as `.agents/AGENTS.md` and reaches Claude Code as `~/.claude/CLAUDE.md`, Codex as `~/.codex/AGENTS.md`, opencode as `~/.config/opencode/AGENTS.md` and GitHub Copilot CLI as `~/.copilot/copilot-instructions.md`. Instructions for one machine only (paths, hosts, local services, employer-specific rules) live in `~/.agents/AGENTS.local.md`, which is not tracked. Where the two disagree, the local file wins.

@~/.agents/AGENTS.local.md

If your tool did not load that file already (Claude Code expands the line above, opencode loads it through its `instructions` setting, Copilot CLI through `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`, Codex does none of these), read `~/.agents/AGENTS.local.md` before you start work and follow it. If it does not exist, this machine has no local rules.

Some sections below name Claude Code tools (`Agent`, skills). In another CLI, use its equivalent or skip that step.

## Personal versus work

The wiki sections below apply only to Jeffrey's personal repos and infrastructure. A repo the local file marks as work, or any repo owned by an employer or client, is not "his own": never read the personal wiki for it and never write anything learned in it to the personal wiki.

Public repos, their commits and their PRs never mention work: no employer, client, work machine or work tooling. Put machine-specific facts in `~/.agents/AGENTS.local.md` instead and keep the public wording generic.

Jeffrey keeps a personal knowledge-base wiki in the GitHub repo `Jeffreyyvdb/wiki-agent` (an Obsidian vault; its `CLAUDE.md` is the schema). Sessions read it before they work and feed it afterwards.

## Read the wiki before working

Before non-trivial work in one of Jeffrey's own repos or on his infrastructure, read what the wiki already knows about it. Decisions, gotchas and the current state are recorded there and are not in the code.

1. Find the wiki. `~/.agents/AGENTS.local.md` names the local working copy when there is one. Read from `origin/main` so a stale or dirty working copy doesn't matter: `git -C <copy> fetch -q origin`, then `git -C <copy> show origin/main:<path>`. With no local copy, use `gh api repos/Jeffreyyvdb/wiki-agent/contents/<path> -H "Accept: application/vnd.github.raw"`.
2. Find the page. Project hubs are in `wiki/concepts/`, tools and services in `wiki/entities/`, both with kebab-case filenames. List the folder (`git -C <copy> ls-tree --name-only origin/main wiki/concepts/`) and pick the page named after the project. If none matches, `git -C <copy> grep -il <repo-name> origin/main -- wiki/`. Do not read `index.md` or `log.md` whole; they are large.
3. Read the hub, and follow a link only when the task needs that detail.

Skip this for quick questions, for work in `wiki-agent` itself, and for headless `claude -p` runs started by a script or timer. If the wiki has no page for the project, carry on without one.

## Keep the wiki current

### When

When a task is done, before your final reply, check whether the session produced **durable knowledge**: something a future session would do worse without, and could not get from the code or the git history. That is:

- a decision and its reason, or a preference or constraint Jeffrey stated
- a gotcha or the root cause of an incident
- an infrastructure or environment fact that changed: services, hosts, timers, domains, tools installed or removed
- a new project or repo, or a change to a project's shape: its architecture, how it deploys, what it is for
- a finding with its evidence: an analysis, an eval, measured numbers
- an open action with a deadline

Routine work is not durable knowledge, so do not write the wiki for it: merged PRs and shipped features, dependency bumps and Dependabot triage, UI tweaks, release tags, CI reruns. The wiki's weekly sweep reads merged PRs from GitHub and records them in its digest. If such a session also produced one of the items above, record that item only.

Also skip the update when:

- the session was a quick question, chit-chat, or produced nothing durable
- the session *was* wiki work in `wiki-agent` itself (it already wrote the wiki)
- you already ran a wiki update in this session and nothing new came up since
- this is a headless `claude -p` run started by a script or timer
- Jeffrey said not to, or a usage budget he stated is close to running out

### How

Hand the facts to `~/.agents/bin/wiki-ingest`. It starts a separate, headless Claude run that updates the wiki and pushes to `main`, then returns at once. Nothing from that run comes back into this session, so the session stays about its own work. Do **not** use a subagent or a background task for this: their reports re-enter the session after your final reply and clutter it.

Write the facts as a self-contained list, because the run starts cold: project or repo names, paths, URLs, dates (absolute, `YYYY-MM-DD`), commands, decisions with their reasons, numbers, and open actions with deadlines. Say which earlier statement a fact replaces when you know one (for example "PR 12 is now merged; it was open this morning"). Leave out secrets, tokens, passwords and keys, even when they appeared in the session.

Pipe them in with one ordinary foreground shell call (not a background one), passing a short topic:

```bash
~/.agents/bin/wiki-ingest "<short topic>" <<'EOF'
- fact one
- fact two
EOF
```

The wiki instructions the run follows live in the script. Its log, ending in a short report (pages and commit, or "no wiki change"), is written to `~/.local/state/wiki-ingest/`.

### Afterwards

Do not wait for the run or check its log. End your final reply with one line saying a wiki update was started in the background. If the script itself failed (for example `claude` or `gh` is missing), say that in that line instead. If it printed that earlier runs failed, add their log paths to that line so Jeffrey can replay them. Never claim the wiki was updated.

## Reviews use Sol, Opus only as a fallback

GPT Sol is reachable through GitHub Copilot or Codex; `~/.agents/AGENTS.local.md` may say which route a machine has. When `sol-loop`, `full-send`, `full-stop` or `council` runs, follow those skills as written and review with Sol. In T3, find it with `orchestrator_capabilities` (the Copilot or Codex provider); in Copilot CLI or Codex, use a native subagent on the latest Sol model.

Only when you have tried every route and none runs Sol, load the `opus-review` skill. It replaces Sol with Claude Opus and overrides sol-loop's "do not substitute a model" rule. Say in your reply that Opus stood in and why.
