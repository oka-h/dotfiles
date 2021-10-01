" ------------------------------------------------------------------------------
" dotfiles/vim/.vimrc
" ------------------------------------------------------------------------------

" ------------------------------------------------------------------------------
" Pre-settings
" ------------------------------------------------------------------------------

let g:is_windows = has('win32') || has('win64')

if has('vim_starting') && &encoding !=# 'utf-8'
    if g:is_windows && !has('gui_running')
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

function! Satisfy_version(...) abort
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

let s:enabled_state_of_filetype = {}
function! g:Is_filetype_enabled(filetype) abort
    return get(s:enabled_state_of_filetype, 'all') || get(s:enabled_state_of_filetype, a:filetype)
endfunction

function! g:Enable_filetype(filetype, ...) abort
    let s:enabled_state_of_filetype[a:filetype] = (a:0 == 0 || a:1)
endfunction


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

function! s:install_dein() abort
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir

    if !Satisfy_version(802)
        let l:cwd = getcwd()
        execute 'cd' s:dein_dir

        if !Satisfy_version(800)
            let l:branch = '1.5'
        else
            let l:branch = '2.2'
        endif

        execute '!git checkout' l:branch
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

    call dein#disable(g:disable_plugins)

    if Satisfy_version(802)
        call dein#disable(dein#util#_get_plugins(0)->filter({-> !v:val->get('if', 1)->eval()})->map({-> v:val.repo->matchstr('^[^/]\+/\zs[^/]\+$')}))
    endif

    call dein#call_hook('source')

    if dein#check_install()
        call dein#install()
    endif
endfunction

if Satisfy_version(704)
    if isdirectory(s:dein_dir)
        call s:load_dein()
    else
        command! DeinInstall call s:install_dein()
        augroup vimrc_no_dein_message
            autocmd!
            autocmd VimEnter * echomsg 'Dein.vim is not installed. Please install it by :DeinIntall.'
        augroup END
    endif
endif

