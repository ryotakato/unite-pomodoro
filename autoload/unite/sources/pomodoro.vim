" unite-pomodoro.vim
let s:save_cpo = &cpo
set cpo&vim


" define unite source
function! unite#sources#pomodoro#define()
  return s:source
endfunction

" source object
let s:source = {
      \ 'name' : 'pomodoro',
      \ 'description' : 'candidates for pomodoro',
      \ 'action_table' : {},
      \ }

" main process
function! s:source.gather_candidates(args, context) "{{{

  let candidates = []

  let dbs = []

  " set to unite candidates
  for db in dbs
    call add(candidates, {
          \ "word": db,
          \ "kind": "source",
          \ "action__source_name" : ["mongodb", db],
          \ })
    unlet db
  endfor

  return candidates
endfunction "}}}

" set to unite current prompt
function! s:set_prompt(str)
  let unite = unite#get_current_unite()
  let unite.prompt = a:str
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
