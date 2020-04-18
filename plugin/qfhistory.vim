" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         plugin/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Apr 19, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if exists('g:loaded_qfhistory') || !has('patch-8.1.1969')
    finish
endif
let g:loaded_qfhistory = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

command! Chistory call qfhistory#open(0)
command! Lhistory call qfhistory#open(1)

let &cpoptions = s:cpo_save
unlet s:cpo_save
