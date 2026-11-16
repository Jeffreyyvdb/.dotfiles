# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal dotfiles repo managed with **GNU Stow**. Stow symlinks everything from `~/.dotfiles` into `~` — editing a file here immediately affects the live config. There is no build step.

## This repo is public

`github.com/Jeffreyyvdb/.dotfiles` is a **public** GitHub repo. Everything committed — including
history, deleted files and commit metadata — is readable by anyone. Before staging anything, check
that it contains none of:

- Credentials of any kind: API keys, tokens, passwords, OAuth/auth files, SSH or GPG keys, `.env` files
- Employer or client details: work email, company names, internal hostnames, repo or project names
- Private infrastructure: server IPs, internal domains, SSH host aliases, VPN or network layout
- Personal data: private email addresses, phone numbers, home paths that reveal other usernames
- Agent/CLI runtime state: session logs, memories, caches, sqlite dbs (see the `.codex` notes below)

Machine-specific or sensitive values belong in `~/.zshrc.local` / `~/.bashrc.local` or another
stow-ignored, git-ignored file — never in a tracked file. Commits must use the GitHub noreply
address (set in `.config/git/config`), not a personal or work email. If something sensitive has
already been committed, say so rather than quietly deleting it: removing it from the tree does not
remove it from history.

## Applying changes

```bash
# After adding new files/dirs that need symlinking (wraps `stow --restow -v .`)
dotfiles stow

# Reload shell config without restarting
source ~/.bashrc        # Linux
source ~/.zshrc         # macOS

# After editing mise tools list
mise install
```

## Stow rules

