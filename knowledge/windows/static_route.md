# [Windowsにスタティックルートを設定する](https://marimelon.github.io/knowledge/knowledge/windows/static_route)

192.168.2.0/24 へのアクセスを192.168.1.1を介してアクセスするルート設定<br>
-p は永続化
```
route -p add 192.168.2.0 mask 255.255.255.0 192.168.1.1 (metric 1) (if 0x2)
```
