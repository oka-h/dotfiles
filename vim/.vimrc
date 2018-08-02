" ------------------------------------------------------------------------------
" dotfiles/vim/.vimrc
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

let s:xdg_cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache')
                                            \ : $XDG_CACHE_HOME

function! g:Version_check(...) abort
    if a:0 == 0
        return 1
    endif
    let l:required_version = 0
    let l:required_patch = 1
    for l:arg in a:000
        if type(l:arg) == type(0)
            if l:required_version <= 0
                let l:required_version = l:arg
            else
                let l:required_patch = l:required_patch && has('patch' . l:arg)
            endif
        elseif type(l:arg) == type('')
            if has('nvim')
                return stridx(l:arg, 'n') >= 0
            elseif stridx(l:arg, 'v') < 0
                return 0
            endif
        endif
        unlet l:arg
    endfor
    return v:version + l:required_patch > l:required_version || has('nvim')
endfunction

command! -nargs=1 NXmap      nmap     <args>| xmap     <args>
command! -nargs=1 NXnoremap  nnoremap <args>| xnoremap <args>
command! -nargs=1 XOmap      xmap     <args>| omap     <args>
command! -nargs=1 XOnoremap  xnoremap <args>| onoremap <args>
command! -nargs=1 NXOmap     nmap     <args>| xmap     <args>| omap     <args>
command! -nargs=1 NXOnoremap nnoremap <args>| xnoremap <args>| onoremap <args>

let g:is_filetype_enable_of = {
\   'c'          : 0,
\   'cpp'        : 0,
\   'go'         : 0,
\   'html'       : 0,
\   'java'       : 0,
\   'processing' : 0,
\   'python'     : 0
\}

let g:disable_plugins = []

let g:is_my_layout = 0

if filereadable(s:vimrc_local_pre)
    execute 'source' s:vimrc_local_pre
endif


" ------------------------------------------------------------------------------
" Dein.vim settings
" ------------------------------------------------------------------------------

let g:plugins_dir = s:xdg_cache_home . expand('/dein')
let s:dein_dir = g:plugins_dir . expand('/repos/github.com/Shougo/dein.vim')
let g:dotfiles_vim_dir = fnamemodify(s:vimrc, ':h')
let s:toml = g:dotfiles_vim_dir . expand('/dein.toml')

if !isdirectory(g:plugins_dir . expand('/repos/github.com/vim-ja/vimdoc-ja'))
    let g:dein#install_process_timeout = 300
endif

function! s:install_dein() abort
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    if !g:Version_check(800)
        let l:cwd = getcwd()
        execute 'cd' s:dein_dir
        execute '!git checkout 1.5'
        execute 'cd' l:cwd
    endif
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
        call dein#begin(g:plugins_dir, l:vimrcs)
        call dein#load_toml(s:toml)

        let l:local_toml = expand('~/.dein_local.toml')
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
endfunction

if g:Version_check(704)
    if isdirectory(s:dein_dir)
        call s:load_dein()
    else
        command! DeinInstall call s:install_dein()
        augroup nodein_call
            autocmd!
            autocmd VimEnter * echomsg 'Dein.vim is not installed. Please install it by :DeinIntall.'
        augroup END
    endif
endif

