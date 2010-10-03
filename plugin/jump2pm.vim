" File: jump2pm.vim
" Author: Takeshi Nakata (nakatatakeshi AT gmail DOT com)
" Version: 0.1
" Last Modified: Oct 01, 2010
" Copyright: Copyright (C) 2002-2010 Takeshi Nakata
"
" -----------------
" Description 
" -----------------
"
"   jump to pm file which package name is current cusor by typing shotcut key.
"     But , do not jump from instance variable string of some class...
"
" -------------------
" Installation and How to use
" -------------------
"
"   Download this file to /path/to/.vim/plugin/
"   Then add .vimrc this configuration.
"
" --------------------------------------
" " split window vertically and jump to pm fine.
" noremap fg :call Jump2pm('vne')<ENTER>
" " jump to pm file in current window
" noremap ff :call Jump2pm('e')<ENTER>
" " split window horizontal, and ...
" noremap fd :call Jump2pm('sp')<ENTER>
" ---------------------------------------
" * you can change the shortcut key 'fg' and so on as you like.
" 
"  then, type 'fg' or 'ff'  or 'fd' when cursor placed of some package name.
"
" ----------------------
" Details of this plugin
" ----------------------
"
"   1. About Search Directory
"     - this plugin search pm file from @INC dir and 'some library directory'.
"       (But, this plugin do not search if your code define "use lib '/path/to/lib';"
"        statement in your code)
"
"     - 'some library directory' are like this.
"       - you can add path calling or writing .vimrc like this.
"       ----------------------------
"       :setlocal path+=/path/to/lib
"       ----------------------------
"       - this plugin add search library path by climbing dir hierarchy 
"         from opend file, and if exsist some dir name in the climbing dir path.
"         some dir is ['lib', 'inc'] by default.
"         if you want to add search lib dirname
"         add .vimrc this configuration.
"         -----------------------------------------------------
"         let search_lib_dir = [ 'include', 'module' , 'etc' ]
"         -----------------------------------------------------
"
"   2. Jumping to method 
"     - if current string is like "Class::method" (static method call),
"       jump to Class.pm and move cursor to "sub method" if exist 
"       or move to "method" in fist line of flle if exist.

if exists('perl_jump_to_pm')
  finish
endif
let perl_jump_to_pm = 1

" activate filetype plugin 
:filetype plugin on
" add path
"do not judge [$&/] as part of filename when cmd called
autocmd FileType perl set isfname-=$
autocmd FileType perl set isfname-=&
autocmd FileType perl set isfname-=/
"judge > as part of filename when cmd called
autocmd FileType perl set isfname+=\>

" overload perl.vim
" hook when gf called and can't find file from path and cfile
autocmd FileType perl set includeexpr=Jump2pm('gf')

function! Jump2pm(cmd)

  let l:wrapscan_flag = &wrapscan
  let l:cur_lib_path  = Get_current_lib_path()

  let l:pm_path  = substitute(expand("<cfile>"),'::','/','g')
  let l:method = ''
  " if include cfile string -> 
  if l:pm_path =~ '->'
    let l:tmp  = substitute(pm_path,'\s*->.*$','','g')
    let l:method  = substitute(substitute(substitute(pm_path ,tmp,'','g'),'->','','g'),'\s','','g')
    let l:pm_path = l:tmp
  endif

  let l:pm_path  = substitute(pm_path,'$','.pm','')

  let l:path     = &l:path
  if l:cur_lib_path != []
    let l:path = l:path . ',' . join(l:cur_lib_path, ',')
  endif

  let l:path_arr = split(path,',')

  for i in range(0,len(path_arr)-1)
    let a_path = path_arr[i]
    if filereadable(a_path . '/' . pm_path)
      if a:cmd == 'gf'
        return a_path . '/' . pm_path
      else
        exe "bel ".a:cmd . " " . a_path . '/' . pm_path
        "if cfile includes -> try to jump line exists 'sub methodname'
        if l:method != ''
          " move to head of file
          exe ":1"
          try
            " throw E385 if not found when search / cmd executed
            :set nowrapscan
            exe "/sub ".method
          catch/E385/
          endtry
        call Set_wrapscan_if_on(wrapscan_flag)
        endif
        return
      endif
    endif
  endfor

  " when cfile is type 'Hoge::static_method' return path/to/Hoge.pm
  let l:new_pm_path = substitute(pm_path,'/[^(/)]*.pm$','','g')
  let l:const = substitute(pm_path,new_pm_path.'/','','g')
  let l:const = substitute(const,'.pm$','','g')

  let l:new_pm_path = new_pm_path . ".pm"
  for i in range(0,len(path_arr)-1)
    let a_path = path_arr[i]
    if filereadable(a_path . '/' . new_pm_path)
      if a:cmd == 'gf'
        return a_path . '/' . new_pm_path
      else
        exe "bel " . a:cmd . " " . a_path . '/' . new_pm_path
        exe ":1"
        try
          " throw E385 if not found when search / cmd executed
          :set nowrapscan
          exe "/sub ".const
        catch/E385/
          exe ":1"
          try
            exe "/".const
          catch/E385/
          endtry
        endtry
        call Set_wrapscan_if_on(wrapscan_flag)
        return
      endif
    endif
  endfor
endfunction

function! Set_wrapscan_if_on(flag)
  if a:flag == 1
    :set wrapscan
  endif
endfunction

function! Get_current_lib_path()
  let l:ret_lib_dir_arr = []
  " get full file path of current opened file
  let l:cur_file      = expand("%:p")

  let s:search_lib_dir = [ 'lib' , 'inc' ]
  if exists("g:search_lib_dir")
     call extend( s:search_lib_dir, g:search_lib_dir)
  endif

  while 1
    if l:cur_file == ''
      return l:ret_lib_dir_arr
    endif
    for i in range(0,len(s:search_lib_dir)-1)
      let l:cur_file = substitute(substitute(cur_file,'/[^(/)]*$','','g'),'$','/' . s:search_lib_dir[i] ,'g')
      if isdirectory(cur_file) 
        call add(l:ret_lib_dir_arr, l:cur_file)
      endif
    endfor
    let l:cur_file = substitute(cur_file,'/[^(/)]*$','','g')
  endwhile
  return l:ret_lib_dir_arr
endfunction
