unite-pomodoro
==============

vim plugin. unite source for using Pomodoro Technique.


## Requires

* vim +timer (later than vim patch 7.4.1578)
* Unite.vim


## Config

.vimrc 

```vim

" this is pomodoro technic one pomodoro minute(default 25)
let g:unite_pomodoro = {
\  'minute' : 25
\  }

" it is executed every one second
" use for display pomodoro time
" this sample is for lightline.vim"
function! g:unite_pomodoro.update_func()
  if match(getwinvar(winnr(), "&statusline"), "%{lightline#link()}") != -1
    call lightline#update()
  endif
endfunction


```


if you using lightline.vim, this is  lightline config
```vim

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'unite_pomodoro', 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'unite_pomodoro': 'unite#pomodoro#get_running_count'
      \ }
      \ }

```




## LICENSE

This software is released under the MIT License, see LICENSE.txt.