function! g:Is_plugin_enable(plugin_name) abort
    return exists('*g:dein#get') && !empty(g:dein#get(a:plugin_name))
endfunction


" ------------------------------------------------------------------------------
" Options
" ------------------------------------------------------------------------------

filetype plugin indent on
set autoread
set backspace=indent,eol,start
set clipboard=unnamed,unnamedplus
set completeopt-=preview
set history=10000
set helplang=ja
set mouse=
set noundofile
set spelllang&
set spelllang+=cjk
set splitbelow
set splitright
set tags=./tags;,./.tags;
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

augroup vimrc_format_options
    autocmd!
    autocmd BufEnter * setlocal formatoptions+=M
                              \ formatoptions-=r
                              \ formatoptions-=o
    if Satisfy_version(704, 541)
        autocmd BufEnter * setlocal formatoptions+=j
    endif
augroup END

let s:dict = expand('/usr/share/dict/words')
if filereadable(s:dict)
    execute 'set dictionary=' . s:dict
endif

set textwidth=0
if has('win32unix')
    augroup vimrc_textwidth_for_vimscript_on_cygwin
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

if g:Is_plugin_enable('jpmoveword.vim')
    XOnoremap e b
    XOnoremap b e
else
    NXOnoremap e b
    NXOnoremap E B
    NXOnoremap b e
    NXOnoremap B E
endif

NXOnoremap m y

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

if !g:Is_plugin_enable('re-window.vim')
    if g:is_my_layout
        NXnoremap <silent> <C-W>ay :<C-U>tabclose<CR>
    else
        NXnoremap <silent> <C-W>aq :<C-U>tabclose<CR>
    endif
endif

let g:hlsearch = 0
nnoremap <silent> <expr> <Space><Space> ':<C-U>' . (g:hlsearch ? 'nohlsearch' : 'set hlsearch')
            \ . ' \| let g:hlsearch = !g:hlsearch<CR>'
xnoremap <silent> <expr> <Space><Space> ':<C-U>' . (g:hlsearch ? 'nohlsearch' : 'set hlsearch')
            \ . ' \| let g:hlsearch = !g:hlsearch<CR>gv'

if exists('##CmdlineEnter')
    augroup vimrc_toggle_hlsearch
        autocmd!
        autocmd CmdlineEnter [/\?] let g:hlsearch = 0
    augroup END
endif


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


let s:term_cmd = {
\   '<Space>' : 'terminal' . (has('nvim') ? '' : ' ++curwin'),
\   't'       : (has('nvim') ? 'tabedit <Bar>' : 'tab') . ' terminal',
\   'r'       : (has('nvim') ? '-tabedit <Bar>' : '-tab') . ' terminal',
\   'k'       : 'leftabove'           . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'j'       : 'rightbelow'          . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'h'       : 'vertical leftabove'  . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'l'       : 'vertical rightbelow' . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'K'       : 'topleft'             . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'J'       : 'botright'            . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'H'       : 'vertical topleft'    . (has('nvim') ? ' split <Bar>' : '') . ' terminal',
\   'L'       : 'vertical botright'   . (has('nvim') ? ' split <Bar>' : '') . ' terminal'
\}

function! g:Define_launching_terminal_key_mappings(shell, prefix_keys, shown_cmd, ...) abort
    if exists(':terminal') != 2
        return
    endif

    if a:0 != 0 && a:0 != 1
        throw 'Invalid Arguments'
    endif

    let l:nohls = (g:Is_plugin_enable('incsearch.vim') || g:Is_plugin_enable('is.vim')) ? 'nohlsearch <Bar> ' : ''
    let l:spaced_shell = empty(a:shell) ? '' : (' ' . a:shell)
    let l:post_keys = has('nvim') ? (l:spaced_shell . '<CR><C-\><C-N>i') : (' ++close' . l:spaced_shell . '<CR>')

    execute 'nmap' a:prefix_keys a:shown_cmd
    execute 'nnoremap' a:shown_cmd '<Nop>'
    for [l:key, l:commands] in items(s:term_cmd)
        execute 'nnoremap <silent>' a:shown_cmd . l:key ':<C-U>' . l:nohls . l:commands . l:post_keys
    endfor

    if a:0 == 1
        let l:cd_shown_cmd = a:1
        execute 'nmap' a:shown_cmd . 'c' l:cd_shown_cmd
        execute 'nnoremap' l:cd_shown_cmd '<Nop>'
        for [l:key, l:commands] in items(s:term_cmd)
            execute 'nnoremap <silent> <expr>' l:cd_shown_cmd . l:key "':<C-U>" . l:nohls . l:commands . l:post_keys
                        \ . "cd ' . expand('%:p:h') . '<CR><C-L>'"
        endfor
    endif
endfunction

call g:Define_launching_terminal_key_mappings((g:is_windows && executable('powershell')) ? 'powershell' : '',
            \ '<Space>t', '[terminal]', '[cd-term]')


" Repeat jump until another file is found.
nnoremap <silent> <Space><C-O> :<C-U>call <SID>jump_next_file('old')<CR>
nnoremap <silent> <Space><C-I> :<C-U>call <SID>jump_next_file('new')<CR>

function! s:jump_next_file(direction) abort
    if a:direction ==? 'old'
        let l:index = 1
        let l:key = "\<C-O>"
    elseif a:direction ==? 'new'
        let l:index = -1
        let l:key = "\<C-I>"
    else
        return
    endif

    let l:distance = split(split(execute('jumps'), '\n')[l:index])[0]
    if l:distance == '>'
        return
    endif
    let l:oldid = winbufnr('.')
    for l:i in range(l:distance)
        call feedkeys(l:key, 'nx')
        if winbufnr('.') != l:oldid
            return
        endif
    endfor
endfunction


inoremap <C-B> <Left>
inoremap <C-F> <Right>

inoremap <C-L> <C-X><C-L>

inoremap <expr> <C-E> pumvisible() ? '<C-Y><C-E>' : '<C-E>'
inoremap <expr> <C-Y> pumvisible() ? '<C-Y><C-Y>' : '<C-Y>'

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

if g:is_my_layout
    cnoremap <C-T> <C-F>
endif

snoremap <C-G> <C-O>pa
inoremap <C-G> <C-G>u<C-R>"
cnoremap <C-G> <C-R>"

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


if exists('+termkey')
    set termkey=<C-E>
endif

if exists(':tnoremap') == 2
    tnoremap <C-O> <C-\><C-N>
    if has('nvim')
        tnoremap <expr> <C-A> '<C-\><C-N>"' . nr2char(getchar()) . 'pi'
    else
        if exists('+termkey')
            tnoremap <C-A> <C-E>"
        else
            tnoremap <C-A> <C-W>"
            tnoremap <C-E> <C-W>
            tnoremap <C-W> <C-W>.
        endif
    endif
endif

if g:is_my_layout
    NXOmap <BS> <Space>
    NXnoremap + <C-]>
    NXnoremap <C-W>y     <C-W>q
    NXnoremap <C-W><C-Y> <C-W>q
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
    let l:delimiter = g:is_windows ? '\' : '/'
    let l:pwd = ' [%{' . (g:is_windows ? "getcwd() == fnamemodify('/', ':p') ? getcwd() : " : '')
                \ . "(getcwd() == $HOME) ? '~" . l:delimiter . "': '"
                \ . l:delimiter . "' . fnamemodify(getcwd(), ':~:t')}] "
    let l:file = '%<%F%m%r%h%w%= '

    let l:format   = "%{empty(&fileformat)   ? '' : '| ' . &fileformat   . ' '}"
    let l:encoding = "%{empty(&fileencoding) ? '' : '| ' . &fileencoding . ' '}"
    let l:filetype = "%{empty(&filetype)     ? '' : '| ' . &filetype     . ' '}"

    let l:col = '| %3v'
    let l:line = ":%{printf('%' . len(line('$')) . 'd', line('.'))} "
    let l:lastline = '/ %L '

    return l:pwd . l:file . l:format . l:encoding . l:filetype . l:col . l:line . l:lastline
