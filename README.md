# vim-qf-history

Plugin to quickly navigate Vim's `quickfix` and `location-list` history using a
popup menu.

<dl>
  <p align="center">
  <img src="https://user-images.githubusercontent.com/6266600/75272505-581fa500-57fe-11ea-844d-9e0f6dc334a6.png" width="480"/>
  </p>
</dl>

**Background**

Vim remembers the ten last used quickfix lists, and the ten last used
location-lists for each window. The entire quickfix and location-list stack can
be displayed with <kbd>:chistory</kbd> and <kbd>:lhistory</kbd>, respectively.
Older quickfix lists are accessed through <kbd>:colder</kbd> and
<kbd>:cnewer</kbd>, or directly with <kbd>:[count]chistory</kbd> (and similar
for location-lists). See <kbd>:help quickfix-error-lists</kbd> for more details.

This plugin will display the quickfix and location-list stack in a popup menu
allowing the user to easily switch to an earlier error list. If one of the lists
contains different error types, the total number of each error type (E, W, I, N)
is shown along with the total number of entries. Unknown error types are
displayed in column "?", and empty lists are greyed out.


## Requirements

Vim `>= 8.1.1969`


## Usage

#### `:Chistory`

Display the `quickfix` history in a popup window and make the selected list the
current list, similar to <kbd>:[count]chistory</kbd>.

#### `:Lhistory`

Same as <kbd>:Chistory</kbd>, but display the `location-list` history of the
current window. This is similar to Vim's builtin command
<kbd>:[count]lhistory</kbd>.

#### Popup mappings

Use <kbd>j</kbd>, <kbd>k</kbd>, <kbd>g</kbd> and <kbd>G</kbd> to move the
cursorline in the menu, or <kbd>0</kbd> to <kbd>9</kbd> to select the respective
entry directly. <kbd>0</kbd> will select the last error list in the stack (most
recent one) if there are less than ten lists. Press <kbd>q</kbd> to cancel the
popup menu, and <kbd>Enter</kbd> to make the selected list the current list.

**Note:** Pressing <kbd>0</kbd> to <kbd>9</kbd> will select and close the popup
window.

#### Autocommands

After switching the quickfix list through the popup menu, the `User` event
`CHistoryCmdPost` is executed, and similarly `LHistoryCmdPost` for the
location-list.

Examples:
```vim
" Print quickfix info of current list in command-line after switching lists
augroup qfhistory
    autocmd!
    autocmd User CHistoryCmdPost echo
        \ printf('Quickfix %d of %d (%d items): %s',
        \   getqflist({'nr': 0}).nr,
        \   getqflist({'nr': '$'}).nr,
        \   getqflist({'size': 0}).size,
        \   getqflist({'title': 0}).title
        \ )
augroup END

" Automatically open location-list window
augroup qfhistory
    autocmd!
    autocmd User LHistoryCmdPost lwindow
augroup END
```


## Configuration

### `g:qfhistory`

The appearance of the popup window can be configured through the dictionary
variable `g:qfhistory`. The following keys are supported:

| Key               | Description                                                         | Default                                    |
| ----------------- | ------------------------------------------------------------------- | ------------------------------------------ |
| `title`           | Whether to show a popup window title (`0` or `1`).                  | `1`                                        |
| `padding`         | List with numbers defining the padding inside the popup window.     | `[1, 1, 1, 1]`                             |
| `border`          | List with numbers (`0` or `1`) specifying whether to draw a border. | `[1, 1, 1, 1]`                             |
| `borderchars`     | List with characters used for drawing the window border.            | `['─', '│', '─', '│', '┌', '┐', '┘', '└']` |
| `borderhighlight` | List with highlight group names used for drawing the border.        | `['QfHistory']`                            |

**Note:** when only one `borderchars` or `borderhighlight` item is specified, it
is used on all sides.

### Highlighting

The highlighting of the popup window can be changed through the following
highlight groups:

| Highlight group     | Description                               | Default   |
| ------------------- | ----------------------------------------- | --------- |
| `QfHistory`         | Popup window background and normal text.  | `Pmenu`   |
| `QfHistoryHeader`   | Top line of the quickfix-history list.    | `Title`   |
| `QfHistoryCurrent`  | Character marking the current error list. | `Title`   |
| `QfHistoryEmpty`    | Empty error list.                         | `Comment` |

### Examples

#### Mappings

Open `quickfix` and `location-list` history with
<kbd>Leader</kbd>+<kbd>c</kbd>+<kbd>h</kbd> and
<kbd>Leader</kbd>+<kbd>l</kbd>+<kbd>h</kbd>, respectively:
```vim
nnoremap <Leader>ch :<C-u>Chistory<CR>
nnoremap <Leader>lh :<C-u>Lhistory<CR>
```

Or alternatively, if you're not using the default `Select-mode` mappings
(mnemonic: go history):
```vim
nnoremap gh :<C-u>Chistory<CR>
nnoremap gH :<C-u>Lhistory<CR>
```

#### Appearance

![img][image-examples]

**Left:** no window border and no window title:
```vim
let g:qfhistory = {'border': [0, 0, 0, 0], 'title': 0}
```

**Center:** border with round corners, padding on left and right side:
```vim
let g:qfhistory = {
    \ 'padding': [0, 1, 0, 1],
    \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    \ 'borderhighlight': ['MyBoldPopupBorder']
    \ }
```

**Right:** same as middle image but without a window title
```vim
let g:qfhistory = {
    \ 'title': 0,
    \ 'padding': [0, 1, 0, 1],
    \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    \ 'borderhighlight': ['MyBoldPopupBorder']
    \ }
```


## Installation

#### Manual Installation

Run the following commands in your terminal:
```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-qf-history
$ vim -u NONE -c "helptags vim-qf-history/doc" -c quit
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see <kbd>:help packages</kbd>.

#### Plugin Managers

Assuming [vim-plug][plug] is your favorite plugin manager, add the following to
your `vimrc`:
```vim
Plug 'bfrg/vim-qf-history'
```


## Credits

This plugin was inspired by the Vimways article [Colder quickfix lists][vimways]
written by [Nick Jensen][nickspoons].


## License

Distributed under the same terms as Vim itself. See <kbd>:help license</kbd>.

[vimways]: https://vimways.org/2018/colder-quickfix-lists
[nickspoons]: https://github.com/nickspoons
[image-examples]: https://user-images.githubusercontent.com/6266600/74968239-cb01d800-541a-11ea-87f6-cb6ba9829395.png
[plug]: https://github.com/junegunn/vim-plug
