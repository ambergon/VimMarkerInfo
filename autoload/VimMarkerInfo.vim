




" let g:mark_replace = [["^ *","",""],["^Function","Func",""],["^function","func",""],["{{{","","g"],["}}}","","g"]]









" マーカーとして使用する名前群
let s:local_list ='abcdefghijklmnopqrstuvwxyz'
let s:global_list ='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
" 専用バッファの名前
let s:VimMarkerInfoBuffer ='MarkerInfoWindow://'
" m' の自動更新間隔
"{{{
if !exists("g:MarkerTimer")
    let g:MarkerTimer = 8000
endif
"}}}
" 専用ウィンドウの幅
"{{{
if !exists("g:MarkerInfoWindowSize")
    let g:MarkerInfoWindowSize =35
endif
"}}}
" サインに使用するアルファベット小文字
"{{{
if !exists("g:marker_window_local")
    let g:marker_window_local=s:local_list
endif
"}}}
" サインに使用するアルファベット大文字
"{{{
if !exists("g:marker_window_global")
    let g:marker_window_global=s:global_list
endif
"}}}

" 専用ウィンドウの置換処理
"{{{
if !exists("g:mark_replace")
    let g:mark_replace =[["","",""]]
endif
"}}}


" 専用バッファの ': を更新する。
"{{{
function! VimMarkerInfo#checkLast()
    " バッファが存在しなければキャンセル
    let l:winid = bufwinid(bufnr( s:VimMarkerInfoBuffer ))
    if l:winid is -1
        call timer_stop( s:timer )
        return
    endif

    " let l:now = "': " . getline( getpos( "''" )[1] )
    let l:now = "': " .  VimMarkerInfo#replace( getline( getpos( "''" )[1] ))
    let l:old = getbufoneline( s:VimMarkerInfoBuffer , 1)
    if l:now != l:old 
        call setbufline(s:VimMarkerInfoBuffer, 1 , l:now )
    endif
endfunction
"}}}

" ウィンドウサイズの変更を修復する。
"{{{
function! VimMarkerInfo#resizeMarkerInfoWindow()
    " そのバッファを表示しているウィンドウIDを取得
    let l:winid = bufwinid(bufnr( s:VimMarkerInfoBuffer ))
    let l:current_winid = win_getid()
    " 現在のウィンドウが専用バッファじゃなければ。
    if l:winid isnot -1 
        if l:winid is l:current_winid 
            call win_execute( l:winid , 'wincmd H')
            call win_execute( l:winid , 'vert resize' . g:MarkerInfoWindowSize)
        endif
    endif
endfunction
"}}}

" マークを付けるたびに自動で再表示する。
"{{{
function! VimMarkerInfo#setMark() 
    let l:char = nr2char(getchar())
    execute 'mark ' . l:char
    call VimMarkerInfo#signSet()
    call VimMarkerInfo#openMarkerWindow()
endfunction
"}}}
" M + other でマークを削除し更新する。
"{{{
function! VimMarkerInfo#RemoveMark()
    let l:char = nr2char(getchar())
    execute 'delmark ' . l:char
    call VimMarkerInfo#signSet()
    call VimMarkerInfo#openMarkerWindow()
endfunction
"}}}

