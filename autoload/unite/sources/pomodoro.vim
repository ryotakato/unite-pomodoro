let s:save_cpo = &cpo
set cpo&vim

call unite#pomodoro#init()

let s:source = {
      \ 'name':'pomodoro',
      \ "description" : "candidates from pomodoro",
      \ 'syntax' : 'uniteSource__Pomodoro',
      \ 'hooks' : {}
      \}

function! s:source.gather_candidates(args, context)
  let candidates = []
  let list = empty(a:args) ? unite#pomodoro#all() : unite#pomodoro#select(a:args)
  let running_pomodoro = unite#pomodoro#get_running_pomodoro()
  let running_pomodoro_id = empty(running_pomodoro) ? "" : running_pomodoro.id
  for pomodoro in list
    call add(candidates, {
          \   "word": join([pomodoro.title, pomodoro.id == running_pomodoro_id ? " Running " : ""]),
          \   "abbr": s:make_abbr(pomodoro, running_pomodoro_id),
          \   "kind": "pomodoro",
          \   "action__path": "",
          \   "source__line": pomodoro.line
          \ })
    unlet pomodoro
  endfor
  return candidates
endfunction

function! s:make_abbr(pomodoro, running_pomodoro_id)
  let abbr = ""
  let abbr .= "  "
  let abbr .= a:pomodoro.status
  let abbr .= " "
  let abbr .= unite#util#truncate_smart(a:pomodoro.title, 20, 0, "...")
  let abbr .= " "
  let abbr .= unite#util#truncate_smart("  ".a:pomodoro.actual, 2, 2, "")
  let abbr .= " / "
  let abbr .= unite#util#truncate_smart("  ".a:pomodoro.budget, 2, 2, "")

  if a:pomodoro.id == a:running_pomodoro_id
    let abbr .= "   Running!!!!"
  endif
  
  return abbr
endfunction

function! s:source.hooks.on_syntax(args, context)
  
  syntax match uniteSource__Pomodoro_Status /\[.\]/
        \ contained containedin=uniteSource__Pomodoro
  highlight default link uniteSource__Pomodoro_Status Statement

  syntax match uniteSource__Pomodoro_Title /\s\+[0-9]*\s\/\s\+[0-9]*/
        \ contained containedin=uniteSource__Pomodoro
  highlight default link uniteSource__Pomodoro_Title Function

  syntax match uniteSource__Pomodoro_Running /\sRunning!!!!\s/
        \ contained containedin=uniteSource__Pomodoro
  highlight default link uniteSource__Pomodoro_Running PreProc

endfunction



let s:source_new = {
      \ 'name':'pomodoro/new',
      \ "description" : "add new pomodoro",
      \ 'syntax' : 'uniteSource__Pomodoro',
      \ 'hooks' : {}
      \}
function! s:source_new.hooks.on_init(args, context) abort "{{{
  let pomodoro_title = get(a:args, 0, '')   
  if pomodoro_title ==# ''
    let pomodoro_title = unite#util#input('New Pomodoro Title: ', '', '', s:source_new.name)
  endif

  let pomodoro_budget = get(a:args, 1, '')   
  if pomodoro_budget ==# ''
    let pomodoro_budget = unite#util#input('New Pomodoro Budget: ', '', '', s:source_new.name)
  endif

  call unite#pomodoro#add(pomodoro_title, pomodoro_budget)

endfunction "}}}

function! s:source_new.gather_candidates(args, context)
  return s:source.gather_candidates(a:args, a:context)
endfunction

function! unite#sources#pomodoro#define()
  return [s:source, s:source_new]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
