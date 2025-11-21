













if exists('g:loaded_VimMarkerInfo')
  finish
endif
let g:loaded_VimMarkerInfo = 1

command! -nargs=0 MarkerInfo call VimMarkerInfo#setWindow()
command! -nargs=0 MarkerInfoOff call VimMarkerInfo#closeWindow()

