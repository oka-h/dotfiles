" ------------------------------------------------------------------------------
" dotfiles/vim/.gvimrc
" ------------------------------------------------------------------------------

set cmdheight=1
set guicursor=a:blinkon0
set guioptions=

for s:button in ['Left', 'Right', 'Middle']
    for s:i in range(1, 4)
        for s:map in (['map', 'lmap'] + (exists(':terminal') == 2 ? ['tmap'] : []))
            execute s:map . ' <' . (s:i > 1 ? (s:i . '-') : '') . s:button . 'Mouse> <Nop>'
        endfor
    endfor
endfor

if !exists('g:colors_name')
    colorscheme torte
endif
