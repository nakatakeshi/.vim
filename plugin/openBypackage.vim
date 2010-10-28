" File: openBypackage.vim
" Author: Takeshi Nakata (nakatatakeshi AT gmail DOT com)
" Version: 0.1
" Last Modified: Oct 01, 2010
" Copyright: Copyright (C) 2002-2010 Takeshi Nakata
"
" -----------------
" Description
" -----------------
"
"   open .pm file from package name.
"   if you type in command line like this,
"   $ vi Package::Hoge
"   then open Package/Hoge.pm
"   or ../Package/Hoge.pm
"   or ../[lib|inc]/Package/Hoge.pm
"   or ../../ (climbling)
"   or @INC's path/Package/Hoge.pm
"
" -------------------
" Installation and How to use
" -------------------
"
"   Download this file to /path/to/.vim/plugin/
"
" ----------------------
" Details of this plugin
" ----------------------
"
"   1. About Search Directory
"     - this plugin search pm file from @INC dir and 'some library directory'.
"
"     - 'some library directory' are like this.
"       - you can add path writing .vimrc like this.
"         -----------------------------------------------------
"         let search_lib_dir_opening = '/path/to/lib1,/path/to/lib2/'
"         -----------------------------------------------------

function! OpenByPackage()
  let cur_file  = expand("%:p")

  if filereadable(cur_file)
    return
  endif

  let cur_dir   = substitute(cur_file,'/[^(/)]*$','','g')
  let cur_file  = substitute(cur_file,cur_dir.'/','','g')
  let cur_file  = substitute(substitute(expand(cur_file),'::','/','g'),'$','.pm','')

  " search from defined path and @INC path
  " stolen from perl.vim
  let perlpath = system("perl -e 'print join(q/,/,@INC)'")
  if exists("g:search_lib_dir_opening")
     let perlpath = perlpath . ',' . g:search_lib_dir_opening
  endif

  let path_arr = split(perlpath, ',' )
  for i in range(0,len(path_arr)-1)
    let a_path = path_arr[i]
    if filereadable(a_path . '/' . cur_file)
      exe ":e ". a_path . '/' . cur_file
      return
    endif
  endfor

  " search for climbing current dir path
  if exists("g:search_lib_dir")
    let s:search_lib_dir = g:search_lib_dir
  else
    let s:search_lib_dir = [ '' , 'lib' , 'inc' ]
  endif

  while 1
    if l:cur_dir == ''
      return
    endif
    for i in range(0,len(s:search_lib_dir)-1)
      let l:tmp_dir = cur_dir . '/' . s:search_lib_dir[i]
      let l:tmp_file = tmp_dir . '/' . cur_file
      if filereadable(tmp_file)
        exe ":e " . tmp_file
        return
      endif
    endfor
    let l:cur_dir = substitute(cur_dir,'/[^(/)]*$','','g')
  endwhile
  return
endfunction

call OpenByPackage()

