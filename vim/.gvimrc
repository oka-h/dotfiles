" ------------------------------------------------------------------------------
" ~/.gvimrc
"
" ~/.config/nvim/ginit.vim
" ------------------------------------------------------------------------------

" Don't display a menu bar.
set guioptions-=m

" Don't display a tool bar.
set guioptions-=T

" Display a non-GUI tab pages.
set guioptions-=e

" Setting of the colorscheme.
if !exists('g:colors_name')
    colorscheme torte
endif

" Show the cursor line.
" set cursorline

" Number of line shown.
set lines=40

" Number of columns shown.
set columns=120

