" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         plugin/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Feb 8, 2021
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if get(g:, 'loaded_qfhistory') || !has('patch-8.2.2257')
    finish
endif
let g:loaded_qfhistory = 1

command Chistory call qfhistory#open(v:false)
command Lhistory call qfhistory#open(v:true)
