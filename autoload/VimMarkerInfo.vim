let s:local_list ='abcdefghijklmnopqrstuvwxyz'
let s:global_list ='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
let s:VimMarkerInfoBuffer ='MarkerInfoWindow://'

if !exists("g:marker_window_local")
    let g:marker_window_local=s:local_list
endif
if !exists("g:marker_window_global")
    let g:marker_window_global=s:global_list
endif

if !exists("g:mark_replace")
    let g:mark_replace =[["","",""]]
endif

if !exists("g:MarkerInfoWindowSize")
    let g:MarkerInfoWindowSize =30
endif

function! VimMarkerInfo#closeWindow()
    call sign_unplace( 'local_group')
    call sign_unplace( 'global_group')
    autocmd! left_window
    autocmd! VimMarkerInfo
    if bufexists(s:VimMarkerInfoBuffer)
        execute("bw " . s:VimMarkerInfoBuffer)
    endif
endfunction

function! VimMarkerInfo#setWindow()
    call VimMarkerInfo#setHighLight()
    call VimMarkerInfo#openMarkerWindow()
    call VimMarkerInfo#signSet()
    augroup VimMarkerInfo
        autocmd bufEnter * call VimMarkerInfo#signSet()
        autocmd bufWinEnter * call VimMarkerInfo#openMarkerWindow()
        autocmd WinEnter * call VimMarkerInfo#openMarkerWindow()
        autocmd InsertLeave * call VimMarkerInfo#openMarkerWindow() | call VimMarkerInfo#signSet()
    augroup end
endfunction

function! VimMarkerInfo#openMarkerWindow()
    if !bufexists(s:VimMarkerInfoBuffer)
        let l:current_winID = win_getid()
        execute('aboveleft ' . g:MarkerInfoWindowSize . 'vs ' . s:VimMarkerInfoBuffer)

        augroup left_window
            execute("autocmd BufLeave <buffer> vert resize " . g:MarkerInfoWindowSize)
            execute("autocmd VimResized <buffer> vert resize " . g:MarkerInfoWindowSize)
            execute("autocmd BufWinLeave <buffer> vert resize " . g:MarkerInfoWindowSize)
            execute("autocmd BufWinEnter <buffer> vert resize " . g:MarkerInfoWindowSize)
            autocmd QuitPre <buffer> call VimMarkerInfo#quitBuffer()
        augroup end

        "qで終了
        nnoremap <buffer> q :q<CR>
        "listに載せない
        setl nobuflisted
        "折り返さない
        setl nowrap
        setl nonumber
        setl norelativenumber
        setl buftype=nowrite
        "bufexist
        setl bufhidden=wipe
        call win_gotoid(l:current_winID)
    endif
    call VimMarkerInfo#windowAppendLines()
endfunction

function! VimMarkerInfo#Replace( text )
    let l:res = a:text
    let l:res = substitute( l:res ,"^ *","",'')
    for l:replace in g:mark_replace
        let l:res = substitute( l:res ,replace[0],replace[1],replace[2])
    endfor
    return l:res
endfunction

function! VimMarkerInfo#windowLocalMark(word)
    let l:line = VimMarkerInfo#Replace(getline(getpos("'" . a:word)[1]))
    return a:word . ":" . l:line
endfunction

function! VimMarkerInfo#windowGlobalMark(word)
    let l:line = bufname(getpos("'" . a:word)[0])
    return a:word . ":" . l:line
endfunction

function! VimMarkerInfo#windowAppendLines()
    "clean
    call deletebufline(s:VimMarkerInfoBuffer,1,"$")
    
    ""local
    let l:x=0
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

function! VimMarkerInfo#setHighLight()
    "windowsのカラーテーブル
    if has( win64 )
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