" 専用のウィンドウを開く。
"{{{
function! VimMarkerInfo#openMarkerWindow()

    " そのバッファを表示しているウィンドウIDを取得
    let l:winid = bufwinid(bufnr( s:VimMarkerInfoBuffer ))
    " 無ければ再設置
    if l:winid is -1
        let l:current_winid = win_getid()
        execute('aboveleft ' . g:MarkerInfoWindowSize . 'vs ' . s:VimMarkerInfoBuffer)
        wincmd H
        execute('vert resize ' . g:MarkerInfoWindowSize)
        " equalalwaysが有効下で高さと幅を固定する。
        setl winfixwidth
        setl winfixheight
        " 他のバッファを表示できないウィンドウとする。
        setl winfixbuf

        " 別のハイライトを使用する。
        setl wincolor=MoreMsg

        "qで終了
        " nnoremap <buffer> q :q<CR>

        "listに載せない
        setl nobuflisted
        "折り返さない
        setl nowrap
        setl nonumber
        setl norelativenumber
        setl buftype=nowrite
        "bufexist
        setl bufhidden=wipe
        " 前のウィンドウに戻す。
        call win_gotoid(l:current_winid)
    endif
    " メインの処理が終わったタイミングで実行する。
    call timer_start( 0 , {-> VimMarkerInfo#updateBuffer()})

endfunction
"}}}

" 専用バッファに情報を入力する。
"{{{
function VimMarkerInfo#updateBuffer()
    let l:x=0
    call deletebufline(s:VimMarkerInfoBuffer,1,"$")

    " 直前まで使用していた場所を表示する。
    if getpos( "''" )[1] != 0
        let l:x = l:x+1
        " let l:line = "': " .  getline(getpos( "''" )[1])
        let l:line = "': " .  VimMarkerInfo#replace( getline(getpos( "''" )[1]))
        call setbufline(s:VimMarkerInfoBuffer,  l:x, l:line )
        let l:x = l:x+1
        call setbufline(s:VimMarkerInfoBuffer,  l:x, "=============================")
    endif

    ""local
    for l:local_word in g:marker_window_local
        if getpos("'" . l:local_word)[1] != 0
            let l:x = l:x+1
            call setbufline(s:VimMarkerInfoBuffer,  l:x, VimMarkerInfo#windowLocalMark(l:local_word))
        endif
    endfor
    let l:x = l:x+1
    call setbufline(s:VimMarkerInfoBuffer,  l:x, "=============================")
    ""global
    for l:global_word in g:marker_window_global
        if getpos("'" . l:global_word)[1] != 0
            let l:x = l:x+1
            call setbufline(s:VimMarkerInfoBuffer,  l:x, VimMarkerInfo#windowGlobalMark(l:global_word))
        endif
    endfor
endfunction
"}}}


" 処理開始
"{{{
function! VimMarkerInfo#setWindow()
    call VimMarkerInfo#setHighLight()
    call VimMarkerInfo#openMarkerWindow()
    call VimMarkerInfo#signSet()
    "m -> 何かで起動。
    nnoremap <expr> m VimMarkerInfo#setMark()
    nnoremap <expr> M VimMarkerInfo#RemoveMark()
    augroup VimMarkerInfo
        autocmd WinEnter * call VimMarkerInfo#resizeMarkerInfoWindow()
        autocmd WinEnter,BufWinEnter,BufEnter * call VimMarkerInfo#signSet()
        autocmd BufWinEnter * call VimMarkerInfo#updateBuffer()
        " autocmd BufNewFile * call timer_start( g:MarkerTimer , {->VimMarkerInfo#updateBuffer()} , {'repeat': -1})
    augroup end
    " 一定間隔で m' を監視し、更新する。
    let s:timer = timer_start( g:MarkerTimer , {->VimMarkerInfo#checkLast()} , {'repeat': -1})
endfunction
"}}}
" 処理終了
"{{{
function! VimMarkerInfo#closeWindow()
    call sign_unplace( 'local_group')
    call sign_unplace( 'global_group')
    call timer_stop( s:timer )
    autocmd! VimMarkerInfo
    if bufexists(s:VimMarkerInfoBuffer)
        execute("bw " . s:VimMarkerInfoBuffer)
    endif
endfunction
"}}}



function! VimMarkerInfo#replace( text )
    let l:res = a:text
    for l:replace in g:mark_replace
        let l:res = substitute( l:res ,replace[0],replace[1],replace[2])
    endfor
    return l:res
endfunction

function! VimMarkerInfo#windowLocalMark(word)
    let l:line = VimMarkerInfo#replace(getline(getpos("'" . a:word)[1]))
    return a:word . ": " . l:line
endfunction

function! VimMarkerInfo#windowGlobalMark(word)
    let l:line = bufname(getpos("'" . a:word)[0])
    return a:word . ": " . l:line
endfunction

" 指定したマーカの目印(sign)を設置する。
"{{{
function! VimMarkerInfo#signSet()
    ""すべて解除
    call sign_unplace( 'local_group')
    call sign_unplace( 'global_group')
    
    for l:local_word in s:local_list
        if getpos("'" . l:local_word)[1] != 0
            call sign_place( 0, 'local_group', 'local_' . l:local_word, bufnr(),{'lnum' : getpos("'" . l:local_word)[1], 'priority' : 10 })
        endif
    endfor
    
    ""global_mark
    for l:global_word in s:global_list
        "getpos = 0行 = 未設定 だとエラー
        if getpos("'" . l:global_word)[1] != 0
            "getBufnum = current
            if getpos("'" . l:global_word)[0] == bufnr()
                call sign_place( 0, 'global_group', 'global_' . l:global_word, bufnr(),{'lnum' : getpos("'" . l:global_word)[1], 'priority' : 20 })
            endif
        endif
    endfor
endfunction
"}}}
" マーカを表示するデザインを指定する。
"{{{
function! VimMarkerInfo#setHighLight()
    "windowsのカラーテーブル
    if has( 'win64' )
        ""local_markの色を定義
        hi LocalMark ctermfg=254 ctermbg=242 guifg=#f9f1a5 guibg=#13a10e
        ""global_markの色を定義
        hi GlobalMark ctermfg=113 ctermbg=175 guifg=#0036da guibg=#f2f2f2
    "linuxを想定
    else
        ""local_markの色を定義
        "fg #dfff00 
        "bg #008700
        hi LocalMark ctermfg=190 ctermbg=28 guifg=#f9f1a5  guibg=#13a10e
        ""global_markの色を定義
        hi GlobalMark ctermfg=20 ctermbg=15 guifg=#0036da guibg=#f2f2f2
    endif

    "local_mark
    for s:local_word in s:local_list
        call sign_define("local_" . s:local_word,{"text" : s:local_word . ">", "texthl" : "LocalMark"})
    endfor
    "global_mark
    for l:global_word in s:global_list
        call sign_define("global_" . l:global_word,{"text" : l:global_word . ">", "texthl" : "GlobalMark"})
    endfor
endfunction
"}}}









