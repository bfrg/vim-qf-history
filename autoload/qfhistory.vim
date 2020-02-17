" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         autoload/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Feb 17, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:cpo_save = &cpoptions
set cpoptions&vim

hi def link QfHistory Pmenu

function! s:popup_callback(loclist, winid, result) abort
    if a:result < 1
        return
    endif
    silent execute a:result .. (a:loclist ? 'lhistory' : 'chistory')
endfunction

function! s:popup_filter(loclist, winid, key) abort
    if a:key ==# 'j'
        call win_execute(a:winid, line('.', a:winid) == line('$', a:winid) ? '2' : 'normal! +')
    elseif a:key ==# 'k'
        call win_execute(a:winid, line('.', a:winid) == 2 ? '$' : 'normal! -')
    elseif a:key ==# 'g'
        call win_execute(a:winid, '2')
    elseif a:key ==# 'G'
        call win_execute(a:winid, '$')
    elseif a:key =~# '\d'
        call win_execute(a:winid, a:key == 0 ? '$' : string(a:key + 1))
    elseif a:key ==# 'q'
        call popup_close(a:winid, -1)
    elseif a:key ==# "\<cr>"
        call popup_close(a:winid, line('.', a:winid) - 1)
    endif
    return v:true
endfunction

function! qfhistory#open(loclist) abort
    let Xgetlist = a:loclist ? function('getloclist', [0]) : function('getqflist')
    let nr = Xgetlist({'nr': '$'}).nr

    if !nr
        echomsg 'No entries'
        return
    endif

    let qflist = ['  QF   Size   Title']
    for i in range(1, nr)
        call add(qflist, printf('%s %2d %6d   %s',
                \ (i == Xgetlist({'nr': 0}).nr ? '>' : ' '),
                \ i,
                \ Xgetlist({'nr': i, 'size': 0}).size,
                \ Xgetlist({'nr': i, 'title': 0}).title
                \ ))
    endfor

    let winid = popup_create(qflist, {
            \ 'border': [],
            \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            \ 'padding': [1,1,1,1],
            \ 'cursorline': 1,
            \ 'wrap': v:false,
            \ 'mapping': v:false,
            \ 'highlight': 'QfHistory',
            \ 'title': (a:loclist ? ' Location-list History' : ' Quickfix History'),
            \ 'callback': funcref('s:popup_callback', [a:loclist]),
            \ 'filter': funcref('s:popup_filter', [a:loclist])
            \ })

    call popup_filter_menu(winid, 'j')
    return winid
endfunction

let &cpoptions = s:cpo_save
unlet s:cpo_save
