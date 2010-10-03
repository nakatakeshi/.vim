" File: jump2sub.vim
" Author: Takeshi Nakata (nakatatakeshi AT gmail DOT com)
" Version: 0.1
" Last Modified: Oct 01, 2010
" Copyright: Copyright (C) 2002-2010 Takeshi Nakata
"
" -----------------
" Description 
" -----------------
"
"   jump to definition of subroutine which the word current cusor is on by typing shotcut key.
"     But ,jump only if selected word exists subroutine in current file...
"
" -------------------
" Installation and How to use
" -------------------
"
"   Download this file to /path/to/.vim/plugin/
"   Then add .vimrc this configuration.
"
" --------------------------------------
" noremap ss :call Jump2sub()<ENTER>
" ---------------------------------------
" * you can change the shortcut key 'ss' as you like.
" 
"  then, type 'ss' when cursor placed of some words.
"

if exists('perl_jump_to_sub')
  finish
endif
let perl_jump_to_sub = 1

" activate filetype plugin 
":filetype plugin on
" add path
"do not judge [$&/] as part of filename when cmd called

function! Jump2sub()
  let l:wrapscan_flag = &wrapscan

  exe ":mark'"
  setlocal iskeyword=a-z,A-Z,48-57,_,
  let l:word = expand('<cword>')
  setlocal iskeyword<
  
  exe ":1"
  try
    " throw E385 if not found 
    :set nowrapscan
    exe "/sub ".word
  catch/E385/
    " move to back
    exe "''"
  endtry
  call Set_wrapscan_if_on(wrapscan_flag)
endfunction

function! Set_wrapscan_if_on(flag)
  if a:flag == 1
    :set wrapscan
  endif
endfunction


