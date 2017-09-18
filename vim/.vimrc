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


let s:vimrc = resolve(expand('<sfile>:p'))
let s:vimrc_local_pre  = expand('~/.vimrc_local_pre')
let s:vimrc_local_post = expand('~/.vimrc_local')

let g:disable_plugins = []

if filereadable(s:vimrc_local_pre)
    execute 'source' s:vimrc_local_pre
endif

let s:xdg_cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache')
                                            \ : $XDG_CACHE_HOME


" ------------------------------------------------------------------------------
" Dein.vim settings
" ------------------------------------------------------------------------------

" The directory installed plugins.
let g:plugins_dir = s:xdg_cache_home . expand('/dein')

" Dein.vim location.
let s:dein_dir = g:plugins_dir . expand('/repos/github.com/Shougo/dein.vim')

" dein.toml location.
let s:toml = fnamemodify(s:vimrc, ':h') . expand('/dein.toml')

function! s:install_dein() abort
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    if isdirectory(s:dein_dir)
        call s:load_dein()
        delcommand DeinInstall
    endif
endfunction

function! s:load_dein() abort
    if &runtimepath !~# s:dein_dir
        execute 'set runtimepath^=' . s:dein_dir
    endif

    if dein#load_state(g:plugins_dir)
        let l:vimrcs = [s:vimrc, s:vimrc_local_pre, s:vimrc_local_post]
        let l:local_toml = expand('~/.dein_local.toml')

        call dein#begin(g:plugins_dir, l:vimrcs)
        call dein#load_toml(s:toml)

        if filereadable(l:local_toml)
            call dein#load_toml(l:local_toml)
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

if isdirectory(s:dein_dir)
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
if exists('+belloff')
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

function! s:get_buf_byte() abort
    let l:byte = line2byte(line('$') + 1)
    return l:byte == -1 ? 0 : byte - 1
endfunction


if exists('+scrollback')
    set scrollback=-1
elseif exists(':terminal') == 2
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
    inoremap  
    cnoremap  
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

function! s:go_to_tab(num) abort
    let l:tabnum = a:num
    let l:lasttab = tabpagenr('$')
    if l:tabnum > l:lasttab || l:tabnum == 0
        let l:tabnum = l:lasttab
    endif
    execute 'tabnext' l:tabnum
endfunction


nnoremap <C-W>aq         :<C-U>tabclose<CR>
nnoremap <C-W><C-A>q     :<C-U>tabclose<CR>
nnoremap <C-W><C-A><C-Q> :<C-U>tabclose<CR>
nnoremap <C-W>t     <C-W>T
nnoremap <C-W><C-T> <C-W>T

nnoremap <Esc><Esc> :<C-U>nohlsearch<CR>

inoremap <C-B> <Left>
inoremap <C-F> <Right>

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

inoremap <C-L> <Del>
cnoremap <C-L> <Del>

inoremap <C-S> <C-G>u<C-R>"
cnoremap <C-S> <C-R>"

" Assign <Home> and <End> to "<Space>h" and "<Space>l". This uses "g^", "^" and
" "0" or "g$" and "$" for different purposes in accordance situations.
nnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_head('n')<CR>
vnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_head('v')<CR>
onoremap          <Space>h ^
nnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_end('n')<CR>
vnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_end('v')<CR>
onoremap          <Space>l $

function! s:go_to_line_head(mode) abort
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

function! s:go_to_line_end(mode) abort
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


if exists(':tnoremap') == 2
    tnoremap <Esc><Esc> <C-\><C-N>
endif


" ------------------------------------------------------------------------------
" Display settings
" ------------------------------------------------------------------------------

set relativenumber
set numberwidth=3
set scrolloff=3
set list
set listchars=tab:\ \ ,extends:>
set showcmd
set lazyredraw
set laststatus=2

set statusline=%!g:My_status_line()

function! g:My_status_line() abort
    let l:pwd  = ' [%{(getcwd()==$HOME)?''~/'':''/''.fnamemodify(getcwd(),'':~:t'')}] '
    let l:file = '%<%F%m%r%h%w%= '

    let l:format   = '%{&fileformat==''''?'''':''| ''.&fileformat.'' ''}'
    let l:encoding = '%{&fileencoding==''''?'''':''| ''.&fileencoding.'' ''}'
    let l:filetype = '%{&filetype==''''?'''':''| ''.&filetype.'' ''}'

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

augroup cursor_line_nr
    autocmd!
    autocmd ColorScheme * highlight CursorLineNr cterm=bold ctermfg=173 gui=bold guifg=#D7875F
augroup END

" Highlight two-byte spaces.
function! s:set_tbs_hl() abort
    highlight two_byte_space cterm=underline ctermfg=red gui=underline guifg=red
endfunction

if has('syntax')
    augroup two_byte_space
        autocmd!
        autocmd ColorScheme * call <SID>set_tbs_hl()
        autocmd VimEnter,WinEnter * match two_byte_space /　/
        autocmd VimEnter,WinEnter * match two_byte_space '\%u3000'
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
    autocmd WinLeave * let b:last_pattern = @/
    autocmd WinEnter * let @/ = get(b:, 'last_pattern', @/)
