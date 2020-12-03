" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         autoload/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Dec 3, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

scriptencoding utf-8

let s:cpo_save = &cpoptions
set cpoptions&vim

hi def link QfHistory        Pmenu
hi def link QfHistoryHeader  Title
hi def link QfHistoryCurrent Title
hi def link QfHistoryEmpty   Comment

const s:defaults = {
        \ 'title': 1,
        \ 'padding': [],
        \ 'border': [],
        \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ 'borderhighlight': []
        \ }

const s:get = {k -> get(get(g:, 'qfhistory', s:defaults), k, get(s:defaults, k))}

function s:popup_callback(loclist, winid, result) abort
    if a:result < 1
        return
    endif
    silent execute a:result .. (a:loclist ? 'lhistory' : 'chistory')

    const event = a:loclist ? 'lhistory' : 'chistory'
    if exists('#QuickFixCmdPost#' .. event)
        execute 'doautocmd <nomodeline> QuickFixCmdPost' event
    endif
endfunction

function s:popup_filter(loclist, winid, key) abort
    if a:key ==# 'j' || a:key ==# "\<down>"
        call win_execute(a:winid, line('.', a:winid) == line('$', a:winid) ? '2' : 'normal! +')
    elseif a:key ==# 'k' || a:key ==# "\<up>"
        call win_execute(a:winid, line('.', a:winid) == 2 ? '$' : 'normal! -')
    elseif a:key ==# 'g' || a:key ==# "\<home>"
        call win_execute(a:winid, '2')
    elseif a:key ==# 'G' || a:key ==# "\<end>"
        call win_execute(a:winid, '$')
    elseif a:key =~# '\d'
        call popup_close(a:winid, a:key == 0 ? line('$', a:winid) - 1 : a:key)
    elseif a:key ==# 'q'
        call popup_close(a:winid, -1)
    elseif a:key ==# "\<cr>"
        call popup_close(a:winid, line('.', a:winid) - 1)
    endif
    return v:true
endfunction

function qfhistory#open(loclist) abort
    const Xgetlist = a:loclist ? function('getloclist', [0]) : function('getqflist')
    const nr = Xgetlist({'nr': '$'}).nr

    if !nr
        echo 'No ' .. (a:loclist ? 'location lists for current window' : 'quickfix lists')
        return
    endif

    " Number of each error type (E, W, I, N) in each quickfix list
    const qferrors = range(1, nr)
            \ ->map({_,i -> Xgetlist({'nr': i, 'items': 0}).items->map('v:val.type')})
            \ ->map({_,i -> {
            \   'E': count(i, 'E', v:true),
            \   'W': count(i, 'W', v:true),
            \   'I': count(i, 'I', v:true),
            \   'N': count(i, 'N', v:true),
            \   '?': copy(i)->filter('v:val !~? "^[EWIN]$"')->len()
            \   }
            \ })

    " Maximum value of each error type in all quickfix lists
    const max = {
            \ 'E': copy(qferrors)->map("v:val['E']")->max(),
            \ 'W': copy(qferrors)->map("v:val['W']")->max(),
            \ 'I': copy(qferrors)->map("v:val['I']")->max(),
            \ 'N': copy(qferrors)->map("v:val['N']")->max(),
            \ '?': copy(qferrors)->map("v:val['?']")->max()
            \ }

    " Columns E/W/I/N/? are shown only when E/W/I/N are non-zero in at least one
    " list
    const header = 'QF'
            \ .. (!max['E'] ? '' : '    E')
            \ .. (!max['W'] ? '' : '    W')
            \ .. (!max['I'] ? '' : '    I')
            \ .. (!max['N'] ? '' : '    N')
            \ .. (!max['E'] && !max['W'] && !max['I'] && !max['N'] ? '' : '     ?')
            \ .. '   Size   Title'

    const lists = range(1, nr)->map({_,i ->
            \ printf('%2d', i)
            \ .. (!max['E'] ? '' : printf(' %4s', !qferrors[i-1]['E'] ? '-' : qferrors[i-1]['E']))
            \ .. (!max['W'] ? '' : printf(' %4s', !qferrors[i-1]['W'] ? '-' : qferrors[i-1]['W']))
            \ .. (!max['I'] ? '' : printf(' %4s', !qferrors[i-1]['I'] ? '-' : qferrors[i-1]['I']))
            \ .. (!max['N'] ? '' : printf(' %4s', !qferrors[i-1]['N'] ? '-' : qferrors[i-1]['N']))
            \ .. (!max['E'] && !max['W'] && !max['I'] && !max['N'] ? '' : printf(' %5s', !qferrors[i-1]['?'] ? '-' : qferrors[i-1]['?']))
            \ .. printf(' %6d', Xgetlist({'nr': i, 'size': 0}).size)
            \ .. printf('   %s', Xgetlist({'nr': i, 'title': 0}).title)
            \ })

    const qflist = extend([header], lists)

    const winid = popup_create(qflist, {
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
            \ 'filter': funcref('s:popup_filter', [a:loclist]),
            \ 'filtermode': 'n'
            \ })

    call popup_filter_menu(winid, 'j')

    call matchadd('QfHistoryHeader', '\%^.*$', 1, -1, {'window': winid})
    for i in range(1, nr)
        if !Xgetlist({'nr': i, 'size': 0}).size
            let pattern = printf('\%%%dl.*\%%%dc', i+1, winbufnr(winid)->getbufline(i+1)[0]->len())
            call matchadd('QfHistoryEmpty', pattern, 1, -1, {'window': winid})
        endif
    endfor

    call setwinvar(winid, '&signcolumn', 'yes')
    call sign_define('QfCurrent', {'text': '>', 'texthl': 'QfHistoryCurrent'})
    call sign_place(0, 'PopUpQfHistory', 'QfCurrent', winbufnr(winid), {
            \ 'lnum': Xgetlist({'nr': 0}).nr + 1,
            \ 'priority': 10
            \ })

    return winid
endfunction

let &cpoptions = s:cpo_save
unlet s:cpo_save
