vim9script
# ==============================================================================
# Display all quickfix lists in the stack and switch to selected list
# File:         plugin/qfhistory.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-qf-history
# Last Change:  May 18, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

if get(g:, 'loaded_qfhistory')
    finish
endif
g:loaded_qfhistory = 1

import autoload 'qfhistory.vim'

command Chistory qfhistory.Open(false)
command Lhistory qfhistory.Open(true)
