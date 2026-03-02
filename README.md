# How to use this .dotfiles repo

## Install stow

### MacOS

```
brew install stow
```

### Arch Linux

```
sudo pacman -S stow
```

## Clone

```
git clone git@github.com:yourusername/.dotfiles.git ~/.dotfiles
```

## Usage

```
stow -v .
```

## Required Tools

These tools provide the aliases and functions in the shell config:

### fzf

Fuzzy finding of files. Go to any directory, type `ff`, and fuzzy find your way to any file with a preview on the right.

- `Ctrl + R` - fuzzy find through command history
- Also used by Neovim with `Space Space`

```
# MacOS
brew install fzf

# Arch Linux
sudo pacman -S fzf
```

### zoxide

Replacement for `cd` that remembers directories. Navigate to `~/.local/share/omarchy` once, then `cd omarchy` (or even `cd oma`) jumps there directly.

```
# MacOS
brew install zoxide

# Arch Linux
sudo pacman -S zoxide
```

### ripgrep

Search file contents with `rg <pattern> <path>`, e.g., `rg Controller app/`. Also used by Neovim with `Space S G`.

```
# MacOS
brew install ripgrep

# Arch Linux
sudo pacman -S ripgrep
```

### eza

Replacement for `ls` with colors and icons. Aliased as `ls` by default.

- `lsa` - listing with hidden files
- `lt` - two-deep nested listing
- `lta` - nested listing with hidden files

```
# MacOS
brew install eza

# Arch Linux
sudo pacman -S eza
```

### fd

Easier replacement for `find`. Use `fd person.rb` to find a file, or `fd person.rb / -H` to search the entire filesystem including hidden.

```
# MacOS
brew install fd

# Arch Linux
sudo pacman -S fd
```

### bat

A `cat` clone with syntax highlighting. Used by `ff` for file previews.

```
# MacOS
brew install bat

# Arch Linux
sudo pacman -S bat
```

## Shell Config Structure

```
.config/shell/
├── rc          # Main entry point
├── envs        # Environment variables
├── aliases     # Portable aliases
├── functions   # Sources fns/*
└── fns/        # Function files
    ├── compression
    ├── ssh-port-forwarding
    ├── tmux
    └── transcoding
```

This shared config is sourced by both `.bashrc` (Linux/Omarchy) and `.zshrc` (macOS).

## Machine-Specific Config

The stowed `.bashrc` and `.zshrc` source `.*.local` files before the shared config, letting machine-specific defaults load first and your shared config override them.

### Omarchy Linux

```bash
# ~/.bashrc.local (sources Omarchy defaults, shared config overrides)
source ~/.local/share/omarchy/default/bashrc
```

### macOS

```bash
# ~/.zshrc.local (machine-specific tools)
eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -f ~/.nvm/nvm.sh ]] && source ~/.nvm/nvm.sh
```

These files are ignored by git and stow, so they stay local to each machine.

### Before Stowing on a New Machine

```bash
cp ~/.zshrc ~/.zshrc.backup  # or ~/.bashrc
stow -v .
# Then create your .zshrc.local or .bashrc.local as needed
```

### Shell / Terminal prompt.

starship.rs used: install `curl -sS https://starship.rs/install.sh | sh`
