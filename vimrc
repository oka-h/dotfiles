" ------------------------------------------------------------------------------
" ~/.vimrc
" ------------------------------------------------------------------------------

" ------------------------------------------------------------------------------
" Pre-settings
" ------------------------------------------------------------------------------

" Check encode automatically.
if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif

if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'

    " Check if iconv corrsponds to eucJP-ms.
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
    " Check if iconv corrsponds to JISX0213.
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    endif

    " Setting of fileencodings.
    if &encoding ==# 'utf-8'
        execute 'set fileencodings^=' . s:enc_jis . ','. s:enc_euc . ',cp932'
    else
        execute 'set fileencodings+=' . s:enc_jis . ',utf-8,ucs-2le,ucs-2'

        if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
            set fileencodings+=cp932
            set fileencodings-=euc-jp
            set fileencodings-=euc-jisx0213
            set fileencodings-=eucjp-ms
            execute 'set encoding=' . s:enc_euc
            execute 'set fileencoding=' . s:enc_euc
        else
            execute 'set fileencodings+=' . s:enc_euc
        endif
    endif
endif

" Set a value of encoding to fileencoding
" if the file has not contained Japanese character.
if has('autocmd')
    function! AU_ReCheck_FENC()
        if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
            execute 'set fileencoding=' . &encoding
        endif
    endfunction
    autocmd BufReadPost * call AU_ReCheck_FENC()
endif

" Check line feed format automatically.
set fileformats=unix,dos,mac

" In Unicode, show some symbols as two-byte character.
if has('multi_byte')
    set ambiwidth=double
endif

" ------------------------------------------------------------------------------
" dein.vim settings
" ------------------------------------------------------------------------------

" The directory installed plugins.
if has('win32') || has('win64')
    if has('nvim')
        let g:dein_dir = expand('$HOME\AppData\Local\nvim\bundles')
    else
        let g:dein_dir = expand('$HOME\vimfiles\bundles')
    endif
else
    let g:dein_dir = expand('~/.vim/bundles')
endif

" dein.vim location.
let s:dein_repo_dir = g:dein_dir . expand('/repos/github.com/Shougo/dein.vim')


" Install dein.vim.
function! s:dein_install()
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    " Check dein.vim,
    " then load plugins and delete the command to install dein.vim.
    if isdirectory(s:dein_repo_dir)
        call s:dein_load()
        delcommand DeinInstall
    endif
endfunction


" Load plugins.
function! s:dein_load()
    " Check runtime path.
    if &runtimepath !~# expand('/dein.vim')
        execute 'set runtimepath^=' . s:dein_repo_dir
    endif

    if dein#load_state(g:dein_dir)
        " TOML files written plugins.
        let g:vim_settings = expand('~/vimsettings')
        let s:toml         = g:vim_settings . expand('/dein.toml')
        let s:local_toml   = expand('~/.dein_local.toml')

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
endfunction


if isdirectory(s:dein_repo_dir)
    " Load plugins if dein.vim is installed.
    call s:dein_load()
else
    " Else, make the command to install it.
    command! DeinInstall call s:dein_install()
    augroup nodein_call
        autocmd!
        autocmd VimEnter * echo 'dein.vim is not installed. '
                            \ . 'Please install it by :DeinIntall.'
    augroup END
endif


" ------------------------------------------------------------------------------
" General settings
" ------------------------------------------------------------------------------

" Reload the modified file automatically.
set autoread

" Don't make a backup file.
set nobackup

" Don't make a swap file.
set noswapfile

" Don't make an undo file.
set noundofile

" Read Japanese help files.
set helplang=ja

" On a gvim, save vim state when vim finishes, and restore it when vim starts.
" This is available only when g:save_session is not 0.
if has('gui_running')
    augroup save_and_load_session
        autocmd!

        " Session file location.
        let s:session_file = expand('$HOME/.vimsession')

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
endif

function! s:get_buf_byte()
    let byte = line2byte(line('$') + 1)
    return byte == -1 ? 0 : byte - 1
