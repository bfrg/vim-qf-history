# vim-qf-history

Plugin to quickly navigate the `quickfix` and `location-list` stack using a
popup menu.


## Usage

#### `:Chistory`

Display the `quickfix` history in a popup window and make the selected list the
current list, similar to `:chistory`.

#### `:Lhistory`

Same as `:Chistory`, but display the `location-list` history of the current
window, similar to `:lhistory`.

#### Popup mappings

Use <kbd>j</kbd>, <kbd>k</kbd>, <kbd>g</kbd> and <kbd>G</kbd> to move the
cursorline in the menu, <kbd>[0-9]</kbd> selects the respective entry. Hit
<kbd>q</kbd> to cancel the popup menu, and <kbd>Enter</kbd> to make the selected
list the current list.


## Configuration

The appearance of the popup window can be changed through the following
highlight groups:

| Highlight group     | Description                               | Default   |
| ------------------- | ----------------------------------------- | --------- |
| `QfHistory`         | Popup window background and normal text.  | `Pmenu`   |
| `QfHistoryHeader`   | Top line of the quickfix-history list.    | `Title`   |
| `QfHistoryCurrent`  | Character marking the current error list. | `Title`   |
| `QfHistoryEmpty`    | Empty error list.                         | `Comment` |


## Installation

#### Manual Installation

Run the following commands in your terminal:
```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-qf-history
$ vim -u NONE -c "helptags vim-qf-history/doc" -c quit
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see `:help packages`.

#### Plugin Managers

Assuming [vim-plug][plug] is your favorite plugin manager, add the following to
your `vimrc`:
```vim
Plug 'bfrg/vim-qf-history'
```


## License

Distributed under the same terms as Vim itself. See `:help license`.

[plug]: https://github.com/junegunn/vim-plug
