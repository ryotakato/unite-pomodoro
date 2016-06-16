let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#pomodoro#define()
  return s:kind
endfunction

let s:kind = {
      \ 'name' : 'pomodoro',
      \ 'default_action' : 'start',
      \ 'action_table': {},
      \ 'is_selectable': 0,
      \ 'parents': ['word'],
      \}

let s:kind.action_table.start = { 'description' : 'start selected pomodoro', 'is_quit': 1 }
function! s:kind.action_table.start.func(candidate)
  call unite#pomodoro#start(unite#pomodoro#struct(a:candidate.source__line))
endfunction

let s:kind.action_table.delete = { 'description' : 'delete pomodoro', 'is_selectable': 1 }
function! s:kind.action_table.delete.func(candidates)
  let list = []
  if unite#util#input_yesno("Delete Selected Pomodoro ?")
    for candidate in a:candidates
      call add(list, unite#pomodoro#struct(candidate.source__line))
    endfor
    call unite#pomodoro#delete(list)
  endif

endfunction

let s:kind.action_table.edit = { 'description' : 'edit pomodoro'  }
function! s:kind.action_table.edit.func(candidate)
  if unite#util#input_yesno("Edit Selected Pomodoro ?")
    call unite#pomodoro#edit(unite#pomodoro#struct(a:candidate.source__line))
  endif
endfunction

let s:kind.action_table.finito = { 'description' : 'finito pomodoro'  }
function! s:kind.action_table.finito.func(candidate)
  if unite#util#input_yesno("Finito Selected Pomodoro ?")
    call unite#pomodoro#finito(unite#pomodoro#struct(a:candidate.source__line))
  endif
endfunction

"let s:parent_kind = {
"      \ 'is_quit': 0,
"      \ 'is_invalidate_cache': 1,
"      \ }
"
"call extend(s:kind.action_table.start, s:parent_kind, 'error')

let &cpo = s:save_cpo
unlet s:save_cpo
