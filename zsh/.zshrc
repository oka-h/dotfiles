# ------------------------------------------------------------------------------
# dotfiles/zsh/.zshrc
# ------------------------------------------------------------------------------

[ -f /etc/zshrc ] && source /etc/zshrc

# Load shell functions.
autoload -U compinit colors promptinit
compinit
colors
promptinit

setopt nolistbeep

local       user="%F{green}%n@%m%f"
local       cdir="%F{yellow}%~%f"
local multi_line="%F{green}%_%f "
local       mark="%B%#%b"

PROMPT="
$user $cdir
$mark "

PROMPT2="$multi_line $mark "


zstyle ':completion:*' list-colors ''

setopt list_packed

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt hist_ignore_dups

setopt share_history        

DIRESTACKSIZE=100

# List recently accessed directory.
setopt auto_pushd

# Set vi keybind.
bindkey -v

# Historical backward/forward search with linehead string binded to Ctrl-P/N.
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey "" history-beginning-search-backward-end
bindkey "" history-beginning-search-forward-end

case "${OSTYPE}" in
  freebsd*|darwin*)
    alias ls="ls -G -w"
    ;;
  linux*|cygwin)
    alias ls="ls --color"
    ;;
esac

alias la="ls -a"
alias ll="ls -l"
alias lal="ls -al"
alias lla="ls -al"


[ -f ~/.shellrc_local ] && source ~/.shellrc_local
[ -f ~/.zshrc_local ] && source ~/.zshrc_local

