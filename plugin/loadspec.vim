" load spec file from app file
" if you open app/(controller|model|...etc)/(hoge).rb and type map key
" then open spec/$1/$2_spec.rb
" how setting
"   autocmd FileType ruby :noremap <C-t> :call LoadSpec('bel vne')<ENTER>

function! LoadSpec(open_command)
    let l:current_file_path = expand("%:p")
    let l:spec_file_path = substitute(l:current_file_path, "\/app\/", "/spec/", "")
    if l:spec_file_path =~ '/controllers/'
      let l:spec_file_path = substitute(l:spec_file_path, "\.rb$", "_controller_spec.rb", "")
    else
      let l:spec_file_path = substitute(l:spec_file_path, "\.rb$", "_spec.rb", "")
    endif

    if filereadable( l:spec_file_path )
      exe a:open_command . " " . l:spec_file_path
    else
      echo 'not exists' . l:spec_file_path
    endif
endfunction

