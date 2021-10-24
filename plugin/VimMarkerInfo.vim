"""setting
"let g:marker_window_local = 'abcde'
"let g:marker_window_global = 'ABCDE'
"let g:mark_replace = [["","",""],["","","g"]]
"let g:MarkerInfoWindowSize =30

""""vim info
""Global
"# File marks:
""Local
"# History of marks within files (newest to oldest):

if exists('g:loaded_VimMarkerInfo')
  finish
endif
let g:loaded_VimMarkerInfo = 1

command! -nargs=0 MarkerInfo call VimMarkerInfo#setWindow()
command! -nargs=0 MarkerInfoOff call VimMarkerInfo#closeWindow()

"augroup VimMarkerInfoSetup
"    autocmd VimEnter * call VimMarkerInfo#setup()
"augroup end
"
"function! VimMarkerInfo#setup()
"    call VimMarkerInfo#setHighLight()
"endfunction

