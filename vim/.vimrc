" ------------------------------------------------------------------------------
" ~/.vimrc
"
" $XDG_CONFIG_HOME/nvim/init.vim
" ------------------------------------------------------------------------------

" ------------------------------------------------------------------------------
" Pre-settings
" ------------------------------------------------------------------------------

if has('vim_starting') && &encoding !=# 'utf-8'
    if (has('win32') || has('win64')) && !has('gui_running')
        set encoding=cp932
    else
        set encoding=utf-8
    endif
endif

set fileencodings=usc-bom,utf-8,iso-2022-jp-3,euc-jp,cp932


let g:disable_plugins = []

let s:vimrc_local_pre = expand('~/.vimrc_local_pre')
if filereadable(s:vimrc_local_pre)
    execute 'source' s:vimrc_local_pre
endif

let s:xdg_cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache')
                                            \ : $XDG_CACHE_HOME


" ------------------------------------------------------------------------------
" Dein.vim settings
" ------------------------------------------------------------------------------

" The directory installed plugins.
let g:dein_dir = s:xdg_cache_home . expand('/dein')

" Dein.vim location.
let s:dein_repo_dir = g:dein_dir . expand('/repos/github.com/Shougo/dein.vim')

function! s:install_dein()
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    if isdirectory(s:dein_repo_dir)
        call s:load_dein()
        delcommand DeinInstall
    endif
endfunction


function! s:load_dein()
    if &runtimepath !~# expand('/dein.vim')
        execute 'set runtimepath^=' . s:dein_repo_dir
    endif

    if dein#load_state(g:dein_dir)
        let s:toml_dir   = expand('~/dotfiles/vim')
        let s:toml       = s:toml_dir . expand('/dein.toml')
        let s:local_toml = expand('~/.dein_local.toml')

        call dein#begin(g:dein_dir, expand('<sfile>'))

        call dein#load_toml(s:toml)
        if filereadable(s:local_toml)
            call dein#load_toml(s:local_toml)
        endif

        call dein#end()
        call dein#save_state()
    endif

    call dein#call_hook('source')

    if dein#check_install()
        call dein#install()
    endif

    call dein#disable(g:disable_plugins)
    unlet g:disable_plugins
endfunction


if isdirectory(s:dein_repo_dir)
    call s:load_dein()
else
    command! DeinInstall call s:install_dein()
    augroup nodein_call
        autocmd!
        autocmd VimEnter * echomsg 'Dein.vim is not installed. Please install it by :DeinIntall.'
    augroup END
endif

" ------------------------------------------------------------------------------
" General settings
" ------------------------------------------------------------------------------

set autoread
set noundofile
set history=10000
set helplang=ja
set ambiwidth=double

" Dirctory for backup/swap file.
let s:temp_dir = s:xdg_cache_home . expand('/vim')
if !isdirectory(s:temp_dir)
    call mkdir(s:temp_dir, 'p')
endif

set backup
execute 'set backupdir=' . s:temp_dir

set swapfile
execute 'set directory=' . s:temp_dir

" Don't beep.
if has('nvim') || v:version + has('patch793') >= 705
    set belloff=all
else
    set visualbell t_vb=
endif

" Save vim state when vim finishes, and restore it when vim starts.
" This is available only when g:save_session is not 0.
augroup save_and_load_session
    autocmd!
    let s:session_file = expand('~/.vimsession')

    if filereadable(s:session_file)
        " Restore a previous session file when vim starts with no argument.
        autocmd VimEnter * nested if @% == '' && s:get_buf_byte() == 0
                              \ |     execute 'source' s:session_file
                              \ |     call delete(s:session_file)
                              \ | endif
    endif

    " Save current session file when vim finishes.
    let g:save_session = 0
    autocmd VimLeave * if g:save_session != 0
                   \ |     execute 'mksession!' s:session_file
                   \ | endif
augroup END

function! s:get_buf_byte()
    let l:byte = line2byte(line('$') + 1)
    return l:byte == -1 ? 0 : byte - 1
endfunction


if has('nvim')
    let g:terminal_scrollback_buffer_size = 100000
endif

" ------------------------------------------------------------------------------
" Key map settings
" ------------------------------------------------------------------------------

noremap <BS>    <Nop>
noremap <Space> <Nop>

noremap ; :
noremap : ;
nnoremap q; q:

noremap j gj
noremap gj j
noremap k gk
noremap gk k

noremap <Space>y "+y
noremap <Space>p "+p
noremap <Space>P "+P

noremap <Space>c "_c
noremap <Space>C "_C
noremap <Space>d "_d
noremap <Space>D "_D
noremap <Space>s "_s
noremap <Space>S "_S
noremap <Space>x "_x
noremap <Space>X "_X

noremap <Space>f f<C-K>
noremap <Space>F F<C-K>
noremap <Space>t t<C-K>
noremap <Space>T T<C-K>

" Solve the problem that Delete key does not work.
if has('unix') && !has('gui_running')
    noremap!  
endif

