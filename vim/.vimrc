" {{{ Pre-settings
let g:is_windows = has('win32') || has('win64')

if has('vim_starting')
    let s:encoding = (g:is_windows && !has('gui_running')) ? 'cp932' : 'utf-8'

    if &encoding !=# s:encoding
        let &encoding = s:encoding
    endif
endif

set fileencodings=usc-bom,utf-8,iso-2022-jp-3,euc-jp,cp932

let s:vimrc = resolve(expand('<sfile>:p'))
let s:vimrc_local_pre = expand(printf('~/%svimrc_local_pre', g:is_windows ? '_' : '.'))
let s:vimrc_local_post = expand(printf('~/%svimrc_local', g:is_windows ? '_' : '.'))

let s:xdg_cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME

command! -nargs=1 NXmap      nmap     <args>| xmap     <args>
command! -nargs=1 NXnoremap  nnoremap <args>| xnoremap <args>
command! -nargs=1 XOmap      xmap     <args>| omap     <args>
command! -nargs=1 XOnoremap  xnoremap <args>| onoremap <args>
command! -nargs=1 NXOmap     nmap     <args>| xmap     <args>| omap     <args>
command! -nargs=1 NXOnoremap nnoremap <args>| xnoremap <args>| onoremap <args>

function! g:Satisfy_vim_version(version, ...) abort
    if has('nvim')
        return 0
    endif

    if a:version != v:version
        return a:version < v:version
    endif

    for l:patch in a:000
        if !has('patch' . l:patch)
            return 0
        endif
    endfor

    return 1
endfunction

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
" }}}

" {{{ Dein.vim setting
let g:plugins_dir = s:xdg_cache_home . expand('/dein')
let s:dein_dir = g:plugins_dir . expand('/repos/github.com/Shougo/dein.vim')
let g:dotfiles_vim_dir = fnamemodify(s:vimrc, ':h')
let s:toml = g:dotfiles_vim_dir . expand('/dein.toml')
let s:local_toml = expand(printf('~/%sdein_local.toml', g:is_windows ? '_' : '.'))

function! s:install_dein() abort
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir

    if !(g:Satisfy_vim_version(802) || has('nvim'))
        let l:cwd = getcwd()
        execute 'cd' s:dein_dir

        if !g:Satisfy_vim_version(800)
            let l:branch = '1.5'
        else
            let l:branch = '2.2'
        endif

        execute '!git checkout' l:branch
        execute 'cd' l:cwd
    endif

    if isdirectory(s:dein_dir)
        call s:load_dein()
        delcommand InstallDein
    endif
endfunction

