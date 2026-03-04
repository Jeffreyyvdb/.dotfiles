[[ $- != *i* ]] && return

autoload -Uz compinit && compinit

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
HISTSIZE=32768
SAVEHIST=$HISTSIZE

bindkey -e

source ~/.config/shell/rc

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

# Override lazygit config directory (MacOS has different directory)
export XDG_CONFIG_HOME="$HOME/.config"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
