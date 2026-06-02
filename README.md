# .dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for macOS, Ubuntu, and Arch Linux.

The tool choices and config here are largely based on [Omarchy Linux](https://omarchy.org/) — this repo carries that setup across machines that don't run Omarchy (work/personal Macs and Ubuntu servers).

## Implement with an Agent

Don't want to follow the steps by hand? Hand the whole thing to an AI agent (Claude Code, etc.). Paste a prompt like this:

```text
Install my dotfiles from git@github.com:Jeffreyyvdb/.dotfiles.git.

Read the repo's README first, then:
1. Install GNU Stow for my OS.
2. Clone the repo to ~/.dotfiles.
3. Back up any conflicting ~/.zshrc / ~/.bashrc before stowing.
4. Create the machine-specific ~/.zshrc.local (macOS) or ~/.bashrc.local (Linux)
   exactly as the README's "Create machine-specific local config" step describes.
5. Run `stow -v .` from ~/.dotfiles.
6. Install the Required dependencies for my OS from the Dependencies tables.
7. Run `mise install`.

Tell me before overwriting anything, and stop if something conflicts.
Note: this repo auto-syncs from git on every new shell — if I don't want that,
set `export DOTFILES_AUTO_SYNC=0` in my local rc (see the Dotfiles Sync section).
```

The agent should work through the OS-specific tables below rather than guessing package names. Everything it does maps to the manual [Quick Start](#quick-start) steps, so you can review each one.

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

# Ubuntu
sudo apt install -y stow

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

**Ubuntu** (`~/.bashrc.local`):

```bash
# ~/.local/bin holds fd/bat symlinks and the mise binary
export PATH="$HOME/.local/bin:$PATH"

# Activate mise
eval "$($HOME/.local/bin/mise activate bash)"
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

| Tool | macOS | Ubuntu | Arch Linux | Purpose |
|------|-------|--------|------------|---------|
| [fzf](https://github.com/junegunn/fzf) | `brew install fzf` | `sudo apt install fzf` | `sudo pacman -S fzf` | Fuzzy finder (`ff`, `Ctrl+R` history, Neovim `Space Space`) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `brew install zoxide` | `curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \| sh` | `sudo pacman -S zoxide` | Smart `cd` replacement (remembers directories) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `brew install ripgrep` | `sudo apt install ripgrep` | `sudo pacman -S ripgrep` | Fast file content search (`rg`, Neovim `Space s g`) |
| [eza](https://github.com/eza-community/eza) | `brew install eza` | See [eza Ubuntu install](#eza-ubuntu) | `sudo pacman -S eza` | Modern `ls` with icons (`ls`, `lsa`, `lt`, `lta`) |
| [fd](https://github.com/sharkdp/fd) | `brew install fd` | `sudo apt install fd-find` ¹ | `sudo pacman -S fd` | Fast `find` replacement |
| [bat](https://github.com/sharkdp/bat) | `brew install bat` | `sudo apt install bat` ¹ | `sudo pacman -S bat` | `cat` with syntax highlighting (used by `ff` preview) |
| [Starship](https://starship.rs) | `brew install starship` | `curl -sS https://starship.rs/install.sh \| sh` | `curl -sS https://starship.rs/install.sh \| sh` | Cross-shell prompt |
| [mise](https://mise.jdx.dev) | `brew install mise` | `curl https://mise.run \| sh` | `sudo pacman -S mise` | Multi-tool version manager (dotnet, node, python, etc.) |
| [delta](https://github.com/dandavison/delta) | `brew install git-delta` | See [delta Ubuntu install](#delta-ubuntu) | `sudo pacman -S git-delta` | Better git diffs (used by lazygit) |

> ¹ **Ubuntu name differences:** `fd` is packaged as `fd-find` (binary: `fdfind`) and `bat` as `batcat`. Add symlinks so the standard names work:
> ```bash
> mkdir -p ~/.local/bin
> ln -sf $(which fdfind) ~/.local/bin/fd
> ln -sf $(which batcat) ~/.local/bin/bat
> ```

#### eza (Ubuntu) {#eza-ubuntu}

eza is not in the default Ubuntu repos. Install via the official deb repository:

```bash
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza
```

#### delta (Ubuntu) {#delta-ubuntu}

```bash
DELTA_VER=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sLO "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/git-delta_${DELTA_VER}_amd64.deb"
sudo dpkg -i git-delta_${DELTA_VER}_amd64.deb
rm git-delta_${DELTA_VER}_amd64.deb
```

### Optional

These tools have configs in the repo but the shell will work fine without them.

| Tool | macOS | Ubuntu | Arch Linux | Purpose |
|------|-------|--------|------------|---------|
| [Neovim](https://neovim.io) | `brew install neovim` | See [Neovim Ubuntu install](#neovim-ubuntu) | `sudo pacman -S neovim` | Primary editor (LazyVim-based IDE) |
| [tmux](https://github.com/tmux/tmux) | Managed by mise | Managed by mise | Managed by mise | Terminal multiplexer |
| [Lazygit](https://github.com/jesseduffield/lazygit) | `brew install lazygit` | See [Lazygit Ubuntu install](#lazygit-ubuntu) | `sudo pacman -S lazygit` | Git TUI (also available inside Neovim) |
| [btop](https://github.com/aristocratos/btop) | `brew install btop` | `sudo apt install btop` | `sudo pacman -S btop` | System monitor with vim keys |
| [Alacritty](https://alacritty.org) | `brew install --cask alacritty` | `sudo apt install alacritty` | `sudo pacman -S alacritty` | GPU-accelerated terminal |
| [Ghostty](https://ghostty.org) | `brew install --cask ghostty` | See [Ghostty docs](https://ghostty.org/docs/install) | See [Ghostty docs](https://ghostty.org/docs/install) | Terminal emulator |
| [Docker](https://www.docker.com) | `brew install --cask docker` | See [Docker docs](https://docs.docker.com/engine/install/ubuntu/) | `sudo pacman -S docker` | Container runtime (alias `d`) |
| [ffmpeg](https://ffmpeg.org) | `brew install ffmpeg` | `sudo apt install ffmpeg` | `sudo pacman -S ffmpeg` | Video transcoding functions |
| [ImageMagick](https://imagemagick.org) | `brew install imagemagick` | `sudo apt install imagemagick` | `sudo pacman -S imagemagick` | Image conversion functions |

#### Neovim (Ubuntu) {#neovim-ubuntu}

Ubuntu's apt version is outdated. Install the latest via AppImage:

```bash
curl -sLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
```

#### Lazygit (Ubuntu) {#lazygit-ubuntu}

```bash
LAZYGIT_VER=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/v//')
curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VER}/lazygit_${LAZYGIT_VER}_Linux_x86_64.tar.gz"
tar -xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin/
rm lazygit lazygit.tar.gz
```

### .NET Development (Neovim)

If using the Neovim .NET/C# setup (`easy-dotnet.nvim`):

```bash
# .NET SDK is installed via mise (see above)
dotnet tool install -g EasyDotnet

# Debugger
# macOS
brew install netcoredbg

# Ubuntu — install from GitHub releases
NETCOREDBG_VER=$(curl -s https://api.github.com/repos/Samsung/netcoredbg/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sLo netcoredbg.tar.gz "https://github.com/Samsung/netcoredbg/releases/download/${NETCOREDBG_VER}/netcoredbg-linux-amd64.tar.gz"
tar -xf netcoredbg.tar.gz && sudo mv netcoredbg /usr/local/bin/ && rm netcoredbg.tar.gz

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
- They are sourced **before** the shared config, so any override below (`DOTFILES_*`, etc.) takes effect

## Dotfiles Sync

Every interactive shell keeps this repo in sync with the remote automatically (defined in `.config/shell/fns/dotfiles`). The goal is that opening a terminal on any machine pulls in the latest committed config without you remembering to `git pull` and `stow`.

**On startup it:**

- Runs a **throttled background `git fetch`** (never blocks the shell on the network — the result is used by the *next* shell).
- If the working tree is **clean and behind** the remote → **fast-forwards and runs `stow --restow .`** automatically, then prints `✓ dotfiles: applied N remote commit(s)`.
- If you have **uncommitted local changes** → prints a banner listing them and does **nothing else** (never auto-merges over your work).
- If the branch has **diverged** or has **unpushed commits** → prints a banner only.
- If **up to date** → silent.

It **never auto-commits and never auto-pushes** — only fast-forwards a clean tree.

**Manual command** (works regardless of the auto-sync setting):

| Command | Does |
|---------|------|
| `dotfiles status` | Fetch + show branch and ahead/behind counts |
| `dotfiles apply` | Fast-forward the remote + restow, on demand |
| `dotfiles diff` | Show uncommitted local changes |

### Turning it off / tuning

Set these in `~/.zshrc.local` / `~/.bashrc.local` (sourced before the shared config):

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_AUTO_SYNC` | `1` | Set `0` to disable the startup fetch/apply entirely. The manual `dotfiles` command still works. |
| `DOTFILES_FETCH_INTERVAL` | `43200` | Seconds between background fetches (12h). |
| `DOTFILES_DIR` | `$HOME/.dotfiles` | Repo location. |

To opt out completely:

```bash
# ~/.zshrc.local (macOS) or ~/.bashrc.local (Linux)
export DOTFILES_AUTO_SYNC=0
```

## Fonts

Both terminal configs (Alacritty and Ghostty) expect **JetBrainsMono Nerd Font**:

```bash
# macOS
brew install --cask font-jetbrains-mono-nerd-font

# Ubuntu
mkdir -p ~/.local/share/fonts
curl -sLo /tmp/JetBrainsMono.tar.xz \
  "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts
fc-cache -f

# Arch Linux
sudo pacman -S ttf-jetbrains-mono-nerd
```

## License

[MIT](LICENSE). The AI agent skills under `.agents/skills/` and `.claude/skills/` are third-party and retain their own licenses; see `.agents/skills/skills-lock.json` for their upstream sources.
