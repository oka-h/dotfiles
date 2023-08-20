set cmdheight=1
set guicursor=a:blinkon0
set guioptions=
set noimdisable
set sessionoptions-=options

for s:button in ['Left', 'Right', 'Middle']
    for s:i in range(1, 4)
        for s:map in (['map', 'map!'] + (exists(':terminal') == 2 ? ['tmap'] : []))
            execute s:map . ' <' . (s:i > 1 ? (s:i . '-') : '') . s:button . 'Mouse> <Nop>'
        endfor
    endfor
endfor

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

if !exists('g:colors_name')
    colorscheme torte
endif
