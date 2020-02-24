# ------------------------------------------------------------------------------
# dotfiles/shell/.zshrc
# ------------------------------------------------------------------------------

source $ZDOTDIR/shellrc

autoload -Uz colors
colors
if ! declare -f compinit > /dev/null 2>&1; then
  autoload -Uz compinit
  compinit -u
fi

export HISTFILE=~/.zsh_history
export DIRESTACKSIZE=100

local user=$'%{\e[38;05;173m%}%n@%m\e[0m'
local cdir=$'%{\e[38;05;242m%}%~\e[0m'
local multi_line=$'%{\e[38;05;226m%}%_\e[0m'
local mark="%#"

export PROMPT="
$user $cdir
$mark "
export PROMPT2="$multi_line $mark "


zstyle ':completion:*' list-colors $LS_COLORS

setopt share_history        
setopt hist_ignore_dups
setopt nolistbeep
setopt list_packed
setopt auto_pushd
setopt pushdignoredups

bindkey -v
bindkey -M viins '^b' backward-char
bindkey -M viins '^f' forward-char
bindkey -M vicmd ' h' beginning-of-line
bindkey -M vicmd ' l' end-of-line

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end

cd-upper() {
  zle push-line
  LBUFFER="cd .."
  zle accept-line
}

zle -N cd-upper
bindkey '^k' cd-upper

autoload -Uz smart-insert-last-word
zstyle :insert-last-word match '*([[:alpha:]/\\]?|?[[:alpha:]/\\])*'
zle -N insert-last-word smart-insert-last-word
bindkey '^t' insert-last-word

[ -f ~/.shellrc_local ] && source ~/.shellrc_local
