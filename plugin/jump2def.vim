" File: jump2def.vim
" Author: Takeshi Nakata (nakatatakeshi AT gmail DOT com)
" Version: 0.1
" Last Modified: Oct 01, 2010
" Copyright: Copyright (C) 2002-2010 Takeshi Nakata
"
" -----------------
" Description 
" -----------------
"
"   jump to def which the word current cusor is on by typing shotcut key.
"     But ,jump only if selected word exists def in current file...
"
" -------------------
" Installation and How to use
" -------------------
"
"   Download this file to /path/to/.vim/plugin/
"   Then add .vimrc this configuration.
"
" --------------------------------------
" autocmd FileType ruby :noremap ss :call Jump2def()<ENTER>
" ---------------------------------------
" * you can change the shortcut key 'ss' as you like.
" 
"  then, type 'ss' when cursor placed of some words.
"

if exists('ruby_jump_to_def')
  finish
endif
let ruby_jump_to_def = 1

function! Jump2def()
  let l:wrapscan_flag = &wrapscan

  exe ":mark'"
  setlocal iskeyword=a-z,A-Z,48-57,_,=,!
  let l:word = expand('<cword>')
  setlocal iskeyword<
  
  exe ":1"
  try
    " throw E385 if not found 
    :set nowrapscan
    exe '/def \(self\.\)\='.word
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


