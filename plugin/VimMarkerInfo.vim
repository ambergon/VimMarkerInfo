













if exists('g:loaded_VimMarkerInfo')
  finish
endif
let g:loaded_VimMarkerInfo = 1

command! -nargs=0 MarkerInfo call VimMarkerInfo#setWindow()

" 自動で起動する設定
"{{{
if exists( 'g:startVimMarkerInfo' ) && g:startVimMarkerInfo == 1
    autocmd VimEnter * :MarkerInfo
endif
"}}}
