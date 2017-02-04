" ------------------------------------------------------------------------------
" ~/.vimrc
" ------------------------------------------------------------------------------

" ------------------------------------------------------------------------------
" 基本設定
" ------------------------------------------------------------------------------

" 内容が変更されたら自動的に再読込み
set autoread

" バックアップファイルを作らない
set nobackup

" スワップファイルを作らない
set noswapfile

" .un~ファイルを作らない
set noundofile

" 文字コードの設定
set encoding=utf-8
scriptencoding utf-8

" gvimで終了時の状態を保存し, 次回起動時に状態を復元する
if has('gui_running')
    augroup session
        autocmd!

        " セッションファイル
        let s:sessionfile = expand('$HOME/.vimsession')

        if filereadable(s:sessionfile)
            " 引数なし起動の時、前回のセッションを復元
            autocmd VimEnter * nested if @% == '' && s:getBufByte() == 0
                                  \ |     execute 'source' s:sessionfile
                                  \ | endif
        endif

        " Vim終了時に現在のセッションを保存する
        let g:savesession = 1
        autocmd VimLeave * if g:savesession == 0
                       \ |     call delete(s:sessionfile)
                       \ | else
                       \ |     execute 'mksession!' s:sessionfile
                       \ | endif
    augroup END
endif

function! s:getBufByte()
    let byte = line2byte(line('$') + 1)
    if byte == -1
        return 0
    else
        return byte - 1
    endif
endfunction


" gvimの常駐化
" If starting gvim && arguments were given
" (assuming double-click on file explorer)
if has('gui_running') && argc()
    let s:running_vim_list = filter(split(serverlist(), '\n'),
                                  \ 'v:val !=? v:servername')
    " If one or more Vim instances are running
    if !empty(s:running_vim_list)
        " Open given files in running Vim and exit.
        silent execute '!start gvim'
                     \ '--servername' s:running_vim_list[0]
                     \ '--remote-tab-silent' join(argv(), ' ')
        qa!
    endif
    unlet s:running_vim_list
endif


" ------------------------------------------------------------------------------
" dein.vim settings
" ------------------------------------------------------------------------------

" プラグインが実際にインストールされるディレクトリ
if has('win32') || has('win64')
    let s:dein_dir = expand('$HOME\vimfiles\bundles')
else
    let s:dein_dir = expand('~/.vim/bundles')
endif

" dein.vim本体
let s:dein_repo_dir = s:dein_dir . expand('/repos/github.com/Shougo/dein.vim')

" dein.vimがなければダウンロードする
if &runtimepath !~# expand('/dein.vim')
    if !isdirectory(s:dein_repo_dir)
        execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    endif
    " execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
    execute 'set runtimepath^=' . s:dein_repo_dir
endif

if dein#load_state(s:dein_dir)
    " プラグインリストを入力したTOMLファイル
    let s:vimsettings = expand('~/vimsettings')
    let s:toml        = s:vimsettings . expand('/dein.toml')
    let s:lazy_toml   = s:vimsettings . expand('/dein_lazy.toml')

    call dein#begin(s:dein_dir, [$MYVIMRC, s:toml])

    " TOMLを読み込み，キャッシュしておく
    call dein#load_toml(s:toml,      {'lazy':0})
    call dein#load_toml(s:lazy_toml, {'lazy':1})

    " 設定終了
    call dein#end()
    call dein#save_state()
endif

" もし，未インストールのものがあればインストール
if dein#check_install()
    call dein#install()
endif


" ------------------------------------------------------------------------------
" キーマッピング設定
" ------------------------------------------------------------------------------

" <BS>, <CR>, <Space>による移動の無効化
noremap <BS>    <Nop>
noremap <CR>    <Nop>
noremap <Space> <Nop>

" jとgj, kとgkを入れ替える
noremap j gj
noremap gj j
noremap k gk
noremap gk k

" Home, Endの割り当て（状況に応じてg^/^/0, g$/$を使い分ける）
" （ビジュアルモードでもgoToHead/Footが使えるようにしたい…）
nnoremap <silent> <Space>h :call <SID>goToHead()<CR>
vnoremap <Space>h ^
onoremap <Space>h ^
nnoremap <silent> <Space>l :call <SID>goToFoot()<CR>
vnoremap <Space>l $
onoremap <Space>l $

function! s:goToHead()
    let l:befCol=col('.')
    normal g^
    let l:aftCol=col('.')
    if l:befCol == l:aftCol
        normal ^
        let l:aftCol=col('.')
        if l:befCol == l:aftCol
            normal 0
        endif
    endif
endfunction

function! s:goToFoot()
    let l:befCol=col('.')
    normal g$
    let l:aftCol=col('.')
    if l:befCol == l:aftCol
        normal $
    endif
endfunction


" <ESC><ESC>でハイライト解除
" nnoremap <ESC><ESC> :<C-U>nohlsearch<CR>

