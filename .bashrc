[[ $- != *i* ]] && return

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
source ~/.config/shell/rc

eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(mise activate bash)"
