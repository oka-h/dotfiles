" ------------------------------------------------------------------------------
" ~/.vimrc
"
" $XDG_CONFIG_HOME/nvim/init.vim
" ------------------------------------------------------------------------------

" ------------------------------------------------------------------------------
" Pre-settings
" ------------------------------------------------------------------------------

" Settings of encoding.
if has('vim_starting') && &encoding !=# 'utf-8'
    if (has('win32') || has('win64')) && !has('gui_running')
        set encoding=cp932
    else
        set encoding=utf-8
    endif
endif

set fileencodings=usc-bom,utf-8,iso-2022-jp-3,euc-jp,cp932


" List of disable plugins.
let g:disable_plugins = []

" Load a local vimrc file if there is it.
let s:vimrc_local = expand('~/.vimrc_local')
if filereadable(s:vimrc_local)
    let g:is_at_start = exists('v:true') ? v:true : 1
    execute 'source' s:vimrc_local
endif

" XDG CACHE HOME.
let s:xdg_cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache')
                                            \ : $XDG_CACHE_HOME


" ------------------------------------------------------------------------------
" Dein.vim settings
" ------------------------------------------------------------------------------

" The directory installed plugins.
let g:dein_dir = s:xdg_cache_home . expand('/dein')

" Dein.vim location.
let s:dein_repo_dir = g:dein_dir . expand('/repos/github.com/Shougo/dein.vim')

" Install dein.vim.
function! s:install_dein()
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    " Check dein.vim, then load plugins and delete the command to install
    " dein.vim.
    if isdirectory(s:dein_repo_dir)
        call s:load_dein()
        delcommand DeinInstall
    endif
endfunction


" Load plugins.
function! s:load_dein()
    " Check runtime path.
    if &runtimepath !~# expand('/dein.vim')
        execute 'set runtimepath^=' . s:dein_repo_dir
    endif

    if dein#load_state(g:dein_dir)
        " TOML files written plugins.
        let s:toml_dir   = expand('~/dotfiles/vim')
        let s:toml       = s:toml_dir . expand('/dein.toml')
        let s:local_toml = expand('~/.dein_local.toml')

        call dein#begin(g:dein_dir, expand('<sfile>'))

        " Load and cache a TOML file.
        call dein#load_toml(s:toml)

        " Load and cache a local TOML file if there is it.
        if filereadable(s:local_toml)
            call dein#load_toml(s:local_toml)
        endif

        " Finish settings.
        call dein#end()
        call dein#save_state()
    endif

    call dein#call_hook('source')

    " Install plugins that are not yet installed, if any.
    if dein#check_install()
        call dein#install()
    endif

    " Disable plugins listed.
    call dein#disable(g:disable_plugins)
    unlet g:disable_plugins
endfunction


if isdirectory(s:dein_repo_dir)
    " Load plugins if dein.vim is installed.
    call s:load_dein()
else
    " Else, make the command to install it.
    command! DeinInstall call s:install_dein()
    augroup nodein_call
        autocmd!
        autocmd VimEnter * echomsg 'Dein.vim is not installed. Please install '
                               \ . 'it by :DeinIntall.'
    augroup END
endif

" ------------------------------------------------------------------------------
" General settings
" ------------------------------------------------------------------------------

" Reload the modified file automatically.
set autoread

" Don't make an undo file.
set noundofile

" Save 10000 previous commands.
set history=10000

" Read Japanese help files.
set helplang=ja

" Use twice the width of ambiguous east asian width class characters.
set ambiwidth=double

" Dirctory for backup/swap file.
let s:temp_dir = s:xdg_cache_home . expand('/vim')
if !exists(s:temp_dir)
    call mkdir(s:temp_dir, 'p')
endif

" Make backup file.
set backup
execute 'set backupdir=' . s:temp_dir

" Make swap file.
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

    " Session file location.
    let s:session_file = expand('~/.vimsession')

    if filereadable(s:session_file)
        " Restore a previous session file when vim starts with no argument.
        autocmd VimEnter * nested if @% == '' && s:get_buf_byte() == 0
                              \ |     execute 'source' s:session_file
                              \ | endif
    endif

    " Save current session file when vim finishes.
    let g:save_session = 0
    autocmd VimLeave * if g:save_session == 0
                   \ |     call delete(s:session_file)
                   \ | else
                   \ |     execute 'mksession!' s:session_file
                   \ | endif
augroup END

function! s:get_buf_byte()
    let l:byte = line2byte(line('$') + 1)
    return l:byte == -1 ? 0 : byte - 1
endfunction


" Set the number of scrollback buffer lines of terminal emulator.
if has('nvim')
    let g:terminal_scrollback_buffer_size = 100000
endif

" ------------------------------------------------------------------------------
" Key map settings
" ------------------------------------------------------------------------------

