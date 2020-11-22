" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         plugin/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Nov 22, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if get(g:, 'loaded_qfhistory') || !has('patch-8.1.1969')
    finish
endif
let g:loaded_qfhistory = 1

command Chistory call qfhistory#open(0)
command Lhistory call qfhistory#open(1)
