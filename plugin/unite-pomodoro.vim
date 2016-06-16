if exists('g:loaded_unite_pomodoro') && g:loaded_unite_pomodoro
    finish
endif
let g:loaded_unite_pomodoro = 1

let s:save_cpo = &cpo
set cpo&vim
 
command! -nargs=* -range=0 UnitePomodoroShow call unite#pomodoro#show()

let &cpo = s:save_cpo
unlet s:save_cpo
