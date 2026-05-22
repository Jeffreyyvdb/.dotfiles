[[ $- != *i* ]] && return

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
source ~/.config/shell/rc

eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(mise activate bash)"

# Override lazygit config directory (MacOS has different directory)
export XDG_CONFIG_HOME="$HOME/.config"

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"