function! g:Is_plugin_enable(plugin_name) abort
    return exists('*g:dein#get') ? !empty(g:dein#get(a:plugin_name)) : 0
endfunction


" ------------------------------------------------------------------------------
" Options
" ------------------------------------------------------------------------------

filetype plugin indent on
set autoread
set backspace=indent,eol,start
set completeopt-=preview
set history=10000
set helplang=ja
set noundofile
set spelllang&
set spelllang+=cjk
set splitbelow
set splitright
set whichwrap=h,l,<,>,[,]
set wildmenu
set wildmode=longest:full,full

" Dirctory for backup/swap file.
let s:temp_dir = s:xdg_cache_home . expand('/vim')
if !isdirectory(s:temp_dir)
    call mkdir(s:temp_dir, 'p')
endif

set backup
execute 'set backupdir=' . s:temp_dir

set swapfile
execute 'set directory=' . s:temp_dir

if exists('+clipboard')
    set clipboard-=autoselect
endif

" Don't beep.
if exists('+belloff')
    set belloff=all
else
    set visualbell t_vb=
endif

augroup format_options
    autocmd!
    autocmd BufEnter * setlocal formatoptions+=M
                              \ formatoptions-=r
                              \ formatoptions-=o
    if g:Version_check(704, 541)
        autocmd BufEnter * setlocal formatoptions+=j
    endif
augroup END

let s:dict = expand('/usr/share/dict/words')
if filereadable(s:dict)
    execute 'set dictionary=' . s:dict
endif

set textwidth=0
if has('win32unix')
    augroup textwidth_cygwin_vimscript
        autocmd!
        autocmd FileType vim set textwidth=0
    augroup END
endif

if exists('+inccommand')
    set inccommand=split
endif

if exists('+scrollback')
    set scrollback=-1
elseif exists(':terminal') == 2
    let g:terminal_scrollback_buffer_size = 100000
endif


" ------------------------------------------------------------------------------
" Keymap settings
" ------------------------------------------------------------------------------

NXOnoremap <BS>    <Nop>
NXOnoremap <Space> <Nop>

NXOnoremap ; :
NXOnoremap : ;
NXnoremap q; q:

NXOnoremap j gj
NXOnoremap gj j
NXOnoremap k gk
NXOnoremap gk k

NXOnoremap m y

NXnoremap <Space>m "+y
NXnoremap <Space>p "+p
NXnoremap <Space>P "+P

NXnoremap <Space>c "_c
NXnoremap <Space>C "_C
NXnoremap <Space>d "_d
NXnoremap <Space>D "_D
NXnoremap <Space>s "_s
NXnoremap <Space>S "_S
NXnoremap <Space>x "_x
NXnoremap <Space>X "_X

NXOnoremap <Space>f f<C-K>
NXOnoremap <Space>F F<C-K>

NXnoremap <C-W>t     <C-W>T
NXnoremap <C-W><C-T> <C-W>T

if g:is_my_layout
    NXnoremap <C-W>Y :<C-U>quit!<CR>
else
    NXnoremap <C-W>Q :<C-U>quit!<CR>
endif

nnoremap <Esc><Esc> :<C-U>nohlsearch<CR>

" Go to optional tab page.
for s:i in range(10)
    execute 'nnoremap <silent> <Space>' . s:i . ' :<C-U>call <SID>go_to_tab(' . s:i . ')<CR>'
endfor

function! s:go_to_tab(num) abort
    let l:tabnum = a:num
    let l:lasttab = tabpagenr('$')
    if l:tabnum > l:lasttab || l:tabnum == 0
        let l:tabnum = l:lasttab
    endif
    execute 'tabnext' l:tabnum
endfunction


if exists(':terminal') == 2
    nmap <Space>t [terminal]
    nnoremap [terminal] <Nop>
    nmap [terminal]c [cd-term]
    nnoremap [cd-term] <Nop>
    if has('nvim')
        nnoremap <silent> [terminal]<Space> :<C-U>                        terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]t :<C-U>tabedit                   | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]r :<C-U>-tabedit                  | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]j :<C-U>         rightbelow split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]k :<C-U>         leftabove  split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]h :<C-U>vertical leftabove  split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]l :<C-U>vertical rightbelow split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]J :<C-U>         botright   split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]K :<C-U>         topleft    split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]H :<C-U>vertical topleft    split | terminal<CR><C-\><C-N>i
        nnoremap <silent> [terminal]L :<C-U>vertical botright   split | terminal<CR><C-\><C-N>i
        nnoremap <silent> <expr> [cd-term]<Space> ':<C-U>                        terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]t ':<C-U>tabedit                   | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]r ':<C-U>-tabedit                  | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]j ':<C-U>         rightbelow split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]k ':<C-U>         leftabove  split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]h ':<C-U>vertical leftabove  split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]l ':<C-U>vertical rightbelow split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]J ':<C-U>         botright   split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]K ':<C-U>         topleft    split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]H ':<C-U>vertical topleft    split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]L ':<C-U>vertical botright   split | terminal<CR><C-\><C-N>icd ' . expand('%:h:p') . '<CR><C-L>'
    else
        nnoremap <silent> [terminal]<Space> :<C-U>terminal ++curwin<CR>
        nnoremap <silent> [terminal]t :<C-U>tab                 terminal<CR>
        nnoremap <silent> [terminal]r :<C-U>-tab                terminal<CR>
        nnoremap <silent> [terminal]j :<C-U>         rightbelow terminal<CR>
        nnoremap <silent> [terminal]k :<C-U>         leftabove  terminal<CR>
        nnoremap <silent> [terminal]h :<C-U>vertical leftabove  terminal<CR>
        nnoremap <silent> [terminal]l :<C-U>vertical rightbelow terminal<CR>
        nnoremap <silent> [terminal]J :<C-U>         botright   terminal<CR>
        nnoremap <silent> [terminal]K :<C-U>         topleft    terminal<CR>
        nnoremap <silent> [terminal]H :<C-U>vertical topleft    terminal<CR>
        nnoremap <silent> [terminal]L :<C-U>vertical botright   terminal<CR>
        nnoremap <silent> <expr> [cd-term]<Space> ':<C-U>terminal ++curwin     <CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]t ':<C-U>tab                 terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]r ':<C-U>-tab                terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]j ':<C-U>         rightbelow terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]k ':<C-U>         leftabove  terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]h ':<C-U>vertical leftabove  terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]l ':<C-U>vertical rightbelow terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]J ':<C-U>         botright   terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]K ':<C-U>         topleft    terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]H ':<C-U>vertical topleft    terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
        nnoremap <silent> <expr> [cd-term]L ':<C-U>vertical botright   terminal<CR>cd ' . expand('%:h:p') . '<CR><C-L>'
    endif