- `dotfiles stow` (`.config/shell/fns/dotfiles`) runs `stow --restow -v .` from `~/.dotfiles`, which creates symlinks in `~` mirroring the directory structure here. Use it rather than a plain `stow .`: on Linux it first creates `~/.config/systemd/user`, `~/.config/user-tmpfiles.d` and every `*.d` drop-in directory under `.config/systemd/user` as real directories, so stow never folds them into one symlink into this repo (where `systemctl --user enable` would then write; and systemd ignores a drop-in directory that is a relative symlink, so a folded drop-in silently does nothing), and on macOS it skips that Linux-only config. The auto-sync re-stows through the same function.
- Files listed in `.stow-local-ignore` are **never** symlinked: `.git`, `.gitignore`, `README.md`, the root `CLAUDE.md` and `AGENTS.md`, `.claude/settings.local.json` (Claude Code's per-project permissions for sessions run inside this repo), `.gitconfig`, `.bashrc.local`, `.zshrc.local`, `.agents/.skill-lock.json`, `.agents/AGENTS.local.md`, and two machine-specific theme files.
- An ignore entry without a `/` matches that **basename at any depth**. `CLAUDE.md` and `AGENTS.md` are therefore anchored (`^/CLAUDE\.md`), so this repo's own instructions stay out of `~` while `.claude/CLAUDE.md` is still linked.
- To stop tracking a file: add it to `.stow-local-ignore`, then run `stow -D . && dotfiles stow` to re-apply.

## Architecture

### Shell config loading order

Both `.bashrc` (Linux) and `.zshrc` (macOS) follow the same pattern:

1. Source `~/.bashrc.local` / `~/.zshrc.local` — machine-specific, git-ignored, not stowed
2. Source `~/.config/shell/rc` — shared entry point that loads `envs`, `aliases`, `functions`
3. Init starship, zoxide, mise

The shared config lives entirely in `.config/shell/`:
- `envs` — exports (`EDITOR=nvim`, `BAT_THEME=ansi`)
- `aliases` — all command aliases; guards with `command -v` before aliasing eza/zoxide so the shell degrades gracefully if a tool is missing
- `functions` — sources every file under `fns/`
- `fns/` — one file per concern: `compression`, `ssh-port-forwarding`, `tmux`, `transcoding`

### Machine-specific config

`.bashrc.local` / `.zshrc.local` are the correct place for anything that shouldn't be in the repo (Homebrew path, nvm, mise activation on Ubuntu, Omarchy defaults). They are sourced *before* the shared config so shared settings take precedence.

### mise-managed tools

`.config/mise/config.toml` declares the tool versions. `mise install` installs them. Tools: `bun` (latest), `dotnet` (latest), `node` (lts), `pnpm` (latest), `python` (latest), `tmux` (latest), and the npm CLIs `defuddle` (web page → clean Markdown), `knap` (Markdown templates from JSON/CSV) and `obsidian-headless` (`ob`: Obsidian Sync/Publish without the desktop app), used by the Obsidian agent skills. `experimental = true` is on for any future GitHub plugins.

### Minimum release age (supply-chain cooldown)

Package managers refuse releases younger than 24h, so a compromised publish has time to be caught
before it lands here. Tracked: mise (`minimum_release_age` in `.config/mise/config.toml`), uv
(`exclude-newer` in `.config/uv/uv.toml`), bun (`minimumReleaseAge` in `.bunfig.toml`, seconds).
Not tracked because their files can hold registry tokens: npm (`min-release-age=1` in `~/.npmrc`,
days) and pnpm (`minimumReleaseAge: 1440` in `~/.config/pnpm/config.yaml`, minutes) — on a new
machine run `npm config set min-release-age 1` and `pnpm config set -g minimumReleaseAge 1440`.
Homebrew has no equivalent; hold fresh formulae back with `brew pin`.

### Neovim

`.config/nvim/` is a LazyVim-based setup. Plugin specs live in `lua/plugins/`. Notable plugins:
- `easy-dotnet.lua` — .NET/C# dev (requires `dotnet tool install -g EasyDotnet`)
- `omarchy-theme-hotreload.lua` — live theme switching (used with Omarchy Linux)
- `all-themes.lua` — theme collection
- `theme.lua` — machine-specific active theme (stow-ignored, not tracked)

`lazy-lock.json` pins plugin versions — commit changes to it when intentionally upgrading plugins.

### btop

`.config/btop/btop.conf` is hand-edited and `save_config_on_exit = false` **on purpose**. Do not flip
it back. `~/.config/btop` is a stow symlink into this repo, so with saving on, btop rewrote the tracked
file on every exit using the schema for whatever hardware it was running on — the config ping-ponged
between machines (the Mac adding GPU keys, a no-GPU Linux box stripping them and adding the Linux-only
`freq_mode`, `shown_gpus` differing by platform). If a btop.conf diff shows up unasked, it is that churn
returning, not a real change — revert it rather than committing it.

### Agent CLI dirs (.claude, .codex, .agents)

Skills live once in `.agents/skills/` and are surfaced to each agent CLI by symlink, so only
`.agents/` holds real files. `.claude/skills/*` and `.codex/skills/*` are tracked symlinks pointing
at `../../.agents/skills/<name>`.

The two CLIs fold at different depths **on purpose**:

- `~/.claude` is a real dir; `~/.claude/skills` is a stow symlink onto this repo's `.claude/skills`.
  The only runtime state Claude Code writes into `skills/` is `skills/synced/` — a cache of the
  account's synced skills (~10MB, rewritten on every sync) — which is gitignored, so the repo can
  still own the rest of that directory. If `.claude/skills/synced/` shows up as untracked, the ignore
  rule has gone missing; do not commit it.
- `~/.codex` and `~/.codex/skills` are both **real dirs**, with only the leaves (`nvim`, `ralph`)
  symlinked in. Codex regenerates `skills/.system/` on startup, so a folded
  `skills` dir would drag those back into the repo. Each Codex skill symlink needs its own
  `!.codex/skills/<name>` line in `.gitignore`, or it stays untracked.

`.agents/.skill-lock.json` is the skills CLI's record of what it installed on a machine. It is
tracked as the Mac's copy (where `~/.agents` is a folded symlink, so it lands here anyway) but
stow-ignored, because a machine with a real `~/.agents` has its own lock listing skills this repo
does not carry.

### Global agent instructions (.agents/AGENTS.md)

`.agents/AGENTS.md` is the one global instruction file for every agent CLI, on every machine. It is
not this file: this root `CLAUDE.md` only describes the dotfiles repo. Tracked symlinks point each
CLI's global location at it:

| CLI | Reads | Repo symlink |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `.claude/CLAUDE.md` → `../.agents/AGENTS.md` |
| Codex | `~/.codex/AGENTS.md` | `.codex/AGENTS.md` → `../.agents/AGENTS.md` (whitelisted in `.gitignore`) |
| opencode | `~/.config/opencode/AGENTS.md` | `.config/opencode/AGENTS.md` → `../../.agents/AGENTS.md` |
| Copilot CLI | `~/.copilot/copilot-instructions.md` | `.copilot/copilot-instructions.md` → `../.agents/AGENTS.md` (whitelisted in `.gitignore`) |

Keep the global file machine-neutral and safe for a public repo. Anything that holds for one
machine only (paths, hostnames, local services, employer-specific rules) goes in
`~/.agents/AGENTS.local.md` on that machine. It is gitignored and stow-ignored, so it cannot be
committed or linked by accident (on a machine where `~/.agents` is folded into this repo, it sits
in the working tree but stays untracked). How each CLI gets it:

- **Claude Code** expands the `@~/.agents/AGENTS.local.md` import line; a missing file is skipped.
- **opencode** does not expand `@` imports; `.config/opencode/opencode.json` lists the file under
  `instructions`.
- **Copilot CLI** has no global `AGENTS.md` and no imports, and it ignores symlinks in
  `~/.copilot/instructions/`. It does load `*.instructions.md` from `<dir>/.github/instructions/`
  for each dir in `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` (set to `~/.agents` in `.config/shell/envs`),
  and there it follows symlinks. Each machine with a local file runs once:
  `mkdir -p ~/.agents/.github/instructions && ln -s ../../AGENTS.local.md ~/.agents/.github/instructions/local.instructions.md`.
  The env var only reaches a Copilot started from the shell.
- **Codex** has no import or append mechanism (`AGENTS.override.md` replaces, not appends), so the
  global file tells the agent to read the local file itself. That is a soft guarantee only.

Verified 2026-11-16 on macOS (Claude Code, Copilot CLI 1.0.110) with tools disabled: both CLIs
answered from the global and the local file. Codex and opencode are not tested.

The global file's end-of-session wiki update goes through `.agents/bin/wiki-ingest` (reached as
`~/.agents/bin/wiki-ingest`), not an in-session subagent. The agent pipes its facts in; the script
saves them, then starts a detached headless `claude -p` (`setsid`, or perl's `POSIX::setsid` on
macOS) in a fresh temp clone of the wiki, with the parent session's `CLAUDE*`/`T3*` env vars
stripped, and returns at once. A failed run leaves `<id>.failed`, which the next call reports. The reason is that a
background subagent's report re-entered the session after the final reply, cluttering it and
breaking T3 Code's suggested next prompt. The wiki prompt lives in the script; logs go to
`~/.local/state/wiki-ingest/` and are pruned after 30 days. Any CLI with a shell can call it.

