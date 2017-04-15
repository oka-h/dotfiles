# ------------------------------------------------------------------------------
# ${ZDOTDIR}/.zshrc
# ------------------------------------------------------------------------------

# Load shell functions.
autoload -U compinit colors promptinit
compinit
colors
promptinit

# Don't beep.
setopt nolistbeep

# Setting of prompt.
local       user="%F{green}%n@%m%f"
local       cdir="%F{yellow}%~%f"
local multi_line="%F{green}%_%f "
local       mark="%B%#%b"

PROMPT="
$user $cdir
$mark "

PROMPT2="$multi_line $mark "
SPROMPT="%F{green}%r is correct? [n,y,a,e]%f%B:%b "


# Display completion list with colors.
zstyle ':completion:*' list-colors ''

# Pack lists.
setopt list_packed

# Correct command automatically.
setopt correct

# Save 10000 previous commands.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Ignore duplication command history list.
setopt hist_ignore_dups

# Share command history data.
setopt share_history        

# Display up to 100 directory history.
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

# Setting of aliases.
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

alias javac='javac -J-Dfile.encoding=UTF-8'
alias java='java -Dfile.encoding=UTF-8'


# Load a local zshrc file if there is it.
[ -f ~/.zshrc_local ] && source ~/.zshrc_local

