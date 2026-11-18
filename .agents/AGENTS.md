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

## Codex through ChatGPT sharing in T3 Code

In T3 Code sessions using Codex through ChatGPT sharing, do not use native Codex subagents (`spawn_agent` or its follow-up tools). Multiple sessions have failed with "Codex used a feature that ChatGPT sharing does not support" immediately after a native subagent attempt. Treat native delegation as unsupported on this connection until support is verified. If the connection type is unknown in a T3 Codex session, work without native subagents.

This restriction overrides pstack's native delegation and fan-out instructions. T3's app-owned `delegate_task` is a separate route. When Jeffrey or an applicable skill requests delegation, announce that route before using it. First call `orchestrator_capabilities` and check that `features.appOwnedSubagents` and the inherited provider's `canRunChildTask` are true, with no constraint blocking the task. Keep the inherited provider, model, and settings unless Jeffrey explicitly requests a change. Do not substitute another provider or agent CLI.

Advertised capabilities establish that T3 offers the route, not that a child has run successfully or native support is restored. Do not launch native subagents to test support. If T3 delegation is unavailable or fails, continue independent work sequentially and report the limitation. Never count self-review, tests, or CI as an independent verdict, or claim that a required independent-review gate passed without the required reviews.

After this provider error, an ordinary retry may retain the failing context. Recover the same thread with T3's `freshContext: true`, carrying forward the user's task, constraints, worktree, and verified progress in a concise handoff. Inspect the working tree before resuming. Do not repeat the unsupported call. Do not change provider or model unless the user asks.

## pstack model sheets

pstack skills take per-role models from a sheet per CLI, each naming only that CLI's own models. Read only your CLI's sheet and ignore the others:

- Claude Code: `~/.claude/pstack-models.md`, imported by the line below.
- Codex: `~/.codex/pstack-models.md`. Codex has no import, so read it before a pstack skill that dispatches subagents.
- Copilot CLI: `~/.copilot/pstack-models.md`, injected by the pstack plugin's hook. Build it with `setup-pstack` inside Copilot; it is machine-specific and not tracked.

@~/.claude/pstack-models.md

## Heavy jobs go through `heavy`

Several agent sessions share one machine. Run one-shot memory-heavy commands (type checks such as `svelte-check`, linters over a whole repo, production builds, test suites, Playwright runs) through `~/.agents/bin/heavy`, e.g. `~/.agents/bin/heavy bun run check`. It waits for a machine-wide slot and enough free memory, so parallel sessions cannot all start one at once. It can wait minutes: give the call a long timeout or run it in the background. Never wrap anything that keeps running (dev servers, `vite dev`, a perf stack), since it would hold the slot until stopped, and run each heavy command on its own rather than several in parallel. `heavy --status` shows who holds the slots. Where the script is missing, run the command directly.
