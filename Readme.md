VimMarkerInfo
=============
VimMarkerInfo はmarkの位置の可視化とマークの内容をいつでも確認することできるようになるプラグインです。
各種コマンドの詳細はhelp /doc/VimMarkerInfo.jaxを確認ください。

Usage:
------
```
開始
	:MarkerInfo

終了
	:MarkerInfoOff
```

ウィンドウが更新されるタイミング:
------
ウィンドウやバッファに入ったタイミング、
insert mode から normal modeに戻ったタイミングで更新されます。

マークしたタイミングでは更新されません。

setting:
------
```
""vimrc setting
"いずれも無設定でも運用可能。

"windowに表示するmarkの指定
"設定していない文字でもsignによる表示は有効。
let g:marker_window_local = 'abcde'
let g:marker_window_global = 'ABCDE'

"windowに表示するlocalなマークの行の内容を置換する
"s///gと同じ。
let g:mark_replace = [["before","after",""],["","","g"]]

"windowの横サイズを指定する。
let g:MarkerInfoWindowSize =30
```


License:
--------
MIT

Author:
-------
ambergon
[twitter](https://twitter.com/Sc_lFoxGon)