" インサートモードでのhjlkによる移動の割り当て
inoremap <C-H> <LEFT>
inoremap <C-J> <DOWN>
inoremap <C-K> <UP>
inoremap <C-L> <RIGHT>

" 括弧の補完
inoremap { {}<LEFT>
inoremap {<CR> {<CR>}<ESC>O
inoremap {} {}
inoremap ( ()<LEFT>
inoremap () ()
inoremap < <><LEFT>
inoremap <> <>
inoremap [ []<LEFT>
inoremap [] []
inoremap " ""<LEFT>
inoremap "" ""
inoremap ' ''<LEFT>
inoremap '' ''

" vim scriptの編集中に""，tomlファイルの編集中に''の補完を無効にする
augroup vimscript
    autocmd!
    autocmd BufRead,BufNewFile [._]g\=vimrc,*.toml inoremap <buffer> " "
    autocmd BufRead,BufNewFile *.toml              inoremap <buffer> ' '
augroup END

" Deleteキーが効かなくなる問題を解決
if has('unix') && !has('gui_running')
    noremap!  
endif


" ------------------------------------------------------------------------------
" 表示系設定
" ------------------------------------------------------------------------------

" カラースキームの設定
colorscheme torte

" 編集中のファイル名を表示する
set title

" 構文ハイライトを有効にする
syntax enable

" ステータスラインを表示
set laststatus=2

" 相対ルーラの表示
set relativenumber
 
" カーソル行を表示
set cursorline

" カーソル行の上下へのオフセットを設定する
set scrolloff=4

" ハイライトする括弧に<>を追加
set matchpairs& matchpairs+=<:>

" Unicodeで行末が変になる問題を解決
set ambiwidth=double

" 長い行をハイライト
" if exists ('&colorcolums')
"     set colorcolumn=+1
" endif

" 挿入モード時、ステータスラインの色を変更
let g:hi_insert = 'highlight statusLine guifg=darkblue guibg=red gui=none '
              \ . 'ctermfg=blue ctermbg=red cterm=none'

if has('syntax')
    augroup InsertHook
      autocmd!
      autocmd InsertEnter * call s:statusLine('Enter')
      autocmd InsertLeave * call s:statusLine('Leave')
    augroup END
endif

let s:slhlcmd = ''
function! s:statusLine(mode)
    if a:mode == 'Enter'
      silent! let s:slhlcmd = 'highlight ' . s:getHighlight('statusLine')
      silent exec g:hi_insert
    else
      highlight clear statusLine
      silent exec s:slhlcmd
    endif
endfunction

function! s:getHighlight(hi)
    redir => hl
    exec 'highlight '.a:hi
    redir END
    let hl = substitute(hl, '[\r\n]', '', 'g')
    let hl = substitute(hl, 'xxx', '', '')
    return hl
endfunction

" ESC後にすぐ反映されない対策（方向キーの動作がおかしくなる？）
"if has('unix') && !has('gui_running')
"    inoremap <silent> <ESC> <ESC>
"    inoremap <silent> <C-[> <ESC>
"endif


" 全角スペースを表示
" コメント以外で全角スペースを指定しているので scriptencodingと、
" このファイルのエンコードが一致するよう注意！
" 全角スペースが強調表示されない場合、ここでscriptencodingを指定すると良い。
" scriptencoding cp932

" デフォルトのZenkakuSpaceを定義
function! s:zenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=red gui=underline guifg=red
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call s:zenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    autocmd VimEnter,WinEnter * match ZenkakuSpace '\%u3000'
  augroup END
  call s:zenkakuSpace()
endif


" ------------------------------------------------------------------------------
" 検索設定
" ------------------------------------------------------------------------------

" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase

" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase

" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch

" 検索時に最後まで行ったら最初に戻る
set wrapscan

" 検索語をハイライト
augroup highlight
    autocmd!
    autocmd VimEnter * set hlsearch
augroup END

" ビジュアルモードで, *, #で選択文字列で検索できるようにする
xnoremap * :<C-U>call <SID>vSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-U>call <SID>vSearch()<CR>#<C-R>=@/<CR><CR>

function! s:vSearch()
    let l:temp=@s
    norm! gv"sy
    let @/='\V' . substitute(substitute(escape(@s, '/\'), '\n$', '', ''), '\n', '\\n', 'g')
    let @s = l:temp
endfunction


" ------------------------------------------------------------------------------
" インデント設定
" ------------------------------------------------------------------------------

" 自動インデントを行う
set autoindent

" 高度な自動インデントを行う
set smartindent

" Tab文字を半角スペースにする
set expandtab

" 行頭でのTab文字の表示幅
set shiftwidth=4

" 行頭以外のTab文字の表示幅
set tabstop=4


" ------------------------------------------------------------------------------
" その他の設定
" ------------------------------------------------------------------------------

" 行を越えて左右移動
set whichwrap=h,l,<,>,[,]

" スペルチェック時に日本語を無視
set spelllang& spelllang+=cjk

" コメント補完の無効化
augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