" Go to optional tab page.
nnoremap <silent> <Space>1 :<C-U>call <SID>go_to_tab(1)<CR>
nnoremap <silent> <Space>2 :<C-U>call <SID>go_to_tab(2)<CR>
nnoremap <silent> <Space>3 :<C-U>call <SID>go_to_tab(3)<CR>
nnoremap <silent> <Space>4 :<C-U>call <SID>go_to_tab(4)<CR>
nnoremap <silent> <Space>5 :<C-U>call <SID>go_to_tab(5)<CR>
nnoremap <silent> <Space>6 :<C-U>call <SID>go_to_tab(6)<CR>
nnoremap <silent> <Space>7 :<C-U>call <SID>go_to_tab(7)<CR>
nnoremap <silent> <Space>8 :<C-U>call <SID>go_to_tab(8)<CR>
nnoremap <silent> <Space>9 :<C-U>call <SID>go_to_tab(9)<CR>
nnoremap <silent> <Space>0 :<C-U>call <SID>go_to_tab(0)<CR>

function! s:go_to_tab(num)
    let l:tabnum = a:num
    let l:lasttab = tabpagenr('$')
    if l:tabnum > l:lasttab || l:tabnum == 0
        let l:tabnum = l:lasttab
    endif
    execute 'tabnext ' . l:tabnum
endfunction


nnoremap <Esc><Esc> :<C-U>nohlsearch<CR>

inoremap <C-B> <Left>
inoremap <C-F> <Right>
inoremap <C-L> <Del>

