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
  if filereadable(cur_file) 
    exe ":e ". cur_file
    return
  endif
  call writefile([ cur_file ], '/tmp/vimdebug')

  let l:path     = &l:path
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
endfunction

call OpenByPackage()