`~/.copilot` must be a real directory before stowing, like `~/.codex`, or stow folds it into this
repo and Copilot writes its session state here: `mkdir -p ~/.copilot` on a fresh machine.

On a machine that already has its own real `~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md`, stow
refuses to link over it. Move the content into `~/.agents/AGENTS.local.md` and delete the
original before stowing. Never use `stow --adopt` for these: that would copy the machine's file,
possibly with employer details, into this public repo.

pstack is vendored as Michael Denyer's multi-harness port, `github.com/michael-denyer/pstack-claude`
(tag `v0.9.138`, commit `2044f18`), in `vendor/pstack-claude/`: the two marketplace manifests,
`plugins/pstack/` and the license and notice files. It ports Lauren Tan's Cursor pstack with a native
plugin per CLI, so one copy serves every agent here. `vendor/` is stow-ignored: each CLI installs the
plugin from `~/.dotfiles/vendor/pstack-claude` rather than reading a link in `~`. It replaced the
tstack skills (`github.com/t3dotgg/tstack`) and the `opus-review` add-on on 2026-11-16; pstack's
playbooks cover their babysit, ship, takeover and review work.

Claude Code and Codex copy the plugin into their own cache, so each machine installs it once and
re-runs the update after a pull that changes `vendor/`:

```bash
claude plugin marketplace add ~/.dotfiles/vendor/pstack-claude
claude plugin install pstack@pstack-claude        # later: claude plugin update pstack@pstack-claude
codex plugin marketplace add ~/.dotfiles/vendor/pstack-claude
codex plugin add pstack@pstack-claude             # then trust its hook once with /hooks in codex
copilot plugin marketplace add ~/.dotfiles/vendor/pstack-claude   # local path untested
copilot plugin install pstack@pstack-claude
```

