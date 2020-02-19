" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         autoload/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Feb 19, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:cpo_save = &cpoptions
set cpoptions&vim

hi def link QfHistory           Pmenu
hi def link QfHistoryHeader     Title
hi def link QfHistoryCurrent    Title
hi def link QfHistoryEmpty      Comment

let s:defaults = {
        \ 'title': 1,
        \ 'padding': [1,1,1,1],
        \ 'border': [],
        \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ 'borderhighlight': []
        \ }

let s:get = {k -> get(get(g:, 'qfhistory', s:defaults), k, get(s:defaults, k))}

function! s:popup_callback(loclist, winid, result) abort
    if a:result < 1
        return
    endif
    silent execute a:result .. (a:loclist ? 'lhistory' : 'chistory')
endfunction

function! s:popup_filter(loclist, winid, key) abort
    if a:key ==# 'j' || a:key ==# "\<down>"
        call win_execute(a:winid, line('.', a:winid) == line('$', a:winid) ? '2' : 'normal! +')
    elseif a:key ==# 'k' || a:key ==# "\<up>"
        call win_execute(a:winid, line('.', a:winid) == 2 ? '$' : 'normal! -')
    elseif a:key ==# 'g' || a:key ==# "\<home>"
        call win_execute(a:winid, '2')
    elseif a:key ==# 'G' || a:key ==# "\<end>"
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
        echo 'No ' .. (a:loclist ? 'location' : 'quickfix') .. ' lists'
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
            \ 'padding': s:get('padding'),
            \ 'border': s:get('border'),
            \ 'borderchars': s:get('borderchars'),
            \ 'borderhighlight': s:get('borderhighlight'),
            \ 'cursorline': 1,
            \ 'wrap': v:false,
            \ 'mapping': v:false,
            \ 'highlight': 'QfHistory',
            \ 'title': s:get('title') ? (a:loclist ? ' Location-list History' : ' Quickfix History') : '',
            \ 'callback': funcref('s:popup_callback', [a:loclist]),
            \ 'filter': funcref('s:popup_filter', [a:loclist])
            \ })

    call popup_filter_menu(winid, 'j')

    call matchadd('QfHistoryHeader', '\%^.*$', 1, 100000, {'window': winid})
    call matchadd('QfHistoryEmpty', '^>\=\zs\s*\d\+\s\+0.*', 1, 100001, {'window': winid})
    call matchadd('QfHistoryCurrent', '^>', 2, 100002, {'window': winid})

    return winid
endfunction

let &cpoptions = s:cpo_save
unlet s:cpo_save
