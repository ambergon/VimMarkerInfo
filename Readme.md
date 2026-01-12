VimMarkerInfo
=============
VimMarkerInfo はmarkの位置の可視化とマークの内容をいつでも確認することできるようになるプラグインです。
各種コマンドの詳細はhelp /doc/VimMarkerInfo.jaxを確認ください。

Required
------
Vim 8.2~

Usage:
------
```
開始
	:MarkerInfo
```

ウィンドウが更新されるタイミング:
------
ウィンドウやバッファに入る、マークを設置したタイミング

setting:
------
```
" 自動起動を有効化
let g:startVimMarkerInfo=1
" cui環境下での色を指定
let g:sign_highlight_cui=[ '2' , '0' , '113' , '0' ]
" マークされた行を表示するウィンドウで置換
let g:mark_replace = [["^ *","",""],["^Function","Func",""],["^function","func",""],["{{{","",""],["}}}","",""]]
" グローバルマークされたファイル名を置換
let g:mark_replace_file = [["\\","/","g"],['^scp://\(.\{-}\)/.*/','scp \1:',""],["^.*/","","g"]]
```


License:
--------
MIT

Author:
-------
ambergon
[twitter](https://twitter.com/Sc_lFoxGon)