opencode reads the plugin straight from the repo through `plugins` in `.config/opencode/opencode.json`.
That path is written `{env:HOME}/...` because opencode does not expand `~` in `plugins` (it does in
`instructions`), so a pull updates opencode with no extra step.

To update pstack, copy the same paths from a newer tag of pstack-claude over `vendor/pstack-claude/`
(`git archive <tag> .claude-plugin .agents/plugins plugins/pstack LICENSE LICENSE-cursor-team-kit
LICENSE-thermos NOTICE.md NOTICE-skills.md README.md VERSION`), review the diff, and update the tag
above. Every plugin ships a session-start hook that routes multi-file, design and unknown-cause bug
work into `poteto-mode`; `setup-pstack` (`/pstack:setup-pstack` in Claude Code) turns it off with
`session hook: off` and sets the model per role.

Those choices live in one model sheet per CLI, each naming only that CLI's own models.
`.claude/pstack-models.md` (Claude models) and `.codex/pstack-models.md` (Codex models, whitelisted in
`.gitignore`) are tracked and stowed into `~/.claude` and `~/.codex`, so every machine shares them. The
Copilot sheet stays untracked in `~/.copilot`: Copilot's `setup-pstack` builds it from the models that
account can reach, and the user picks each one. The shared `.agents/AGENTS.md` wires them in:
Claude Code through an `@~/.claude/pstack-models.md` import, Codex through an instruction to read its
sheet, and Copilot through the plugin hook. pstack's own Codex step, pasting the rows into
`~/.codex/AGENTS.md`, would put them in the shared file, where Claude would see GPT rows. Panels stay
single-vendor per CLI on purpose: mixing Claude and GPT through T3 Code's `delegate_task` only works
inside T3 and is outside pstack's contract. Because `.claude/pstack-models.md` sits at this repo's root, the hook
also treats it as this repo's project sheet, which is harmless because it is the same file.

`~/.codex` must never become a single symlink into this repo. It was one until 2026-09-12, which meant
Codex wrote its whole state — live OAuth tokens in `auth.json`, `memories/logs/state` sqlite dbs
carrying session content from every repo, and ~135MB of `.tmp`/`plugins`/`cache` — straight into the
working tree of a public repo. Nothing sensitive ever got committed; the state now lives in a real
`~/.codex` and `.gitignore` whitelists only the skill symlinks.

Stow folds a directory into one symlink when the target does not exist, so on a **fresh machine create
the dirs before stowing** or the whole problem comes back:

```bash
mkdir -p ~/.codex/skills ~/.claude ~/.copilot
source ~/.dotfiles/.config/shell/fns/dotfiles && dotfiles stow
```

Do not add `.codex` to `.stow-local-ignore` — that would stop the skill symlinks being linked at all.

## Ubuntu-specific notes

`fd` and `bat` are packaged as `fd-find`/`fdfind` and `batcat` on Ubuntu. Symlinks are needed:

```bash
ln -sf $(which fdfind) ~/.local/bin/fd
ln -sf $(which batcat) ~/.local/bin/bat
```

`~/.bashrc.local` on Ubuntu should export `PATH="$HOME/.local/bin:$PATH"` and run `eval "$($HOME/.local/bin/mise activate bash)"` — mise is not in the system PATH otherwise.

`btop` in the Ubuntu apt repos is outdated (stuck at 1.3.0). Install the latest release binary from GitHub instead:

```bash
curl -fsSL https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-unknown-linux-musl.tar.gz \
  | tar -xz -C /tmp && cp /tmp/btop/bin/btop ~/.local/bin/btop && chmod +x ~/.local/bin/btop
```

The binary is statically linked (musl) and works on kernel 2.6.39+. No GPU support in the binary — acceptable since this machine has no NVIDIA/AMD GPU.
