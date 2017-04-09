" ------------------------------------------------------------------------------
" ~/.vimrc
"
" ~/.config/nvim/init.vim
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

set fileencodings=usc-bom,iso-2022-jp-3,utf-8,euc-jp,cp932


" ------------------------------------------------------------------------------
" Dein.vim settings
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

" Dein.vim location.
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
        let g:vim_settings = expand('~/dotfiles/vim')
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
        autocmd VimEnter * echomsg 'Dein.vim is not installed. '
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

" Save 10000 previous commands.
set history=10000

" Read Japanese help files.
set helplang=ja

" Don't beep.
if has('nvim') || v:version >= 705 || (v:version == 704 && has('patch793'))
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
" This uses "g^", "^" and "0" or "g$" and "$" for different purposes
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


" In a terminal emulator,
" change from terminal mode to normal mode by <ESC><ESC>.
if has('nvim')
    tnoremap <ESC><ESC> <C-\><C-N>
endif


" ------------------------------------------------------------------------------
" Display settings
" ------------------------------------------------------------------------------

" Display current file name.
set title

" Display relative line numbers.
set relativenumber
set numberwidth=3
 
" Display the cursor line.
" set cursorline

" Set the minimal number of screen lines to keep above and below the cursor.
set scrolloff=4

" Display tabs and lines continue beyond the right of the screen.
set list
set listchars=tab:>-,extends:>

" Display command in the last line of the screen.
set showcmd

" Setting of the status line.
set laststatus=2
set statusline=%!g:My_status_line()

function! g:My_status_line()
    return ' %F%m%r%h%w%= '
       \ . '%{&fileformat!=''''?&fileformat.'' | '':''''}'
       \ . '%{&fileencoding!=''''?&fileencoding.'' | '':''''}'
       \ . '%{&filetype!=''''?&filetype.'' | '':''''}'
       \ . '%3v:%' . (float2nr(log10(line('$')))+1) . 'l / %L '
endfunction


" Setting of the tab line.
set tabline=%!g:My_tab_line()

function! g:My_tab_line()
    let l:tabline = ''

    for l:i in range(1, tabpagenr('$'))
        let l:buflist = tabpagebuflist(l:i)
        let l:bufid = l:buflist[tabpagewinnr(l:i) - 1]

        let l:tabstart = '%' . l:i . 'T%#'
                    \ . (l:i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'

        let l:tabnum = '(' . l:i . ') '

        let l:filename = pathshorten(fnamemodify(bufname(l:bufid), ':t'))
        if l:filename == ''
            let l:filename = '[No Name]'
        endif
        let l:filename .= ' '

        let l:bufnum = len(l:buflist)
        if l:bufnum <= 1
            let l:bufnum = ''
        endif
        let l:modified = ''
        for l:buftemp in l:buflist
            if getbufvar(l:buftemp, '&modified')
                let l:modified = '+'
                break
            endif
        endfor
        let l:addinfo = ''
        if l:bufnum != '' || l:modified != ''
            let l:addinfo = '[' . l:bufnum . l:modified .'] '
        endif

        let l:tabfinish = '%T'

        let l:tabline .= l:tabstart
                     \ . l:tabnum
                     \ . l:filename
                     \ . l:addinfo
                     \ . l:tabfinish
    endfor

    let l:tabline .= '%#TabLineFill#%T%='
    let l:tabline .= '%<[' . fnamemodify(getcwd(), ':~') . ']'
    return l:tabline
endfunction


" ------------------------------------------------------------------------------
" Color settings
" ------------------------------------------------------------------------------

" Setting of highlights.
augroup sethighlights
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
    highlight two_byte_space cterm=none ctermbg=red gui=none guibg=red
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
xnoremap # :<C-U>call <SID>visual_star_search()<CR>?<C-R>=@/<CR><CR>

function! s:visual_star_search()
    let l:temp = @s
    normal! gv"sy
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
    let l:time = getftime(expand('%'))
    if l:time < 0
        normal! 
    else
        let l:file_info = substitute(execute('normal! '), '\n', '', 'g')
        let l:timestamp = strftime(" (%y/%m/%d %H:%M:%S)", l:time)
        let l:file_info = join(insert(split(l:file_info, '"\zs'),
                                    \ l:timestamp, 2), '')
        echomsg l:file_info
    endif
endfunction


" ------------------------------------------------------------------------------
" Settings for each language
" ------------------------------------------------------------------------------

" Enable syntax highlight for Java.
let g:java_highlight_all       = 1
let g:java_highlight_functions = 'style'
let g:java_space_error         = 1

" Setting of tab width for shell script.
augroup shellscript
    autocmd!
    autocmd FileType *sh setlocal tabstop=2
    autocmd FileType *sh setlocal shiftwidth=2
augroup END

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
let s:vimrc_local = expand('~/.vimrc_local')
if filereadable(s:vimrc_local)
    execute 'source' s:vimrc_local
endif

