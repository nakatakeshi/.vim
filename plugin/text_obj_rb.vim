if exists('g:loaded_textobj_rb')
  finish
endif

let g:loaded_textobj_rb = 1

" match Hoge.fuga
call textobj#user#plugin('dot', {
\   'dot': {
\     '*pattern*': '\w\+\(\.\w\+\)\+',
\     'select': ['a.', 'i.'],
\   }})


" match keyword: or Hoge::Fuga
call textobj#user#plugin('colon', {
\   'colon': {
\     '*pattern*': '\(\w\+\(::\w\+\)\+\)\|\(:\w\+\)\|\(\w\+:\)',
\     'select': ['a:', 'i:'],
\   }}) 