function! s:load_dein() abort
    if &runtimepath !~# s:dein_dir
        execute 'set runtimepath^=' . s:dein_dir
    endif

    if dein#load_state(g:plugins_dir)
        let l:vimrcs = [s:vimrc, s:vimrc_local_pre, s:vimrc_local_post, s:toml]
        let l:plugins = get(dein#toml#parse_file(s:toml), 'plugins', [])

        if filereadable(s:local_toml)
            call add(l:vimrcs, s:local_toml)
            let l:plugins += get(dein#toml#parse_file(s:local_toml), 'plugins', [])
        endif

        call dein#begin(g:plugins_dir, l:vimrcs)

        for l:plugin in s:get_useful_plugins(l:plugins)
            call dein#add(l:plugin['repo'], l:plugin)
        endfor

        call dein#end()
        call dein#save_state()
    endif

    call dein#call_hook('source')

    augroup vimrc_hook_post_source
        autocmd!
        autocmd VimEnter * call dein#call_hook('post_source')
    augroup END

    if dein#check_install()
        call dein#install()
    endif
endfunction

function! s:get_useful_plugins(plugins) abort
    let l:plugin_dict = {}

    for l:plugin in a:plugins
        let l:plugin_dict[matchstr(l:plugin['repo'], '/\zs[^/]\+$')] = { 'plugin' : l:plugin }
    endfor

    for l:disable_plugin_name in g:disable_plugins
        let l:plugin_dict[l:disable_plugin_name]['useful'] = 0
    endfor

    return map(filter(keys(l:plugin_dict), 's:is_plugin_useful(v:val, l:plugin_dict)'), "l:plugin_dict[v:val]['plugin']")
endfunction

function! s:is_plugin_useful(name, plugin_dict) abort
    let l:plugin_item = a:plugin_dict[a:name]

    if has_key(l:plugin_item, 'useful')
        return l:plugin_item['useful']
    endif

    let l:plugin_item['useful'] = 1

    if !eval(get(l:plugin_item['plugin'], 'if', 1))
        let l:plugin_item['useful'] = 0
        return 0
    endif

    let l:depends_plugin_names = get(l:plugin_item['plugin'], 'depends', [])

    if type(l:depends_plugin_names) != type([])
        let l:depends_plugin_names = [l:depends_plugin_names]
    endif

    for l:depends_plugin_name in l:depends_plugin_names
        if !s:is_plugin_useful(l:depends_plugin_name, a:plugin_dict)
            let l:plugin_item['useful'] = 0
            return 0
        endif
    endfor

    return 1
endfunction

if g:Satisfy_vim_version(704) || has('nvim')
    if isdirectory(s:dein_dir)
        call s:load_dein()
    else
        command! InstallDein call s:install_dein()
    endif
endif

function! g:Is_plugin_enable(plugin_name) abort
    return exists('*g:dein#get') && !empty(g:dein#get(a:plugin_name))
endfunction
" }}}

" {{{ Set options
filetype plugin indent on
syntax enable

set autoread
set backspace=indent,eol,start
set completeopt-=preview
set foldlevelstart=99
set foldmethod=marker
set helplang=ja
set history=10000
set mouse=
set noundofile
set spelllang&
set spelllang+=cjk
set splitbelow
set splitright
set switchbuf=usetab
set tags=./tags;,./.tags;
set whichwrap=h,l,<,>,[,]
set wildmenu
set wildmode=longest:full,full

let s:temp_dir = s:xdg_cache_home . expand('/vim')

if !isdirectory(s:temp_dir)
    call mkdir(s:temp_dir, 'p')
endif

set backup
let &backupdir = s:temp_dir

set swapfile
let &directory = s:temp_dir

set undofile
let &undodir = s:temp_dir

if exists('+clipboard')
    set clipboard=unnamed,unnamedplus
endif

if exists('+belloff')
    set belloff=all
else
    set visualbell
    set t_vb=
endif

augroup vimrc_formatoptions
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
                              \ formatoptions-=o
                              \ formatoptions+=M

    if g:Satisfy_vim_version(704, 541) || has('nvim')
        autocmd BufEnter * setlocal formatoptions+=j
    endif
augroup END

augroup vimrc_cursorline
    autocmd!
    autocmd WinEnter * set cursorline
    autocmd WinLeave * set nocursorline
augroup END

let s:dict = expand('/usr/share/dict/words')

if filereadable(s:dict)
    let &dictionary = s:dict
endif

set textwidth=0

if has('win32unix')
    augroup vimrc_textwidth_for_cygwin
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
" }}}

" {{{ Keymaps
NXOnoremap <Space> <Nop>
nnoremap <Space><Space> :<C-U>set hlsearch<CR>

if g:is_my_layout
    NXOmap <BS> <Space>
else
    NXOnoremap <BS> <Nop>
endif

NXOnoremap ; :
NXOnoremap : ;
NXnoremap q; q:

XOnoremap e b
XOnoremap b e

if !g:Is_plugin_enable('jpmoveword.vim')
    nnoremap e b
    nnoremap b e
    NXOnoremap E B
    NXOnoremap B E
endif

NXOnoremap <Space>f f<C-K>
NXOnoremap <Space>F F<C-K>

NXOnoremap m y

NXnoremap <Space>c "_c
NXnoremap <Space>C "_C
NXnoremap <Space>d "_d
NXnoremap <Space>D "_D
NXnoremap <Space>s "_s
NXnoremap <Space>S "_S
NXnoremap <Space>x "_x
NXnoremap <Space>X "_X

NXnoremap <C-W>t     <C-W>T
NXnoremap <C-W><C-T> <C-W>T

if g:is_my_layout
    NXnoremap <C-W>y <C-W>q
    NXnoremap <C-W><C-Y> <C-W>q
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

if g:is_my_layout
    nnoremap ( *
    nnoremap ) #
endif

NXnoremap + <C-]>

nnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_edge('n', ['g^', '^', '0'])<CR>
xnoremap <silent> <Space>h :<C-U>call <SID>go_to_line_edge('x', ['g^', '^', '0'])<CR>
onoremap          <Space>h ^
nnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_edge('n', ['g$', '$'])<CR>
xnoremap <silent> <Space>l :<C-U>call <SID>go_to_line_edge('x', ['g$', '$'])<CR>
onoremap          <Space>l $

function! s:go_to_line_edge(mode, keys) abort
    let l:initial_col = col('.')

    if a:mode == 'x'
        normal! gv
    endif

    for l:key in a:keys
        execute 'normal!' l:key

        if col('.') != l:initial_col
            return
        endif
    endfor
endfunction

for s:i in range(10)
    execute printf('nnoremap <silent> <Space>%s :<C-U>call <SID>go_to_tab(%s)<CR>', s:i, s:i)
endfor

function! s:go_to_tab(num) abort
    let l:tabnum = a:num
    let l:lasttab = tabpagenr('$')

    if l:tabnum > l:lasttab || l:tabnum == 0
        let l:tabnum = l:lasttab
    endif

    execute 'tabnext' l:tabnum
endfunction

nnoremap <silent> <Space><C-O> :<C-U>call <SID>jump_next_file(0)<CR>
nnoremap <silent> <Space><C-I> :<C-U>call <SID>jump_next_file(1)<CR>

function! s:jump_next_file(forward) abort
    if a:forward
        let l:index = -1
        let l:key = "\<C-I>"
    else
        let l:index = 1
        let l:key = "\<C-O>"
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

    if has('nvim')
        let l:post_keys = a:shell . '<CR><C-\><C-N>i'
    else
        let l:post_keys = printf('++close%s<CR>', empty(a:shell) ? '' : (' ' . a:shell))
    endif

    execute 'nmap' a:prefix_keys a:shown_cmd
    execute 'nnoremap' a:shown_cmd '<Nop>'

    for [l:key, l:command] in items(s:term_cmd)
        execute printf('nnoremap <silent> %s%s :<C-U>%s %s', a:shown_cmd, l:key, l:command, l:post_keys)
    endfor

    if a:0
        let l:cd_shown_cmd = a:1
        execute 'nmap' a:shown_cmd . 'c' l:cd_shown_cmd
        execute 'nnoremap' l:cd_shown_cmd '<Nop>'

        for [l:key, l:command] in items(s:term_cmd)
            execute printf("nnoremap <silent> <expr> %s%s ':<C-U>%s%scd ' . expand('%%:p:h') . '<CR><C-L>'",
            \   l:cd_shown_cmd, l:key, l:command, l:post_keys)
        endfor
    endif
endfunction

call g:Define_launching_terminal_key_mappings(g:is_windows ? 'powershell' : '', '<Space>t', '[terminal]', '[cd-term]')

inoremap <C-L> <C-X><C-L>

inoremap <expr> <C-E> pumvisible() ? '<C-Y><C-E>' : '<C-E>'
inoremap <expr> <C-Y> pumvisible() ? '<C-Y><C-Y>' : '<C-Y>'

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

if g:is_my_layout
    cnoremap <C-T> <C-F>
endif

snoremap <C-G> <C-O>pa
inoremap <C-G> <C-G>u<C-R>*
cnoremap <C-G> <C-R>*

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

" Solve the problem that Delete key does not work.
if has('unix') && !has('gui_running')
    inoremap  
    cnoremap  
endif
" }}}

" {{{ Display settings
set display=lastline
set laststatus=2
set lazyredraw
set list
set listchars=tab:\ \ ,extends:>
set numberwidth=3
set relativenumber
set scrolloff=3
set showcmd
set showmode
set t_Co=256

set statusline=%!g:My_status_line()

function! g:My_status_line() abort
    let l:delimiter = g:is_windows ? '\' : '/'
    let l:pwd = ' [%{' . (g:is_windows ? "getcwd() == fnamemodify('/', ':p') ? getcwd() : " : '')
                \ . "(getcwd() == $HOME) ? '~" . l:delimiter . "': '"
                \ . l:delimiter . "' . fnamemodify(getcwd(), ':~:t')}] "
    let l:file = '%<%F%m%r%h%w%= '

    let l:format   = "%{empty(&fileformat) ? '' : '| ' . &fileformat . ' '}"
    let l:encoding = "%{empty(&fileencoding) ? '' : '| ' . &fileencoding . ' '}"
    let l:filetype = "%{empty(&filetype) ? '' : '| ' . &filetype . ' '}"

    let l:col = '| %3v'
    let l:line = ":%{printf('%' . len(line('$')) . 'd', line('.'))} "
    let l:lastline = '/ %L '

    return l:pwd . l:file . l:format . l:encoding . l:filetype . l:col . l:line . l:lastline
endfunction

if !g:Is_plugin_enable('yozakura.vim')
    colorscheme desert
endif
" }}}

" {{{ Search settings
set ignorecase
set incsearch
set smartcase
set wrapscan

if g:Satisfy_vim_version(801, 1270) || has('nvim')
    set shortmess-=S
endif

augroup vimrc_hlsearch
    autocmd!
    autocmd VimEnter * set hlsearch
augroup END

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
    let l:save_reg_str = getreg(l:register, 1, 1)
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
" }}}

" {{{ Indent settings
set autoindent
set smartindent
set expandtab
set shiftwidth=4
set tabstop=4

if exists('+breakindent')
    set breakindent
endif
" }}}

" {{{ My commands
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

command! -nargs=1 -complete=file Rename call s:rename_file(<f-args>)

function! s:rename_file(file_name) abort
    let l:old_path = expand('%:p')
    let l:separator = g:is_windows ? '\' : '/'

    if stridx(a:file_name, l:separator) >= 0
        let l:new_path = a:file_name
    else
        let l:new_path = expand('%:h') . l:separator . a:file_name
    endif

    execute 'saveas' l:new_path

    if filereadable(l:new_path)
        call delete(l:old_path)
    endif
endfunction
" }}}

" {{{ Other settings
if exists(':terminal') == 2 && has('clientserver') && empty(v:servername)
    call remote_startserver('vim-server' . getpid())
endif

let s:session_file = expand(printf('~/%svimsession', g:is_windows ? '_' : '.'))
let s:temp_session_file = expand(printf('~/%svimtempsession', g:is_windows ? '_' : '.'))

augroup vimrc_session
    autocmd!
    autocmd CursorHold * if empty(getcmdwintype())
                     \ |     execute 'mksession!' s:temp_session_file
                     \ | endif
    autocmd ExitPre * if !v:dying
                  \ |     call delete(s:temp_session_file)
                  \ | endif
    autocmd VimEnter * nested call s:source_session_file()
augroup END

function! s:source_session_file() abort
    if !(empty(@%) && s:get_buf_byte() == 0)
        return
    endif

    if filereadable(s:session_file)
        silent execute 'source' s:session_file
        call delete(s:session_file)
    elseif filereadable(s:temp_session_file)
        silent execute 'source' s:temp_session_file
        call delete(s:temp_session_file)
    endif
endfunction

function! s:get_buf_byte() abort
    let l:byte = line2byte(line('$') + 1)
    return l:byte == -1 ? 0 : byte - 1
endfunction

command! PauseVim call s:pause_vim()

function! s:pause_vim() abort
    if !empty(execute('ls +'))
        echohl ErrorMsg
        echomsg '最後の変更が保存されていません'
        echohl None
        sbmodified
        return
    endif

    if exists('?getbufinfo')
        try
            execute 'bdelete' getbufinfo()->filter({-> !v:val['loaded']})->map({-> v:val['bufnr']})->join()
        catch
        endtry
    endif

    execute 'mksession' s:session_file

    try
        qall
    finally
        call delete(s:session_file)
    endtry
endfunction
" }}}

" {{{ Settings for each language
let g:java_highlight_all = 1
let g:java_highlight_functions = 'style'
let g:java_space_error = 1

augroup vimrc_filetypes
    autocmd!
    if exists('##TerminalOpen')
        autocmd TerminalOpen * setlocal norelativenumber
    elseif exists('##TermOpen') && exists('##TermClose')
        autocmd TermOpen  * setlocal norelativenumber
        autocmd TermClose * setlocal relativenumber
    endif

    autocmd FileType markdown inoremap <buffer> <nowait> ' '

    autocmd FileType neosnippet setlocal noexpandtab

    autocmd FileType text inoremap <buffer> <nowait> ' '

    autocmd FileType python setlocal textwidth=79

    autocmd FileType *sh setlocal tabstop=2
    autocmd FileType *sh setlocal shiftwidth=2
    autocmd BufRead,BufNewFile *shellrc* set filetype=sh

    autocmd FileType *tex setlocal conceallevel=0

    autocmd BufRead,BufNewFile *.tsv set filetype=tsv
    autocmd FileType tsv setlocal noexpandtab
    autocmd FileType tsv setlocal tabstop=8

    autocmd BufRead,BufNewFile *.toml set filetype=conf
    autocmd FileType vim,help         setlocal keywordprg=:help
    autocmd BufRead,BufNewFile *.toml setlocal keywordprg=:help
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> '''<CR> '''<CR>'''<Esc>O<Tab>
    autocmd FileType vim              inoremap <buffer> <expr> <CR> <SID>expand_cr()
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> <expr> <CR> <SID>expand_cr()

    let s:bracket = {
    \   '{' : '}',
    \   '[' : ']',
    \   '(' : ')'
    \}

    function! s:expand_cr() abort
        let l:col = col('.')

        if l:col < 2
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
            let l:right_indent .= empty(l:right_indent) ? "\<Tab>" : ''
            return "\<CR> \<C-U>\\\<Left> \<C-U>" . l:left_indent . "\<Right>" . l:right_indent
        else
            return "\<CR> \<C-U>\\\<Left> \<C-U>" . l:left_indent . "\<Right>" . l:right_indent
               \ . "\<Esc>O\\\<Left> \<C-U>" . l:left_indent . "\<Right>" . l:right_indent . "\<Tab>"
        endif
    endfunction
augroup END
" }}}

" {{{ Local settings
if filereadable(s:vimrc_local_post)
    execute 'source' s:vimrc_local_post
endif
" }}}
