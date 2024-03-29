vim9script
# ==============================================================================
# Display all quickfix lists in the stack and switch to selected list
# File:         autoload/qfhistory.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-qf-history
# Last Change:  Jun 6, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

scriptencoding utf-8

hi def link QfHistory        Pmenu
hi def link QfHistoryHeader  Title
hi def link QfHistoryCurrent Title
hi def link QfHistoryEmpty   Comment

def Getopt(key: string): any
    const defaults: dict<any> = {
        title: true,
        padding: [],
        border: [],
        borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        borderhighlight: []
    }
    return get(g:, 'qfhistory', defaults)->get(key, defaults[key])
enddef

def Popup_callback(loclist: bool, winid: number, result: number)
    if result < 1
        return
    endif

    const event: string = loclist ? 'lhistory' : 'chistory'
    silent execute $':{result}{event}'

    if exists($'#QuickFixCmdPost#{event}')
        execute $'doautocmd <nomodeline> QuickFixCmdPost {event}'
    endif
enddef

def Popup_filter(winid: number, key: string): bool
    if key == 'j' || key == "\<down>" || key == "\<tab>"
        win_execute(winid, line('.', winid) == line('$', winid) ? ':2' : 'normal! +')
    elseif key == 'k' || key == "\<up>" || key == "\<s-tab>"
        win_execute(winid, line('.', winid) == 2 ? ':$' : 'normal! -')
    elseif key == 'g' || key == "\<home>"
        win_execute(winid, ':2')
    elseif key == 'G' || key == "\<end>"
        win_execute(winid, ':$')
    elseif key =~ '\d'
        const nr: number = str2nr(key)
        popup_close(winid, nr == 0 || nr >= line('$', winid) ? line('$', winid) - 1 : nr)
    elseif key == 'q'
        popup_close(winid, -1)
    elseif key == "\<cr>"
        popup_close(winid, line('.', winid) - 1)
    endif
    return true
enddef

export def Open(loclist: bool): number
    const Xgetlist = loclist ? function('getloclist', [0]) : function('getqflist')
    const nr: number = Xgetlist({nr: '$'}).nr

    if !nr
        echo 'No ' .. (loclist ? 'location lists for current window' : 'quickfix lists')
        return 0
    endif

    # Number of each error type (E, W, I, N, ?) in each quickfix list
    var qferrors: list<dict<number>> = []

    # Maximum value of each error type in all quickfix lists
    var max: dict<number> = {E: 0, W: 0, I: 0, N: 0, '?': 0}

    for i in range(1, nr)
        var ntypes: dict<number> = {E: 0, W: 0, I: 0, N: 0, '?': 0}

        for j in Xgetlist({nr: i, items: 0}).items
            if j.type ==? 'E'
                ntypes['E'] += 1
            elseif j.type ==? 'W'
                ntypes['W'] += 1
            elseif j.type ==? 'I'
                ntypes['I'] += 1
            elseif j.type ==? 'N'
                ntypes['N'] += 1
            else
                ntypes['?'] += 1
            endif
        endfor

        add(qferrors, ntypes)
        max['E'] = max([ntypes['E'], max['E']])
        max['W'] = max([ntypes['W'], max['W']])
        max['I'] = max([ntypes['I'], max['I']])
        max['N'] = max([ntypes['N'], max['N']])
        max['?'] = max([ntypes['?'], max['?']])
    endfor

    # Popup content
    var lists: list<string> = []

    for i in range(1, nr)
        var str: string = printf('%2d', i)
        str ..= !max['E'] ? '' : printf(' %4s', !qferrors[i - 1]['E'] ? '-' : qferrors[i - 1]['E'])
        str ..= !max['W'] ? '' : printf(' %4s', !qferrors[i - 1]['W'] ? '-' : qferrors[i - 1]['W'])
        str ..= !max['I'] ? '' : printf(' %4s', !qferrors[i - 1]['I'] ? '-' : qferrors[i - 1]['I'])
        str ..= !max['N'] ? '' : printf(' %4s', !qferrors[i - 1]['N'] ? '-' : qferrors[i - 1]['N'])
        str ..= !max['E'] && !max['W'] && !max['I'] && !max['N'] ? '' : printf(' %5s', !qferrors[i - 1]['?'] ? '-' : qferrors[i - 1]['?'])
        str ..= printf(' %6d', Xgetlist({nr: i, size: 0}).size)
        str ..= printf('   %s', Xgetlist({nr: i, title: 0}).title)
        add(lists, str)
    endfor

    # Columns E/W/I/N/? are displayed only if at least one list contains
    # non-zero E/W/I/N types
    const header: string = (loclist ? 'LL' : 'QF')
        .. (!max['E'] ? '' : '    E')
        .. (!max['W'] ? '' : '    W')
        .. (!max['I'] ? '' : '    I')
        .. (!max['N'] ? '' : '    N')
        .. (!max['E'] && !max['W'] && !max['I'] && !max['N'] ? '' : '     ?')
        .. '   Size   Title'

    const winid: number = extend([header], lists)->popup_create({
        padding: Getopt('padding'),
        border: Getopt('border'),
        borderchars: Getopt('borderchars'),
        borderhighlight: Getopt('borderhighlight'),
        cursorline: true,
        wrap: false,
        mapping: false,
        highlight: 'QfHistory',
        title: Getopt('title') ? (loclist ? ' Location-list History ' : ' Quickfix History ') : '',
        callback: (winid: number, result: number) => Popup_callback(loclist, winid, result),
        filter: Popup_filter,
        filtermode: 'n'
    })

    popup_filter_menu(winid, 'j')
    matchadd('QfHistoryHeader', '\%^.*$', 1, -1, {window: winid})

    for i in range(1, nr)
        if !Xgetlist({nr: i, size: 0}).size
            const pattern: string = printf('\%%%dl.*\%%%dc', i + 1, winid->winbufnr()->getbufline(i + 1)[0]->len())
            matchadd('QfHistoryEmpty', pattern, 1, -1, {window: winid})
        endif
    endfor

    setwinvar(winid, '&signcolumn', 'yes')
    sign_define('QfCurrent', {text: '>', texthl: 'QfHistoryCurrent'})
    sign_place(0, 'PopUpQfHistory', 'QfCurrent', winbufnr(winid), {
        lnum: Xgetlist({nr: 0}).nr + 1,
        priority: 10
    })

    return winid
enddef
