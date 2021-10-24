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

setting:
------
```
""setting
"windowに表示するmarkの指定
let g:marker_window_local = 'abcde'
let g:marker_window_global = 'ABCDE'

"windowに表示するlocalなマークの行の内容を置換する
let g:mark_replace = [["","",""],["","","g"]]

"windowのサイズを指定する。
let g:MarkerInfoWindowSize =30
```


License:
--------
MIT

Author:
-------
ambergon
[twitter](https://twitter.com/Sc_lFoxGon)
