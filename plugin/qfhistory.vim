vim9script
# ==============================================================================
# Display all quickfix lists in the stack and switch to selected list
# File:         plugin/qfhistory.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-qf-history
# Last Change:  Dec 23, 2023
# License:      Same as Vim itself (see :h license)
# ==============================================================================

import autoload '../autoload/qfhistory.vim'

command Chistory qfhistory.Open(false)
command Lhistory qfhistory.Open(true)