endfunction


" ------------------------------------------------------------------------------
" Color settings
" ------------------------------------------------------------------------------

set t_Co=256

augroup vimrc_cursor_line_nr
    autocmd!
    autocmd VimEnter,ColorScheme * highlight CursorLineNr cterm=bold ctermfg=173 gui=bold guifg=#D7875F
augroup END

" Highlight two-byte spaces.
function! s:set_tbs_hl() abort
    highlight two_byte_space cterm=underline ctermfg=red gui=underline guifg=red
endfunction

if has('syntax')
    augroup vimrc_two_byte_space
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

augroup vimrc_hlsearch
    autocmd!
    autocmd VimEnter * set hlsearch
augroup END

" In visual mode, search the selected string by "*" or "#".
if g:is_my_layout
    xnoremap <silent> ( :<C-U>call <SID>visual_star_search('/')<CR>
    xnoremap <silent> ) :<C-U>call <SID>visual_star_search('?')<CR>
else
    xnoremap <silent> * :<C-U>call <SID>visual_star_search('/')<CR>
    xnoremap <silent> # :<C-U>call <SID>visual_star_search('?')<CR>
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
command! RemoveTailSpaces %s/\s\+$//e
                      \ | call histdel('/', -1)


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

    if empty(a:bang)
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

if exists(':terminal') == 2 && has('clientserver') && empty(v:servername)
    call remote_startserver('vim-server' . getpid())
endif

" Display latest update time of the current file by <C-G>.
nnoremap <silent> <C-G> :<C-U>call <SID>display_file_info()<CR>

function! s:display_file_info() abort
    let l:filename =  expand('%:p:~')
    if empty(l:filename)
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


let s:session_file = expand('~/.vimsession')
let s:temp_session_file = expand('~/.vimtempsession')

augroup vimrc_session
    autocmd!
    autocmd CursorHold * if empty(getcmdwintype())
                     \ |     execute 'mksession!' s:temp_session_file
                     \ | endif
    autocmd ExitPre * if !v:dying
                  \ |     call delete(s:temp_session_file)
                  \ | endif

    let s:load_session_file = filereadable(s:session_file) ? s:session_file
                          \ : filereadable(s:temp_session_file) ? s:temp_session_file : ''
    if !empty(s:load_session_file)
        autocmd VimEnter * nested if empty(@%) && s:get_buf_byte() == 0
                              \ |     silent execute 'source' s:load_session_file
                              \ |     call delete(s:load_session_file)
                              \ | endif

        function! s:get_buf_byte() abort
            let l:byte = line2byte(line('$') + 1)
            return l:byte == -1 ? 0 : byte - 1
        endfunction
    endif
augroup END

command! PauseVim execute 'mksession' s:session_file
              \ | try
              \ |     qall
              \ | finally
              \ |     call delete(s:session_file)
              \ | endtry


" ------------------------------------------------------------------------------
" Settings for each language
" ------------------------------------------------------------------------------

augroup vimrc_each_language
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

    " tsv
    autocmd BufRead,BufNewFile *.tsv set filetype=tsv
    autocmd FileType tsv setlocal noexpandtab
    autocmd FileType tsv setlocal tabstop=8

    " vim script
    autocmd BufRead,BufNewFile *.toml set filetype=conf
    autocmd FileType vim,help         setlocal keywordprg=:help
    autocmd BufRead,BufNewFile *.toml setlocal keywordprg=:help
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> '''<CR> '''<CR>'''<Esc>O<Tab>
    autocmd FileType vim              inoremap <buffer> <expr> <CR> <SID>expand_cr()
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <expr> <CR> <SID>expand_cr()

    let s:bracket = {
    \   '{': '}',
    \   '[': ']',
    \   '(': ')'
    \}

    function! s:expand_cr() abort
        let l:col = col('.')

        if l:col <# 2
            return "\<CR>"
        endif

        let l:line = getline('.')
        let l:lhs = l:line[l:col - 2]
        let l:rhs = l:line[l:col - 1]

        if !(has_key(s:bracket, l:lhs) && s:bracket[l:lhs] ==# l:rhs) && l:lhs !=# ','
            return "\<CR>"
        endif

        let l:match = matchlist(l:line, '\(\s*\)\\\?\(\s*\)\?')
        let l:left_indent = l:match[1]
        let l:right_indent = l:match[2]

        if l:lhs ==# ','
            let l:right_indent .= len(l:right_indent) == 0 ? "\<Tab>" : ''
            return "\<CR> \<C-U>\\\<Left> \<C-U>" . l:left_indent . "\<Right>" . l:right_indent
        else
            return "\<CR> \<C-U>\\\<Left> \<C-U>" . l:left_indent . "\<Right>" . l:right_indent
               \ . "\<Esc>O\\\<Left> \<C-U>" . l:left_indent . "\<Right>" . l:right_indent . "\<Tab>"
        endif
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