inoremap {     {}<Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap {}    {}
inoremap {{{   {{{
inoremap (     ()<Left>
inoremap ()    ()
inoremap [     []<Left>
inoremap []    []
inoremap "     ""<Left>
inoremap ""    ""
inoremap '     ''<Left>
inoremap ''    ''

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Assign <Home> and <End> to "<Space>h" and "<Space>l". This uses "g^", "^" and
" "0" or "g$" and "$" for different purposes in accordance situations.
nnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_head('n')<CR>
vnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_head('v')<CR>
onoremap          <Space>h ^
nnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_end('n')<CR>
vnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_end('v')<CR>
onoremap          <Space>l $

function! s:go_to_line_head(mode)
    if a:mode == 'v'
        normal! gv
    endif
    let l:bef_col = col('.')
    normal! g^
    let l:aft_col = col('.')
    if l:bef_col == l:aft_col
        normal! ^
        let l:aft_col = col('.')
        if l:bef_col == l:aft_col
            normal! 0
        endif
    endif
endfunction

function! s:go_to_line_end(mode)
    if a:mode == 'v'
        normal! gv
    endif
    let l:bef_col = col('.')
    normal! g$
    let l:aft_col = col('.')
    if l:bef_col == l:aft_col
        normal! $
    endif
endfunction


if has('nvim')
    tnoremap <Esc><Esc> <C-\><C-N>
endif


" ------------------------------------------------------------------------------
" Display settings
" ------------------------------------------------------------------------------

set relativenumber
set numberwidth=3
set scrolloff=3
set list
set listchars=tab:>-,extends:>
set showcmd
set lazyredraw
set laststatus=2

set statusline=%!g:My_status_line()

function! g:My_status_line()
    let l:pwd  = ' ['
    let l:pwd .= (getcwd() == $HOME) ? '~/'
                                   \ : '/' . fnamemodify(getcwd(), ':~:t')
    let l:pwd .= '] '
    let l:file = '%<%F%m%r%h%w%= '

    let l:format   = (&fileformat   != '') ? '| ' . &fileformat   . ' ' : ''
    let l:encoding = (&fileencoding != '') ? '| ' . &fileencoding . ' ' : ''
    let l:filetype = (&filetype     != '') ? '| ' . &filetype     . ' ' : ''

    let l:col = '| %3v'
    let l:line_digit = (float2nr(log10(line('$')))+1)
    let l:line = ':%' . l:line_digit . 'l '
    let l:max_line = '/ %L '

    return l:pwd . l:file . l:format . l:encoding . l:filetype . l:col . l:line . l:max_line
endfunction


" ------------------------------------------------------------------------------
" Color settings
" ------------------------------------------------------------------------------

set t_Co=256

augroup highlights
    autocmd!
    autocmd ColorScheme * highlight CursorLineNr cterm=bold ctermfg=173 gui=bold   guifg=#D7875F
augroup END

" Highlight two-byte spaces.

function! s:set_tbs_hl()
    highlight two_byte_space cterm=underline ctermfg=red gui=underline guifg=red
endfunction

if has('syntax')
    augroup two_byte_space
        autocmd!
        autocmd VimEnter,WinEnter * match two_byte_space /　/
        autocmd VimEnter,WinEnter * match two_byte_space '\%u3000'
        autocmd ColorScheme       * call s:set_tbs_hl()
    augroup END
    call s:set_tbs_hl()
endif


syntax enable

if !exists('g:colors_name')
    colorscheme torte
endif


" ------------------------------------------------------------------------------
" Search settings
" ------------------------------------------------------------------------------

set ignorecase
set smartcase
set incsearch
set wrapscan

augroup hlsearch
    autocmd!
    autocmd VimEnter * set hlsearch
augroup END

" Save the last search word and hlsearch for each buffers.
augroup localized_search
    autocmd!
    autocmd WinLeave * let b:vimrc_pattern = @/
    autocmd WinEnter * let @/ = get(b:, 'vimrc_pattern', @/)
augroup END

" In visual mode, search the selected string by "*" or "#".
xnoremap * :<C-U>call <SID>visual_star_search('/')<CR>
xnoremap # :<C-U>call <SID>visual_star_search('?')<CR>

function! s:visual_star_search(key)
    let l:temp = @k
    normal! gv"sy
    let l:keyword = @k
    let @s = l:temp

    let l:keyword = escape(l:keyword, '/\')
    let l:keyword = substitute(l:keyword, '\n$', '', '')
    let l:keyword = substitute(l:keyword, '\n', '\\n', 'g')
    let l:keyword = '\V' . l:keyword
    call feedkeys(a:key . l:keyword . "\<CR>")
endfunction


" ------------------------------------------------------------------------------
" Indent settings
" ------------------------------------------------------------------------------

set autoindent
set smartindent
set expandtab
set shiftwidth=4
set tabstop=4


" ------------------------------------------------------------------------------
" Other settings
" ------------------------------------------------------------------------------

set whichwrap=h,l,<,>,[,]
set wildmenu
set wildmode=longest:full,full
set matchpairs+=（:）
set spelllang& spelllang+=cjk

set textwidth=0
if has('win32unix')
    augroup textwidth_cygwin_vimscript
        autocmd!
        autocmd FileType vim set textwidth=0
    augroup END
endif

augroup format_options
    autocmd!
    autocmd BufEnter * setlocal formatoptions+=M
    autocmd BufEnter * setlocal formatoptions+=j
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

" Display latest update time of the current file by <C-G>.
nnoremap <C-G> :<C-U>call <SID>display_file_info()<CR>

function! s:display_file_info()
    let l:filename =  expand('%:p:~')
    if l:filename == ''
        let l:filename = '[No Name]'
    endif

    let l:update_time = getftime(expand('%'))
    if l:update_time >= 0
        let l:update_time = strftime(" (%y/%m/%d %H:%M:%S)", l:update_time)
        echomsg ' ' . l:filename . l:update_time
    else
        echomsg ' ' . l:filename
    endif
endfunction


" ":DisplayMode" switches "set number" and "set cursorline" respectively.
command! DisplayMode call s:switch_display_mode()

function! s:switch_display_mode()
    let l:cur_tab = tabpagenr()
    let l:cur_win = winnr()

    let l:terminal = '^term://'
    if &cursorline
        setglobal nocursorline
        setglobal nonumber
        setglobal relativenumber
        tabdo windo if expand('%') !~ l:terminal
                \ |     setlocal nocursorline
                \ |     if &number || &relativenumber
                \ |         setlocal nonumber
                \ |         setlocal relativenumber
                \ |     endif
                \ | endif
    else
        setglobal cursorline
        setglobal number
        setglobal norelativenumber
        tabdo windo if expand('%') !~ l:terminal
                \ |     setlocal cursorline
                \ |     if &number || &relativenumber
                \ |         setlocal number
                \ |         setlocal norelativenumber
                \ |     endif
                \ | endif
    endif

    execute 'tabnext ' . l:cur_tab
    execute 'normal! ' . l:cur_win . "\<C-W>w"
endfunction


if has('nvim')
    set inccommand=split
endif


" ------------------------------------------------------------------------------
" Settings for each language
" ------------------------------------------------------------------------------

" Java
let g:java_highlight_all       = 1
let g:java_highlight_functions = 'style'
let g:java_space_error         = 1

" Markdown
augroup markdown
    autocmd!
    autocmd FileType markdown inoremap <buffer> ' '
augroup END

" shell script
augroup shellscript
    autocmd!
    autocmd FileType *sh setlocal tabstop=2
    autocmd FileType *sh setlocal shiftwidth=2
augroup END

" plain text
augroup textfile
    autocmd!
    autocmd FileType text inoremap <buffer> ' '
augroup END

" Tex
augroup texfile
    autocmd!
    autocmd FileType *tex setlocal conceallevel=0
    " Transform markdown to tex.
    autocmd FileType *tex setlocal formatprg=pandoc\ --from=markdown\ --to=latex
augroup END

" Vim script
augroup vimscript
    autocmd!
    autocmd FileType           vim    inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> ' '

    autocmd FileType vim,help nnoremap <buffer> <silent> K :<C-U>help <C-R><C-W><CR>
    autocmd BufRead,BufNewFile *.toml nnoremap <buffer> <silent> K :<C-U>help <C-R><C-W><CR>

    autocmd BufRead,BufNewFile *.toml set filetype=conf
augroup END

" Yacc
augroup yacc
    autocmd!
    autocmd BufRead,BufNewFile *.jay set filetype=yacc
augroup END


" ------------------------------------------------------------------------------
" Local settings
" ------------------------------------------------------------------------------

let s:vimrc_local_post = expand('~/.vimrc_local')
if filereadable(s:vimrc_local_post)
    execute 'source' s:vimrc_local_post
endif

