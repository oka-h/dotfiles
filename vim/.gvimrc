set cmdheight=1
set guioptions=
set noimdisable

if !has('nvim')
    set guicursor=a:blinkon0
endif

if !(has('win32') && has('nvim'))
    augroup disable_ime
        autocmd!
        autocmd InsertEnter * set iminsert=0
        autocmd CmdwinEnter [:/\?] call feedkeys(":\<ESC>\<C-L>", 'n')

        if exists('##CmdlineEnter')
            autocmd CmdlineEnter [/\?] if mode() ==# 'c' && (&imsearch == 2 || (&imsearch == -1 && &iminsert == 2))
                                   \ |     call feedkeys("\<C-^>", 'n')
                                   \ | end
        endif
    augroup END
endif
