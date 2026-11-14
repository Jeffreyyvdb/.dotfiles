# Global instructions

Shared across Jeffrey's machines: this file is tracked in the dotfiles repo and stowed to `~/.claude/CLAUDE.md`. Facts that hold for one machine only (paths, hosts, local services) live in `~/.claude/rules/machine.md`, which is not tracked.

Jeffrey keeps a personal knowledge-base wiki in the GitHub repo `Jeffreyyvdb/wiki-agent` (an Obsidian vault; its `CLAUDE.md` is the schema). Sessions read it before they work and feed it afterwards.

## Read the wiki before working

Before non-trivial work in one of Jeffrey's own repos or on his infrastructure, read what the wiki already knows about it. Decisions, gotchas and the current state are recorded there and are not in the code.

1. Find the wiki. `~/.claude/rules/machine.md` names the local working copy when there is one. Read from `origin/main` so a stale or dirty working copy doesn't matter: `git -C <copy> fetch -q origin`, then `git -C <copy> show origin/main:<path>`. With no local copy, use `gh api repos/Jeffreyyvdb/wiki-agent/contents/<path> -H "Accept: application/vnd.github.raw"`.
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

Start **one** subagent with the Agent tool, in the background (`subagent_type: "general-purpose"`). It starts cold, so its prompt must carry everything it needs:

1. **The facts**, written out as a self-contained list: project or repo names, paths, URLs, dates (absolute, `YYYY-MM-DD`), commands, decisions with their reasons, numbers, and open actions with deadlines. Say which earlier statement a fact replaces when you know one (for example "PR 12 is now merged; it was open this morning"). Leave out secrets, tokens, passwords and keys, even when they appeared in the session.
2. **These instructions**, copied into the prompt:

> Update the wiki in `Jeffreyyvdb/wiki-agent` with the facts above. You have full authority to commit and push to `main` yourself. No PR and no review are needed.
>
> 1. Work in your own clone so you never collide with other sessions: `D=$(mktemp -d) && gh repo clone Jeffreyyvdb/wiki-agent "$D/wiki"`. Do not touch any other working copy of the wiki on this machine.
> 2. Read the wiki's `CLAUDE.md` (the schema; it wins where it covers something). Read the existing pages for every project, tool or concept the facts touch, and today's session-log page if it exists. Search `index.md` for the names you need rather than reading it whole.
> 3. Follow the schema's Ingest steps 4–7, without the "discuss with the user" step. Put each fact on the hub or entity page it belongs to, updating in place rather than creating duplicates, and replace statements the facts make untrue. Then record the session in the day's session-log source page (`wiki/sources/sessions-YYYY-MM-DD.md`, the schema's session-log variant). If that page already has a section on the same topic, update that section in place, so the page never says two different things about one subject; otherwise append a section. Keep a section to what was learned, not a list of what was done. Create a new page only when the schema's "Heuristics for what deserves a page" say so. Keep hub discipline: Active work has at most 6 bullets with no dates or PR numbers, and every decision ends with a source link. Bump `updated:` on every page you touch. Register new pages in `index.md` in one line each and append one `ingest` entry to `log.md`.
> 4. If the facts add nothing the wiki doesn't already say, change nothing and report "no wiki change".
> 5. Check every `[[link]]` on the pages you touched: it must resolve by filename or `aliases:`, case-insensitively, with no space/dash swap. `[[index]]` is valid.
> 6. Commit as `ingest: session YYYY-MM-DD <short topic>` and end the message with `Co-Authored-By: Claude <noreply@anthropic.com>`. Then `git pull --rebase origin main` and `git push origin main`. If the push is rejected because another session pushed first, pull with rebase and push again, up to 3 times. Resolve `log.md` conflicts by keeping both entries in date order.
> 7. Delete the temporary clone. Reply in at most 3 lines: the pages created and updated, and the commit hash, or why nothing was pushed.

### Afterwards

Do not wait for the subagent before your final reply. End the reply with one line saying a wiki update is running in the background. If its result arrives while the session is still open, pass it on in one line (pages and commit, or the error). Never claim the wiki was updated before the subagent has reported it.