endif

inoremap <C-B> <Left>
inoremap <C-F> <Right>

inoremap <C-L> <C-X><C-L>
inoremap <C-K> <C-X><C-K>

inoremap <expr> <C-E> pumvisible() ? '<C-Y><C-E>' : '<C-E>'
inoremap <expr> <C-Y> pumvisible() ? '<C-Y><C-Y>' : '<C-Y>'

inoremap {     {}<C-G>U<Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap {}    {}
inoremap {{{   {{{
inoremap (     ()<C-G>U<Left>
inoremap (<CR> (<CR>)<Esc>O
inoremap ()    ()
inoremap [     []<C-G>U<Left>
inoremap [<CR> [<CR>]<Esc>O
inoremap []    []
inoremap "     ""<C-G>U<Left>
inoremap ""    ""
inoremap '     ''<C-G>U<Left>
inoremap ''    ''

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

inoremap <C-Z> <Del>
cnoremap <C-Z> <Del>

snoremap <C-A> <C-O>pa
inoremap <C-A> <C-G>u<C-R>"
cnoremap <C-A> <C-R>"

" Assign <Home> and <End> to "<Space>h" and "<Space>l". This uses "g^", "^" and
" "0" or "g$" and "$" for different purposes in accordance situations.
nnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_head('n')<CR>
xnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_head('x')<CR>
onoremap          <Space>h ^
nnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_tail('n')<CR>
xnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_tail('x')<CR>
onoremap          <Space>l $

function! s:go_to_line_head(mode) abort
    if a:mode == 'x'
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

function! s:go_to_line_tail(mode) abort
    if a:mode == 'x'
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
    if !has('nvim')
        tnoremap <C-W> <C-W>.
    endif
endif

if g:is_my_layout
    NXOmap <BS> <Space>
    NXnoremap { <C-]>
    " } To not break syntax color
    NXnoremap y v
    NXnoremap Y V
    NXnoremap <C-Y> <C-V>
    NXnoremap gy gv
    NXnoremap <C-W>y <C-W>q
    if !g:Is_plugin_enable('incsearch.vim')
        NXnoremap = /
        NXnoremap + ?
    endif
endif

" Solve the problem that Delete key does not work.
if has('unix') && !has('gui_running')
    inoremap  
    cnoremap  
endif


" ------------------------------------------------------------------------------
" Display settings
" ------------------------------------------------------------------------------

set showmode
set relativenumber
set numberwidth=3
set scrolloff=3
set list
set listchars=tab:\ \ ,extends:>
set display=lastline
set showcmd
set lazyredraw
set laststatus=2

set statusline=%!g:My_status_line()

function! g:My_status_line() abort
    let l:pwd = " [%{(getcwd() == $HOME) ? '~/' : '/' . fnamemodify(getcwd(), ':~:t')}] "
    let l:file = '%<%F%m%r%h%w%= '

    let l:format   = "%{&fileformat   == '' ? '' : '| ' . &fileformat   . ' '}"
    let l:encoding = "%{&fileencoding == '' ? '' : '| ' . &fileencoding . ' '}"
    let l:filetype = "%{&filetype     == '' ? '' : '| ' . &filetype     . ' '}"

    let l:col = '| %3v'
    let l:line = ":%{printf('%' . len(line('$')) . 'd', line('.'))} "
    let l:lastline = '/ %L '

    return l:pwd . l:file . l:format . l:encoding . l:filetype . l:col . l:line . l:lastline
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

" In visual mode, search the selected string by "*" or "#".
if g:is_my_layout
    vnoremap <silent> ( :<C-U>call <SID>visual_star_search('/')<CR>
    vnoremap <silent> ) :<C-U>call <SID>visual_star_search('?')<CR>
else
    vnoremap <silent> * :<C-U>call <SID>visual_star_search('/')<CR>
    vnoremap <silent> # :<C-U>call <SID>visual_star_search('?')<CR>
endif

function! s:visual_star_search(key) abort
    let l:count = v:count1

    let l:register = '"'
    let l:save_reg_str  = getreg(l:register, 1, 1)
    let l:save_reg_type = getregtype(l:register)
    execute 'normal! gv"' . l:register . 'y'
    let l:search_word = getreg(l:register)
    call setreg(l:register, l:save_reg_str, l:save_reg_type)

    let l:search_word = escape(l:search_word, '\' . a:key)
    let l:search_word = substitute(l:search_word, '\n$', '', '')
    let l:search_word = substitute(l:search_word, '\n', '\\n', 'g')
    let l:search_word = '\V' . l:search_word

    call feedkeys(l:count . a:key . l:search_word . "\<CR>")
endfunction


" ------------------------------------------------------------------------------
" Indent settings
" ------------------------------------------------------------------------------

set autoindent
set smartindent
set expandtab
set shiftwidth=4
set tabstop=4

if exists('+breakindent')
    set breakindent
endif


" ------------------------------------------------------------------------------
" My commands
" ------------------------------------------------------------------------------

" :RemoveTailSpaces
command! RemoveTailSpaces %s/ \+$//

" :W
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


" :Redir
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


" :DisplayMode
" Switch "set number" and "set cursorline" respectively.
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


" ------------------------------------------------------------------------------
" Other settings
" ------------------------------------------------------------------------------

if executable('/usr/bin/python')
    let g:python_host_prog = '/usr/bin/python'
endif

if executable('/usr/bin/python3')
    let g:python3_host_prog = '/usr/bin/python3'
endif

if exists(':terminal') == 2 && has('clientserver') && v:servername == ''
    call remote_startserver('vim-server' . getpid())
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


" ------------------------------------------------------------------------------
" Settings for each language
" ------------------------------------------------------------------------------

augroup each_language
    autocmd!
    " java
    let g:java_highlight_all       = 1
    let g:java_highlight_functions = 'style'
    let g:java_space_error         = 1

    " terminal
    if exists('##TerminalOpen')
        autocmd TerminalOpen * setlocal norelativenumber
    elseif exists('##TermOpen') && exists('##TermClose')
        autocmd TermOpen  * setlocal norelativenumber
        autocmd TermClose * setlocal relativenumber
    endif

    " markdown
    autocmd FileType markdown inoremap <buffer> <nowait> ' '

    " neosnippet
    autocmd FileType neosnippet setlocal noexpandtab

    " plain text
    autocmd FileType text inoremap <buffer> <nowait> ' '

    " python
    autocmd FileType python setlocal textwidth=79

    " shell script
    autocmd FileType *sh setlocal tabstop=2
    autocmd FileType *sh setlocal shiftwidth=2
    autocmd BufRead,BufNewFile *shellrc* set filetype=sh

    " tex
    autocmd FileType *tex setlocal conceallevel=0
    " Transform markdown to tex.
    if executable('pandoc')
        autocmd FileType *tex setlocal formatprg=pandoc\ --from=markdown\ --to=latex
    endif

    " vim script
    autocmd BufRead,BufNewFile *.toml set filetype=conf
    autocmd FileType vim,help         nnoremap <buffer> <silent> K :<C-U>help <C-R><C-W><CR>
    autocmd BufRead,BufNewFile *.toml nnoremap <buffer> <silent> K :<C-U>help <C-R><C-W><CR>
    autocmd FileType vim              inoremap <buffer> <nowait> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <nowait> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> '''<CR>  '''<CR>'''<Esc>O<Tab>

    autocmd FileType vim              inoremap <buffer> <silent> <expr> (<CR> <SID>vim_continue_line('(')
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <silent> <expr> (<CR> <SID>vim_continue_line('(')
    autocmd FileType vim              inoremap <buffer> <silent> <expr> [<CR> <SID>vim_continue_line('[')
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <silent> <expr> [<CR> <SID>vim_continue_line('[')
    autocmd FileType vim              inoremap <buffer> <silent> <expr> {<CR> <SID>vim_continue_line('{')
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <silent> <expr> {<CR> <SID>vim_continue_line('{')
    autocmd FileType vim              inoremap <buffer> <silent> <expr> ,<CR> <SID>vim_continue_line(',')
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <silent> <expr> ,<CR> <SID>vim_continue_line(',')

    function! s:vim_continue_line(char) abort
        let l:indent = matchstr(getline('.'), '\s*\\\?\s*')
        if match(l:indent,'\') < 0
            let l:indent .= '\'
        endif
        let l:pair_char = a:char == '(' ? ')'
                      \ : a:char == '[' ? ']'
                      \ : a:char == '{' ? '}'
                                      \ : ''
        return a:char . "\<Esc>"
           \ . ":call append(line('.'), '" . l:indent . "')\<CR>"
           \ . (l:pair_char != '' ? ":call append(line('.') + 1, '" . l:indent . l:pair_char . "')\<CR>" : '')
           \ . "jA" . (l:pair_char != '' ? "\<Tab>" : '')
    endfunction


    " yacc
    autocmd BufRead,BufNewFile *.jay set filetype=yacc
augroup END


" ------------------------------------------------------------------------------
" Local settings
" ------------------------------------------------------------------------------

if filereadable(s:vimrc_local_post)
    execute 'source' s:vimrc_local_post
endif
