# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal dotfiles repo managed with **GNU Stow**. Stow symlinks everything from `~/.dotfiles` into `~` — editing a file here immediately affects the live config. There is no build step.

## Applying changes

```bash
# After adding new files/dirs that need symlinking
cd ~/.dotfiles && stow -v .

# Reload shell config without restarting
source ~/.bashrc        # Linux
source ~/.zshrc         # macOS

# After editing mise tools list
mise install
```

## Stow rules

- `stow -v .` run from `~/.dotfiles` creates symlinks in `~`, mirroring the directory structure here.
- Files listed in `.stow-local-ignore` are **never** symlinked: `.git`, `.gitignore`, `README.md`, `CLAUDE.md`, `.gitconfig`, `.bashrc.local`, `.zshrc.local`, and two machine-specific theme files.
- To stop tracking a file: add it to `.stow-local-ignore`, then run `stow -D . && stow .` to re-apply.

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

`.config/mise/config.toml` declares the tool versions. `mise install` installs them. Tools: `bun` (latest), `dotnet` (latest), `node` (lts), `pnpm` (latest), `python` (latest), `tmux` (latest). `experimental = true` is on for any future GitHub plugins.

### Neovim

`.config/nvim/` is a LazyVim-based setup. Plugin specs live in `lua/plugins/`. Notable plugins:
- `easy-dotnet.lua` — .NET/C# dev (requires `dotnet tool install -g EasyDotnet`)
- `omarchy-theme-hotreload.lua` — live theme switching (used with Omarchy Linux)
- `all-themes.lua` — theme collection
- `theme.lua` — machine-specific active theme (stow-ignored, not tracked)

`lazy-lock.json` pins plugin versions — commit changes to it when intentionally upgrading plugins.

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
