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

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