endfunction


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
inoremap (     ()<LEFT>
inoremap ()    ()
inoremap <     <><LEFT>
inoremap <>    <>
inoremap [     []<LEFT>
inoremap []    []
inoremap "     ""<LEFT>
inoremap ""    ""
inoremap '     ''<LEFT>
inoremap ''    ''

" In insert mode, assign movement to <C-H>, <C-J>, <C-K> and <C-L>.
inoremap <C-H> <LEFT>
inoremap <C-J> <DOWN>
inoremap <C-K> <UP>
inoremap <C-L> <RIGHT>

" In command line mode, assign complementing history to <C-P> and <C-N>.
cnoremap <C-P> <UP>
cnoremap <C-N> <DOWN>

" Assign <Home> and <End> to "<Space>h" and "<Space>l".
" This uses "g^", "^" and 0 or "g$" and "$" for different purposes
" in accordance situations.
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


" ------------------------------------------------------------------------------
" Display settings
" ------------------------------------------------------------------------------

" Show current file name.
set title

" Show relative line numbers.
set relativenumber
set numberwidth=3
 
" Show the cursor line.
" set cursorline

" Set the minimal number of screen lines to keep above and below the cursor.
set scrolloff=4

" Highlight pairs of "<>"
set matchpairs& matchpairs+=<:>

" Setting of the status line.
set laststatus=2
set statusline=%!g:My_status_line()

function! g:My_status_line()
    return ' %F%m%r%h%w%='
       \ . '%{&fileformat!=''''?&fileformat.'' | '':''''}'
       \ . '%{&fileencoding!=''''?&fileencoding.'' | '':''''}'
       \ . '%{&filetype!=''''?&filetype.'' | '':''''}'
       \ . '%3v:%' . (float2nr(log10(line('$')))+1) . 'l / %L '
endfunction


" ------------------------------------------------------------------------------
" Color settings
" ------------------------------------------------------------------------------

" Setting of highlights.
augroup sethighlights
    autocmd!
    autocmd ColorScheme * call s:define_hilights()
augroup END

function! s:define_hilights()
    " Set the color of the cursor line.
    highlight CursorLine term=underline cterm=underline gui=underline

    " Set the colors of complementary pop-up.
    highlight Pmenu    ctermbg=lightgray
    highlight Pmenu    ctermfg=black
    highlight PmenuSel ctermbg=3
    highlight PmenuSel ctermfg=black
endfunction


" In insert mode, change the color of the status line.
" let g:hl_insert = 'highlight StatusLine ctermfg=white ctermbg=red cterm=none '
"                                      \ . 'guifg=white   guibg=red   gui=none'
" 
" if has('syntax')
"     augroup insert_hook
"         autocmd!
"         autocmd InsertEnter * call s:status_line('Enter')
"         autocmd InsertLeave * call s:status_line('Leave')
"     augroup END
" endif
" 
" let s:sl_hl_cmd = ''
" function! s:status_line(mode)
"     if a:mode == 'Enter'
"         silent! let s:sl_hl_cmd = 'highlight ' . s:get_highlight('StatusLine')
"         silent exec g:hl_insert
"     else
"         highlight clear StatusLine
"         silent exec s:sl_hl_cmd
"     endif
" endfunction
" 
" function! s:get_highlight(hi)
"     redir => hl
"     exec 'highlight ' . a:hi
"     redir END
"     let hl = substitute(hl, '[\r\n]', '', 'g')
"     let hl = substitute(hl, 'xxx', '', '')
"     return hl
" endfunction


" Highlight two-byte spaces.

" Set highlight of two byte spaces.
function! s:set_tbs_hl()
    highlight two_byte_space cterm=none ctermbg=darkred gui=none guibg=darkred
endfunction

if has('syntax')
    augroup two_byte_space
        autocmd!
        " Remove next line if you set two_byte_space in colorscheme.
        autocmd ColorScheme * call s:set_tbs_hl()
        " Associate the highlight with two byte spaces.
        autocmd VimEnter,WinEnter * match two_byte_space /　/
        autocmd VimEnter,WinEnter * match two_byte_space '\%u3000'
    augroup END
    call s:set_tbs_hl()
endif


" Enable syntax highlight.
syntax enable

" Setting of the colorscheme.
colorscheme torte

" Set the color of front of each line.
highlight CursorLineNr ctermfg=red guifg=red

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
augroup hl_search
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
xnoremap * :<C-U>call <SID>visual_star_search()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-U>call <SID>visual_star_search()<CR>#<C-R>=@/<CR><CR>

function! s:visual_star_search()
    let l:temp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(substitute(escape(@s, '/\'), '\n$', '', ''),
                             \ '\n', '\\n', 'g')
    let @s = l:temp
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

" Enable movement over lines.
set whichwrap=h,l,<,>,[,]

" Set complementary settings in command line mode.
set wildmode=longest:full,full

" Ignore Japanese when check spelling
set spelllang& spelllang+=cjk

" Disable completing comment.
augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

" Show the last modification of the current file by <C-G>.
nnoremap <C-G> :<C-U>call <SID>show_file_info()<CR>

function! s:show_file_info()
    let l:time = getftime(expand('%'))
    if l:time < 0
        normal! 
    else
        let l:file_info = substitute(execute('normal! '), '\n', '', 'g')
        let l:timestamp = strftime(" (%y/%m/%d %H:%M:%S)", l:time)
        let l:file_info = join(insert(split(l:file_info, '"\zs'),
                                    \ l:timestamp, 2), '')
        echo l:file_info
    endif
endfunction


" ------------------------------------------------------------------------------
" Settings for each language
" ------------------------------------------------------------------------------

" Disable completing "" while editing vim scripts,
" and '' while editing TOML files.
augroup vimscript
    autocmd!
    autocmd FileType           vim    inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml inoremap <buffer> ' '
augroup END


" ------------------------------------------------------------------------------
" Local settings
" ------------------------------------------------------------------------------

" Load a local vimrc file if there is it.
let s:vimrc_local = expand('$HOME/.vimrc_local')
if filereadable(s:vimrc_local)
    execute 'source' s:vimrc_local
endif

