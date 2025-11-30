





" ハイライトカラーの指定がない場合のデフォルト
"{{{
if !exists("g:sign_highlight_cui")
    let g:sign_highlight_cui=[ '254' , '242' , '113' , '0' ]
endif
"}}}
"{{{
if !exists("g:sign_highlight_gui")
    let g:sign_highlight_gui=[ '#f9f1a5' , '#13a10e' , '#0036da' , '#f2f2f2' ]
endif
"}}}

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
if !exists("g:VimMarkerInfoLocalSignList")
    let g:VimMarkerInfoLocalSignList='abcdefghijklmnopqrstuvwxyz'
endif
"}}}
" サインに使用するアルファベット大文字
"{{{
if !exists("g:VimMarkerInfoGlobalSignList")
    let g:VimMarkerInfoGlobalSignList='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
"}}}

" 専用ウィンドウの置換処理
" let g:mark_replace = [["^ *","",""],["^Function","Func",""],["^function","func",""],["{{{","","g"],["}}}","","g"]]
"{{{
if !exists("g:mark_replace")
    let g:mark_replace =[]
endif
"}}}
"{{{
if !exists("g:mark_replace_file")
    let g:mark_replace_file =[]
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
    if l:char =~ '^[a-zA-Z]$'
        execute 'mark ' . l:char
        call VimMarkerInfo#signSet()
        call VimMarkerInfo#openMarkerWindow()
    endif
    return ""
