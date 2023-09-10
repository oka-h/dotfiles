export HISTSIZE=10000
export SAVEHIST=10000

export LS_COLORS="\
no=38;05;254:\
fi=38;05;254:\
di=38;05;75:\
ln=38;05;86:\
or=38;05;242:\
mi=38;05;242:\
ex=38;05;218:\
ow=38;05;106"

export LSCOLORS=gxfxcxdxbxegedabagacad

if type vim > /dev/null 2>&1 && [ $(vim --version | grep -c +terminal) -gt 0 ]; then
  export EDITOR=vim
elif type nvim > /dev/null 2>&1; then
  export EDITOR=nvim
elif type vim > /dev/null 2>&1; then
  export EDITOR=vim
elif type vi > /dev/null 2>&1; then
  export EDITOR=vi
fi

case "$OSTYPE" in
  linux* | cygwin | msys)
    alias ls="ls --color"
    ;;
  freebsd* | darwin*)
    if type gls > /dev/null 2>&1; then
      alias ls="gls --color=auto"
    else
      alias ls="ls -G -w"
    fi
    ;;
esac

alias la="ls -a"
alias ll="ls -l"
alias lal="ls -al"
alias lla="ls -al"
alias l="ls"
alias sl="ls"
alias grep="grep --color"

if [[ $VIM_SERVERNAME =~ ^vim-server[0-9]+$ ]]; then
  alias e="vim --servername \$VIM_SERVERNAME --remote"
  alias tabe="vim --servername \$VIM_SERVERNAME --remote-tab"
elif [ -n "$VIM_SERVERNAME" ] && type /Applications/MacVim.app/Contents/bin/mvim > /dev/null 2>&1; then
  alias e="/Applications/MacVim.app/Contents/bin/mvim --remote"
  alias tabe="/Applications/MacVim.app/Contents/bin/mvim --remote-tab"
else
  alias e=$EDITOR
  alias tabe="$EDITOR -p"
fi
