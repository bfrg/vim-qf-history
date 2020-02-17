" ==============================================================================
" Display all quickfix lists in the stack and switch to selected list
" File:         plugin/qfhistory.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-history
" Last Change:  Feb 17, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if exists('g:loaded_qfhistory')
    finish
endif
let g:loaded_qfhistory = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

command! Chistory call qfhistory#open(0)
command! Lhistory call qfhistory#open(1)

nnoremap <silent> <plug>(chistory-popup) :<c-u>call qfhistory#open(0)<cr>
nnoremap <silent> <plug>(lhistory-popup) :<c-u>call qfhistory#open(1)<cr>

let &cpoptions = s:cpo_save
unlet s:cpo_save