augroup END

" In visual mode, search the selected string by "*" or "#".
xnoremap * :<C-U>call <SID>visual_star_search('/')<CR>
xnoremap # :<C-U>call <SID>visual_star_search('?')<CR>

function! s:visual_star_search(key) abort
    let l:reg_str  = getreg('"', 1, 1)
    let l:reg_type = getregtype('"')
    normal! gvy
    let l:keyword = getreg('"')
    call setreg('"', l:reg_str, l:reg_type)

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

if has('linebreak')
    set breakindent
endif


" ------------------------------------------------------------------------------
" Other settings
" ------------------------------------------------------------------------------

set splitbelow
set splitright
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
                              \ formatoptions+=j
                              \ formatoptions-=r
                              \ formatoptions-=o
augroup END

if exists('+inccommand')
    set inccommand=split
endif

" Display latest update time of the current file by <C-G>.
nnoremap <C-G> :<C-U>call <SID>display_file_info()<CR>

function! s:display_file_info() abort
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

function! s:switch_display_mode() abort
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

    execute 'tabnext' l:cur_tab
    execute 'normal!' l:cur_win . "\<C-W>w"
endfunction


" If Repository that is contained vimrc has been updated, tell about it.
function! g:Check_vimrc_repos_updated(channel, git_msg) abort
    let l:remote_repos_id = split(a:git_msg)[0]
    if l:remote_repos_id != s:local_repos_id
        let l:msg = 'Repository of "' . fnamemodify(s:vimrc_git_dir, ':~') . '" has been updated.'
        if v:vim_did_enter
            echomsg l:msg
        else
            autocmd vimrc_repos_updated VimEnter * echomsg l:msg
        endif
    endif
endfunction

if has('job')
    let s:vimrc_git_dir = expand('<sfile>:p')
    let s:vimrc_git_dir = resolve(s:vimrc_git_dir)
    let s:vimrc_git_dir = fnamemodify(s:vimrc_git_dir, ':h:h')

    let s:local_repos_id = system('git -C ' . s:vimrc_git_dir . ' log -1 origin | grep commit')
    let s:local_repos_id = split(s:local_repos_id)[1]

    let s:command = 'git -C ' . s:vimrc_git_dir . ' ls-remote origin HEAD | grep HEAD'
    let s:job_option = {
    \   'out_cb' : 'Check_vimrc_repos_updated'
    \}
    call job_start(s:command, s:job_option)
endif


" Write by sudo.
if executable('sudo')
    command! -nargs=? -complete=file_in_path W call <SID>sudo_write(<f-args>)
endif

function! s:sudo_write(...) abort
    if a:0 <= 0
        let l:file = '%'
    else
        let l:file = expand(a:1)
    endif
    execute 'write !sudo tee' l:file '> /dev/null'
endfunction


" View Ex command output on file.
command! -nargs=+ -complete=command -bang Redir call <SID>redir_output(<q-bang>, <f-args>)

function! s:redir_output(bang, ...) abort
    let l:temp_file_name = tempname()

    execute 'redir >' l:temp_file_name
    silent execute join(a:000)
    redir END

    if a:bang == ''
        let l:win_id = win_getid()
        if winheight(l:win_id) * 5 >= winwidth(l:win_id) * 2
            let l:ex_cmd = 'split'
        else
            let l:ex_cmd = 'vsplit'
        endif
    else
        let l:ex_cmd = 'tabedit'
    endif
    execute l:ex_cmd l:temp_file_name
endfunction


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
    autocmd FileType markdown inoremap <buffer> <nowait> ' '
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
    autocmd FileType text inoremap <buffer> <nowait> ' '
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
    autocmd BufRead,BufNewFile *.toml set filetype=conf

    autocmd FileType vim              inoremap <buffer> <nowait> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <nowait> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <nowait> ''' '''

    autocmd FileType vim              inoremap <buffer> [<CR> [<CR>\]<ESC>O\<Tab>
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> [<CR> [<CR>\]<ESC>O\<Tab>
    autocmd FileType vim              inoremap <buffer> {<CR> {<CR><C-D>\}<ESC>O\<Tab>
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> {<CR> {<CR><C-D>\}<ESC>O\<Tab>

    autocmd FileType vim,help         nnoremap <buffer> <silent> K :<C-U>help <C-R><C-W><CR>
    autocmd BufRead,BufNewFile *.toml nnoremap <buffer> <silent> K :<C-U>help <C-R><C-W><CR>
augroup END

" Yacc
augroup yacc
    autocmd!
    autocmd BufRead,BufNewFile *.jay set filetype=yacc
augroup END


" ------------------------------------------------------------------------------
" Local settings
" ------------------------------------------------------------------------------

if filereadable(s:vimrc_local_post)
    execute 'source' s:vimrc_local_post
endif

