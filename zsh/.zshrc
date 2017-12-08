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

local       user="%F{173}%n@%m%f"
local       cdir="%F{242}%~%f"
local multi_line="%F{226}%_%f"
local       mark="%#"

PROMPT="
$user $cdir
$mark "

PROMPT2="$multi_line $mark "


export LS_COLORS="\
no=38;05;254:\
fi=38;05;254:\
di=38;05;75:\
ln=38;05;86:\
or=38;05;242:\
mi=38;05;242:\
ex=38;05;218:\
ow=38;05;106"

zstyle ':completion:*' list-colors $LS_COLORS

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

if type nvim > /dev/null 2>&1; then
  editor=nvim
elif type vim > /dev/null 2>&1; then
  editor=vim
elif type vi > /dev/null 2>&1; then
  editor=vi
fi

export EDITOR=$editor


[ -f ~/.shellrc_local ] && source ~/.shellrc_local
[ -f ~/.zshrc_local ] && source ~/.zshrc_local

