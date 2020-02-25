# vim-qf-history

Plugin to quickly navigate Vim's `quickfix` and `location-list` history using a
popup menu.

<dl>
  <p align="center">
  <img src="https://user-images.githubusercontent.com/6266600/74968593-554a3c00-541b-11ea-8a82-f6d99357a007.png" width="480"/>
  </p>
</dl>


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
cursorline in the menu, <kbd>0</kbd> to <kbd>9</kbd> select the respective
entry. <kbd>0</kbd> always selects the last error list in the stack (most recent
one). Press <kbd>q</kbd> to cancel the popup menu, and <kbd>Enter</kbd> to make
the selected list the current list.


## Configuration

### `g:qfhistory`

The appearance of the popup window can be configured through the dictionary
variable `g:qfhistory`. The following keys are supported:

| Key               | Description                                                         | Default                                     |
| ----------------- | ------------------------------------------------------------------- | ------------------------------------------- |
| `title`           | Whether to show a popup window title (`0` or `1`).                  | `1`                                         |
| `padding`         | List with numbers defining the padding inside the popup window.     | `[1,1,1,1]`                                 |
| `border`          | List with numbers (`0` or `1`) specifying whether to draw a border. | `[1,1,1,1]`                                 |
| `borderchars`     | List with characters used for drawing the window border.            | `['─', '│', '─', '│', '┌', '┐', '┘', '└']`  |
| `borderhighlight` | List with highlight group names used for drawing the border.        | `[QfHistory]`                               |

**Note:** when only one `borderchars` is specified, it is used for all sides.

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
<kbd>Leader</kbd><kbd>c</kbd><kbd>h</kbd> and
<kbd>Leader</kbd><kbd>l</kbd><kbd>h</kbd>, respectively:
```vim
nnoremap <Leader>ch :<C-u>Chistory<CR>
nnoremap <Leader>lh :<C-u>Lhistory<CR>
```

#### Appearance

![img][image-examples]

**Left:** no window border and no window title:
```vim
let g:qfhistory = {'border': [0,0,0,0], 'title': 0}
```

**Center:** border with round corners, padding on left and right side:
```vim
let g:qfhistory = {
    \ 'padding': [0,1,0,1],
    \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    \ 'borderhighlight': ['MyBoldPopupBorder']
    \ }
```

**Right:** same as center but without a window title
```vim
let g:qfhistory = {
    \ 'title': 0,
    \ 'padding': [0,1,0,1],
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


## License

Distributed under the same terms as Vim itself. See <kbd>:help license</kbd>.

[image-examples]: https://user-images.githubusercontent.com/6266600/74968239-cb01d800-541a-11ea-87f6-cb6ba9829395.png
[plug]: https://github.com/junegunn/vim-plug