endfunction
"}}}
" M + other でマークを削除し更新する。
"{{{
function! VimMarkerInfo#RemoveMark()
    let l:char = nr2char(getchar())
    if l:char =~ '^[a-zA-Z]$'
        execute 'delmark ' . l:char
        call VimMarkerInfo#signSet()
        call VimMarkerInfo#openMarkerWindow()
    endif
    return ""
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

        "折り返さない
        setl nowrap
        setl nonumber
        setl norelativenumber
        "listに載せない bnextなどが聞かなくなるように。
        setl nobuflisted
        setl buftype=nofile
        setl bufhidden=wipe
        setl noswapfile
        " 前のウィンドウに戻す。
        call win_gotoid(l:current_winid)
    endif
    " メインの処理が終わったタイミングで実行する。
    call timer_start( 0 , {-> VimMarkerInfo#updateBuffer()})

endfunction
"}}}

" 専用バッファに情報を入力する。
"{{{
function! VimMarkerInfo#updateBuffer()
    " let l:winid = bufwinid(bufnr( s:VimMarkerInfoBuffer ))
    " if l:winid is -1
    "     return
    " endif

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
    for l:local_word in g:VimMarkerInfoLocalSignList
        if getpos("'" . l:local_word)[1] != 0
            let l:x = l:x+1
            call setbufline(s:VimMarkerInfoBuffer,  l:x, VimMarkerInfo#windowLocalMark(l:local_word))
        endif
    endfor
    let l:x = l:x+1
    call setbufline(s:VimMarkerInfoBuffer,  l:x, "=============================")
    ""global
    for l:global_word in g:VimMarkerInfoGlobalSignList
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
        autocmd!
        autocmd WinEnter                * call VimMarkerInfo#resizeMarkerInfoWindow()
        autocmd WinEnter,BufWinEnter    * call VimMarkerInfo#signSet()
        autocmd WinEnter,BufWinEnter    * call VimMarkerInfo#updateBuffer()
        " autocmd WinClosed,WinEnter   * call VimMarkerInfo#autoClose()
        autocmd WinEnter * call VimMarkerInfo#autoClose()
    augroup end
    execute( 'autocmd BufWipeout ' . s:VimMarkerInfoBuffer . ' ++once call VimMarkerInfo#closeWindow()' )
    " 一定間隔で m' を監視し、更新する。
    let s:timer = timer_start( g:MarkerTimer , {->VimMarkerInfo#checkLast()} , {'repeat': -1})
endfunction
"}}}
" 処理終了
"{{{
function! VimMarkerInfo#closeWindow()
    nunmap m
    nunmap M
    call sign_unplace( 'local_group')
    call sign_unplace( 'global_group')
    call timer_stop( s:timer )
    autocmd! VimMarkerInfo
endfunction
"}}}
" ウィンドウを閉じた時、ほかに編集中のバッファがなければそのまま終了する。
"{{{
function! VimMarkerInfo#autoClose()
    " echo winnr('$') 
    " echo bufname('%')
    " echo filter( range( 1 , bufnr( '$' ) ) , 'getbufvar( v:val , "&modified" )' )
    " ウィンドウが1つのみか確認
    if winnr('$') == 1
        " 最後のウィンドウのバッファ名を取得
        let l:bufname = bufname('%')
        " バッファ名を確認
        if l:bufname ==# s:VimMarkerInfoBuffer
            " 未保存のバッファに編集中が無ければ。 rangeの中の変数v:xxx
            let l:modified_buffers = filter( range( 1 , bufnr( '$' ) ) , 'getbufvar( v:val , "&modified" )' )
            " 無ければ終了。
            if empty( l:modified_buffers )
                quit
            endif
        endif
    endif
endfunction
"}}}

" 表示する行を置換。
"{{{
function! VimMarkerInfo#replace( text )
    let l:res = a:text
    for replace in g:mark_replace
        let l:res = substitute( l:res ,replace[0],replace[1],replace[2])
    endfor
    return l:res
endfunction
"}}}
" 表示するファイル名を置換。
"{{{
function! VimMarkerInfo#replacePath( path )
    let l:res = a:path
    for replace in g:mark_replace_file
        let l:res = substitute( l:res ,replace[0],replace[1],replace[2])
    endfor
    return l:res
endfunction
"}}}
" マーカーで保存されている行を返す。
"{{{
function! VimMarkerInfo#windowLocalMark(word)
    let l:line = VimMarkerInfo#replace(getline(getpos("'" . a:word)[1]))
    return a:word . ": " . l:line
endfunction
"}}}
" グローバルマーカーで保存されている行を返す。
"{{{
function! VimMarkerInfo#windowGlobalMark(word)
    " 該当バッファの番号
    let l:buf = getpos("'" . a:word)[0]
    " ファイル名を取得
    let l:fullname = bufname( l:buf )
    " 該当バッファが読み込まれているならばその内容を返す。
    if bufloaded( l:buf ) != 0 && bufexists( l:buf )
        let l:line = VimMarkerInfo#replace( getbufoneline( l:buf , getpos("'" . a:word)[1] ) )
        return a:word . ": " . l:line
    endif
    " バッファの読み込みがされていなければファイル名だけを返す。
    let l:name = VimMarkerInfo#replacePath( l:fullname )
    return a:word . ": " . l:name
endfunction
"}}}
" 指定したマーカの目印(sign)を設置する。
"{{{
function! VimMarkerInfo#signSet()
    ""すべて解除
    call sign_unplace( 'local_group')
    call sign_unplace( 'global_group')
    
    for l:local_word in g:VimMarkerInfoLocalSignList
        if getpos("'" . l:local_word)[1] != 0
            call sign_place( 0, 'local_group', 'local_' . l:local_word, bufnr(),{'lnum' : getpos("'" . l:local_word)[1], 'priority' : 30 })
        endif
    endfor
    ""global_mark
    for l:global_word in g:VimMarkerInfoGlobalSignList
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
    " cui環境での色を定義
    execute( 'hi LocalMark  ctermfg=' . g:sign_highlight_cui[0] . ' ctermbg=' . g:sign_highlight_cui[1] )
    execute( 'hi GlobalMark ctermfg=' . g:sign_highlight_cui[2] . ' ctermbg=' . g:sign_highlight_cui[3] ) 
    execute( 'hi LocalMark  guifg=' . g:sign_highlight_gui[0]   . ' guibg=' . g:sign_highlight_gui[1] )
    execute( 'hi GlobalMark guifg=' . g:sign_highlight_gui[2]   . ' guibg=' . g:sign_highlight_gui[3] ) 

    " local_mark
    for s:local_word in g:VimMarkerInfoLocalSignList
        call sign_define("local_" . s:local_word,{"text" : s:local_word . ">", "texthl" : "LocalMark"})
    endfor
    " global_mark
    for l:global_word in g:VimMarkerInfoGlobalSignList
        call sign_define("global_" . l:global_word,{"text" : l:global_word . ">", "texthl" : "GlobalMark"})
    endfor
endfunction
"}}}









