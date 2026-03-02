# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

# Delta in Git

To enable better difs in git and lazygit i use delta

`brew install git-delta`

OVerride the lazygit config location: 
in bashrc or zshrc 
```
export XDG_CONFIG_HOME="$HOME/.config

```

```
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    side-by-side = true
    syntax-theme = Dracula  # or any theme you like
```

# Nvim dotnet development
For easy dotnet the dotnet tool needs to be installed
`dotnet tool install -g EasyDotnet`
```
