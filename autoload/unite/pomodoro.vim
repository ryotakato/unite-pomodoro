let s:save_cpo = &cpo
set cpo&vim


let g:unite_pomodoro_data_directory = expand(get(g:, 'unite_pomodoro_data_directory', unite#get_data_directory()))


let s:pomodoro_file = printf('%s/pomodoro/pomodoro.txt', g:unite_pomodoro_data_directory)


function! unite#pomodoro#init()
  if empty(glob(s:pomodoro_file))
    call writefile([], s:pomodoro_file)
  endif
endfunction

function! unite#pomodoro#struct(line)
  let words = split(a:line, ',') 

  return {
        \ 'id': words[0],
        \ 'title': words[1],
        \ 'budget': words[2],
        \ 'actual': words[3],
        \ 'status': words[4],
        \ 'line': a:line,
        \ }
endfunction

function! unite#pomodoro#select(pattern)
  let pomodoro_list = map(readfile(s:pomodoro_file), 'unite#pomodoro#struct(v:val)')
  return empty(a:pattern) ? pomodoro_list : filter(pomodoro_list, a:pattern)
endfunction

function! unite#pomodoro#all()
  return unite#pomodoro#select([])
endfunction

function! unite#pomodoro#update(structs)
  call writefile(
        \ map(a:structs, 'join([v:val.id, v:val.title, v:val.budget, v:val.actual, v:val.status], ",")'),
        \ s:pomodoro_file)
endfunction

function! unite#pomodoro#new(id, title, budget)
  return unite#pomodoro#struct(join([a:id, a:title, a:budget, 0, '[ ]'], ','))
endfunction

function! unite#pomodoro#add(title, budget)
  let title = unite#pomodoro#trim(a:title)
  let budget = unite#pomodoro#trim(a:budget)
  let pomodoro = unite#pomodoro#new(strftime("%Y%m%d_%H%M%S"), title, budget)
  call unite#pomodoro#update(insert(unite#pomodoro#all(), pomodoro))
  
endfunction


function! unite#pomodoro#delete(pomodoro_list)
  let all_list = unite#pomodoro#all()
  for pomodoro in a:pomodoro_list
    call filter(all_list, 'v:val.id != pomodoro.id')
  endfor
  call unite#pomodoro#update(all_list)
endfunction

function! unite#pomodoro#edit(pomodoro)
  let after_title = unite#util#input(a:pomodoro.title.'->', a:pomodoro.title, '')
  let after_budget = unite#util#input(a:pomodoro.budget.'->', a:pomodoro.budget, '')
  let after_actual = unite#util#input(a:pomodoro.actual.'->', a:pomodoro.actual, '')
  let after_status = unite#util#input(a:pomodoro.status.'->', a:pomodoro.status, '')

  let a:pomodoro.title = after_title
  let a:pomodoro.budget = after_budget
  let a:pomodoro.actual = after_actual
  let a:pomodoro.status = after_status

  let conv = map(unite#pomodoro#all(), "v:val.id == a:pomodoro.id ? a:pomodoro : v:val")
  call unite#pomodoro#update(conv)
endfunction

function! unite#pomodoro#finito(pomodoro)
  let a:pomodoro.status = "[x]"

  let conv = map(unite#pomodoro#all(), "v:val.id == a:pomodoro.id ? a:pomodoro : v:val")
  call unite#pomodoro#update(conv)
endfunction

function! unite#pomodoro#trim(str)
  return substitute(a:str, '^\s\+\|\s\+$', '', 'g')
endfunction



let s:pomodoro_second = 0
let s:run_pomodoro = {}

function! unite#pomodoro#start(pomodoro)

  if !empty(s:run_pomodoro)
    echo "Already Running pomodoro : ".s:run_pomodoro.title
  else

    let userConfig = get(g:, 'unite_pomodoro', {})
    if !empty(userConfig)
      if has_key(userConfig, 'minute')
        let minute = userConfig.minute
      else
        let minute = 25
      endif
    endif

    if unite#util#input_yesno("Start pomodoro(".minute."min) '".a:pomodoro.title."' ?")
      let s:pomodoro_second = minute * 60
      " TODO Vim 7.4 patch 1721 では、引数で渡した参照が解放されてしまうため、一時的にスクリプトローカルで回避
      let s:run_pomodoro = a:pomodoro
      let s:timer = timer_start(1000, function('unite#pomodoro#countdown') , { "repeat" : s:pomodoro_second})
    else
      echo "Not start pomodoro"
    endif
  endif


endfunction

let s:count = 0
function! unite#pomodoro#countdown(timer)
    let s:count += 1

    let userConfig = get(g:, 'unite_pomodoro', {})
    if !empty(userConfig)
      if has_key(userConfig, 'update_func')
        call userConfig.update_func()
      endif
    endif

    if s:count == s:pomodoro_second
        let s:count = 0

        let s:run_pomodoro.actual += 1
        let conv = map(unite#pomodoro#all(), "v:val.id == s:run_pomodoro.id ? s:run_pomodoro : v:val")

        call unite#pomodoro#update(conv)

        echo "End pomodoro : ".s:run_pomodoro.title

        let s:run_pomodoro = {}
    endif
endfunction


function! unite#pomodoro#show()
  echo unite#pomodoro#get_running_count()
endfunction

function! unite#pomodoro#get_running_count()
  if !empty(s:run_pomodoro)
    let min = s:count / 60
    let sec = s:count % 60
    return printf("pomodoro %02d:%02d", min, sec)
  else
    return ""
  endif
endfunction

function! unite#pomodoro#get_running_pomodoro()
    return s:run_pomodoro
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
