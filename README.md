# .dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for macOS and Arch Linux.

## What's Included

| Category | Tools |
|----------|-------|
| Terminal Emulators | Alacritty, Ghostty |
| Shell | Zsh (macOS), Bash (Linux/Omarchy), shared cross-platform config |
| Prompt | Starship |
| Editor | Neovim (LazyVim) with .NET/C# support |
| Git | Git, Lazygit, Delta |
| Multiplexer | tmux |
| AI / Dev Tools | OpenCode, Claude, Entire CLI |
| System Monitor | btop |
| Shell Functions | SSH port forwarding, tmux dev layouts, video/image transcoding, compression |

## Quick Start

### 1. Install stow

```bash
# macOS
brew install stow

# Arch Linux
sudo pacman -S stow
```

### 2. Clone

```bash
git clone git@github.com:Jeffreyyvdb/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Backup existing configs

```bash
# Back up any files that would conflict
cp ~/.zshrc ~/.zshrc.backup    # macOS
cp ~/.bashrc ~/.bashrc.backup  # Linux
```

### 4. Create machine-specific local config

These files are git-ignored and stow-ignored, so they stay local to each machine.

**macOS** (`~/.zshrc.local`):

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -f ~/.nvm/nvm.sh ]] && source ~/.nvm/nvm.sh
```

**Omarchy Linux** (`~/.bashrc.local`):

```bash
source ~/.local/share/omarchy/default/bashrc
```

### 5. Stow

```bash
cd ~/.dotfiles
stow -v .
```

### 6. Install dependencies

See the [Dependencies](#dependencies) section below.

### 7. Install mise-managed runtimes

```bash
mise install
```

This installs dotnet, node, python, tmux, and Entire CLI as defined in `.config/mise/config.toml`.

## Dependencies

### Required

These tools power the shell aliases, functions, and prompt. Without them the shell config will partially break or degrade.

| Tool | macOS | Arch Linux | Purpose |
|------|-------|------------|---------|
| [fzf](https://github.com/junegunn/fzf) | `brew install fzf` | `sudo pacman -S fzf` | Fuzzy finder (`ff`, `Ctrl+R` history, Neovim `Space Space`) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `brew install zoxide` | `sudo pacman -S zoxide` | Smart `cd` replacement (remembers directories) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `brew install ripgrep` | `sudo pacman -S ripgrep` | Fast file content search (`rg`, Neovim `Space s g`) |
| [eza](https://github.com/eza-community/eza) | `brew install eza` | `sudo pacman -S eza` | Modern `ls` with icons (`ls`, `lsa`, `lt`, `lta`) |
| [fd](https://github.com/sharkdp/fd) | `brew install fd` | `sudo pacman -S fd` | Fast `find` replacement |
| [bat](https://github.com/sharkdp/bat) | `brew install bat` | `sudo pacman -S bat` | `cat` with syntax highlighting (used by `ff` preview) |
| [Starship](https://starship.rs) | `brew install starship` | `curl -sS https://starship.rs/install.sh \| sh` | Cross-shell prompt |
| [mise](https://mise.jdx.dev) | `brew install mise` | `sudo pacman -S mise` | Multi-tool version manager (dotnet, node, python, etc.) |
| [delta](https://github.com/dandavison/delta) | `brew install git-delta` | `sudo pacman -S git-delta` | Better git diffs (used by lazygit) |

### Optional

These tools have configs in the repo but the shell will work fine without them.

| Tool | macOS | Arch Linux | Purpose |
|------|-------|------------|---------|
| [Neovim](https://neovim.io) | `brew install neovim` | `sudo pacman -S neovim` | Primary editor (LazyVim-based IDE) |
| [tmux](https://github.com/tmux/tmux) | Managed by mise | Managed by mise | Terminal multiplexer |
| [Lazygit](https://github.com/jesseduffield/lazygit) | `brew install lazygit` | `sudo pacman -S lazygit` | Git TUI (also available inside Neovim) |
| [btop](https://github.com/aristocratos/btop) | `brew install btop` | `sudo pacman -S btop` | System monitor with vim keys |
| [Alacritty](https://alacritty.org) | `brew install --cask alacritty` | `sudo pacman -S alacritty` | GPU-accelerated terminal |
| [Ghostty](https://ghostty.org) | `brew install --cask ghostty` | See [Ghostty docs](https://ghostty.org/docs/install) | Terminal emulator |
| [Docker](https://www.docker.com) | `brew install --cask docker` | `sudo pacman -S docker` | Container runtime (alias `d`) |
| [ffmpeg](https://ffmpeg.org) | `brew install ffmpeg` | `sudo pacman -S ffmpeg` | Video transcoding functions |
| [ImageMagick](https://imagemagick.org) | `brew install imagemagick` | `sudo pacman -S imagemagick` | Image conversion functions |

### .NET Development (Neovim)

If using the Neovim .NET/C# setup (`easy-dotnet.nvim`):

```bash
# .NET SDK is installed via mise (see above)
dotnet tool install -g EasyDotnet

# Debugger
# macOS
brew install netcoredbg

# Arch Linux (AUR)
yay -S netcoredbg
```

### Managed by mise

These tools are auto-installed when you run `mise install`:

| Tool | Version |
|------|---------|
| dotnet | latest |
| node | lts |
| python | latest |
| tmux | latest |
| [Entire CLI](https://entire.io) | latest |

## Shell Config Structure

Both `.bashrc` (Linux) and `.zshrc` (macOS) source a shared config in `.config/shell/`:

```
.config/shell/
├── rc              # Main entry point (sources envs, aliases, functions)
├── envs            # Environment variables (EDITOR=nvim, BAT_THEME, etc.)
├── aliases         # Portable aliases (eza, fzf, zoxide, git, docker, etc.)
├── functions       # Sources all files in fns/
└── fns/
    ├── compression          # compress/decompress (tar.gz) helpers
    ├── ssh-port-forwarding  # fip/dip/lip: SSH port forwarding
    ├── tmux                 # tdl/tdlm/tsl: dev layout functions
    └── transcoding          # ffmpeg video + ImageMagick image conversion
```

### Key Aliases

| Alias | Command |
|-------|---------|
| `ls` | `eza -lh --group-directories-first --icons` |
| `ff` | `fzf` with `bat` preview |
| `eff` | Open `ff` result in `$EDITOR` |
| `cd` | `zoxide` smart directory jump |
| `n` | `nvim` (opens `.` if no args) |
| `c` | `opencode` |
| `t` | `tmux attach \|\| tmux new -s Work` |
| `g` | `git` |
| `d` | `docker` |

## Machine-Specific Config

The `.bashrc` and `.zshrc` source `.*.local` files **before** the shared config, so machine-specific defaults load first and shared config overrides them.

- `.zshrc.local` / `.bashrc.local` are **git-ignored** and **stow-ignored**
- Each machine can set up Homebrew paths, nvm, or Omarchy defaults without affecting the shared repo

## Fonts

Both terminal configs (Alacritty and Ghostty) expect **JetBrainsMono Nerd Font**:

```bash
# macOS
brew install --cask font-jetbrains-mono-nerd-font

# Arch Linux
sudo pacman -S ttf-jetbrains-mono-nerd
```