" Disable movement by <BS> and <Space>.
noremap <BS>    <Nop>
noremap <Space> <Nop>

" Reverse each keys "j" and "gj", "k" and "gk".
noremap j gj
noremap gj j
noremap k gk
noremap gk k

" Reverse ";" and ":".
noremap ; :
noremap : ;
nnoremap q; q:

" Use "+ register.
noremap <Space>y "+y
noremap <Space>p "+p
noremap <Space>P "+P

" Delete without use register.
noremap <Space>d "_d

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
nnoremap <silent> <Space>0 :<C-U>call <SID>go_to_tab(10)<CR>

function! s:go_to_tab(num)
    let l:tabnum = a:num
    let l:lasttab = tabpagenr('$')
    if l:tabnum > l:lasttab
        let l:tabnum = l:lasttab
    endif
    execute 'tabnext ' . l:tabnum
endfunction


" Solve the problem that Delete key does not work.
if has('unix') && !has('gui_running')
    noremap!  
endif

" Release searching highlight by <ESC><ESC>.
nnoremap <ESC><ESC> :<C-U>nohlsearch<CR>

" Complete brackets.
inoremap {     {}<LEFT>
inoremap {<CR> {<CR>}<ESC>O
inoremap {}    {}
inoremap {{{   {{{
inoremap (     ()<LEFT>
inoremap ()    ()
inoremap [     []<LEFT>
inoremap []    []
inoremap "     ""<LEFT>
inoremap ""    ""
inoremap '     ''<LEFT>
inoremap ''    ''

" In insert mode, assign movement to <C-B> and <C-F>.
inoremap <C-B> <LEFT>
inoremap <C-F> <RIGHT>

" In command line mode, assign complementing history to <C-P> and <C-N>.
cnoremap <C-P> <UP>
cnoremap <C-N> <DOWN>

" Assign <Home> and <End> to "<Space>h" and "<Space>l".
" This uses "g^", "^" and "0" or "g$" and "$" for different purposes in
" accordance situations.
" TODO: Make this to be able to use in visual mode.
nnoremap <silent> <Space>h :<C-U>call <SID>go_to_head()<CR>
vnoremap          <Space>h ^
onoremap          <Space>h ^
nnoremap <silent> <Space>l :<C-U>call <SID>go_to_foot()<CR>
vnoremap          <Space>l $
onoremap          <Space>l $

function! s:go_to_head()
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

function! s:go_to_foot()
    let l:bef_col = col('.')
    normal! g$
    let l:aft_col = col('.')
    if l:bef_col == l:aft_col
        normal! $
    endif
endfunction


" In a terminal emulator, change from terminal mode to normal mode by
" <ESC><ESC>.
if has('nvim')
    tnoremap <ESC><ESC> <C-\><C-N>
endif


" ------------------------------------------------------------------------------
" Display settings
" ------------------------------------------------------------------------------

" Display relative line numbers.
set relativenumber
set numberwidth=3

" Set the minimal number of screen lines to keep above and below the cursor.
set scrolloff=3

" Display tabs and lines continue beyond the right of the screen.
set list
set listchars=tab:>-,extends:>

" Display command in the last line of the screen.
set showcmd

" Don't redraw while executing macros, registers and other commands.
set lazyredraw

" Setting of the status line.
set laststatus=2
set statusline=%!g:My_status_line()

function! g:My_status_line()
    let l:pwd = getcwd()
    return ' [' . (l:pwd == $HOME ? '~' : '') . '/'
       \ . fnamemodify(l:pwd, ':~:t') . '] '
       \ . '%<%F%m%r%h%w%= '
       \ . '%{&fileformat!=''''?''| ''.&fileformat.'' '':''''}'
       \ . '%{&fileencoding!=''''?''| ''.&fileencoding.'' '':''''}'
       \ . '%{&filetype!=''''?''| ''.&filetype.'' '':''''}'
       \ . '| %3v:%' . (float2nr(log10(line('$')))+1) . 'l / %L '
endfunction


" ------------------------------------------------------------------------------
" Color settings
" ------------------------------------------------------------------------------

" Set number of colors.
set t_Co=256

" Setting of highlights.
augroup highlights
    autocmd!
    autocmd ColorScheme * call s:define_highlights()
augroup END

function! s:define_highlights()
    " Set the color of front of each line.
    highlight CursorLineNr cterm=bold ctermfg=173 gui=bold guifg=#D7875F

    " Set the color of the cursor line.
    " highlight CursorLine term=underline cterm=underline gui=underline
endfunction


" Highlight two-byte spaces.

" Set the color of two byte spaces.
function! s:set_tbs_hl()
    highlight two_byte_space cterm=underline ctermfg=red gui=underline guifg=red
endfunction

if has('syntax')
    augroup two_byte_space
        autocmd!
        " Associate the color with two byte spaces.
        autocmd VimEnter,WinEnter * match two_byte_space /　/
        autocmd VimEnter,WinEnter * match two_byte_space '\%u3000'
        autocmd ColorScheme       * call s:set_tbs_hl()
    augroup END
    call s:set_tbs_hl()
endif


" Enable syntax highlight.
syntax enable

" Set the colorscheme if no colorscheme is loaded.
if !exists('g:colors_name')
    colorscheme torte
endif


" ------------------------------------------------------------------------------
" Search settings
" ------------------------------------------------------------------------------

" Ignore capital letters when searching.
set ignorecase

" Don't ignore capital letters if the search word contain capital letters.
set smartcase

" Enable incremental search.
set incsearch

" Search wrap around the end of the file.
set wrapscan

" Highlight the search word.
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
    let l:temp = @s
    normal! gv"sy
    let l:search = @s
    let @s = l:temp
    call feedkeys(a:key . '\V' . substitute(substitute(escape(@s, '/\'),
                                \ '\n$', '', ''), '\n', '\\n', 'g') . "\<CR>")
endfunction


" ------------------------------------------------------------------------------
" Indent settings
" ------------------------------------------------------------------------------

" Enable automatic indentation.
set autoindent

" Enable smart automatic indentation.
set smartindent

" Replace tab characters with spaces.
set expandtab

" Set width of tab characters at beginning of lines.
set shiftwidth=4

" Set width of tab characters except for beginning of lines.
set tabstop=4


" ------------------------------------------------------------------------------
" Other settings
" ------------------------------------------------------------------------------

" Disable automatic line break.
set textwidth=0
if has('win32unix')
    augroup textwidth_cygwin_vimscript
        autocmd!
        autocmd FileType vim set textwidth=0
    augroup END
endif

" Enable movement over lines.
set whichwrap=h,l,<,>,[,]

" Set complementary settings in command line mode.
set wildmenu
set wildmode=longest:full,full

" Make replacements easier to recognize.
if has('nvim')
    set inccommand=split
endif

" Ignore Japanese when check spelling
set spelllang& spelllang+=cjk

" Disable completing comment.
augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

" Display the last modification of the current file by <C-G>.
nnoremap <silent> <C-G> :<C-U>call <SID>display_file_info()<CR>

function! s:display_file_info()
    let l:info = ' ' . expand('%:p:~')
    let l:time = getftime(expand('%'))
    if l:time >= 0
        let l:info .= strftime(" (%y/%m/%d %H:%M:%S)", l:time)
    endif
    echomsg l:info
endfunction


" Make a command to set number and set cursorline.
command! DisplayMode call s:switch_display_mode()

function! s:switch_display_mode()
    let l:cur_tab = tabpagenr()
    let l:cur_win = winnr()

    if &cursorline
        setglobal nocursorline
        setglobal nonumber
        setglobal relativenumber
        tabdo windo if expand('%') !~ '^term://'
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
        tabdo windo if expand('%') !~ '^term://'
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


" ------------------------------------------------------------------------------
" Settings for each language
" ------------------------------------------------------------------------------

" Java
" Enable syntax highlight.
let g:java_highlight_all       = 1
let g:java_highlight_functions = 'style'
let g:java_space_error         = 1

" markdown
augroup markdown
    autocmd!
    " Disable completing ''.
    autocmd FileType markdown inoremap <buffer> ' '
augroup END

" shell script
augroup shellscript
    autocmd!
    " Setting of tab width.
    autocmd FileType *sh setlocal tabstop=2
    autocmd FileType *sh setlocal shiftwidth=2
augroup END

" text
augroup textfile
    autocmd!
    " Disable completing ''.
    autocmd FileType text inoremap <buffer> ' '
augroup END

" Tex
augroup texfile
    autocmd!
    " Display text normally.
    autocmd FileType *tex setlocal conceallevel=0
    " Transform markdown to tex.
    autocmd FileType *tex setlocal formatprg=pandoc\ --from=markdown\ --to=latex
augroup END

" vim script
augroup vimscript
    " Disable completing "" and ''.
    autocmd!
    autocmd FileType           vim    inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> ' '

    " Call help about the word under the cursor.
    autocmd FileType vim,help nnoremap <buffer> K :<C-U>help <C-R><C-W><CR>
    autocmd BufRead,BufNewFile *.toml
                            \ nnoremap <buffer> K :<C-U>help <C-R><C-W><CR>

    " Setting of filetype for toml file.
    autocmd BufRead,BufNewFile *.toml set filetype=conf
augroup END


" ------------------------------------------------------------------------------
" Local settings
" ------------------------------------------------------------------------------

" Load a local vimrc file if there is it.
if filereadable(s:vimrc_local)
    let g:is_at_start = exists('v:false') ? v:false : 0
    execute 'source' s:vimrc_local
    unlet g:is_at_start
endif

