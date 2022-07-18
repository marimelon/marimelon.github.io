# [OpenfortiVPN]RaspberryPiを使ってPCの設定無しに自宅からVPN接続する

　大学のシステムを利用するのに、自宅からだとVPN接続する必要があるが、以下の点が面倒に感じた。
- 接続したいPCごとにVPNの設定をしないといけない
- FortiGateを使っているため、Clientをインストールする必要がある
- 全てのパケットがVPNを経由するように設定されてしまう

　そこでラズパイからVPNに接続し、VPNを経由する必要のあるパケットは、そのラズパイを経由して通信するように設定する。

## 構成

### 構成要素
- RasberryPi4 (Raspberry Pi OS Bullseye)
    - OpenfortiVPN
- Synology DHCP Server
- Synology DNS Server

## 構築

### 1.OpenfortiVPNをインストールする

```
$ sudo apt install openfortivpn
```

### 2.接続先を設定する
```
$ sudp vim /etc/openfortivpn/config
```

```
### config file for openfortivpn, see man openfortivpn(1) ###

host = VPNサーバのアドレス
port = 443
username = ユーザ名
password = パスワード
set-routes = 0
```

自分でルーティングを設定したいので、`set-routes = 0`でルーティング設定を無効にしておく。


### 3.systemdに登録する

`/etc/systemd/system/`に定義ファイルを作成する。

```
$ sudo vim /etc/systemd/system/vpn.service
```

ファイルの中身

```
[Unit]
Description=OpenfortiVPN

[Service]
Restart=always
ExecStart=/usr/bin/openfortivpn --pppd-ipparam=school_vpn

[Install]
WantedBy=default.target
```

VPN接続後、ルーティング設定を行うので`--pppd-ipparam=school_vpn`で接続名を設定しておく。

### 3.ルーティングの設定(ラズパイ)

#### VPN接続確立時の設定

VPN接続確立後にHookを使ってルーティングの設定を行う。

```
$ sudo vim /etc/ppp/ip-up.d/school_vpn
```

```
#!/bin/sh -e

if [ "$PPP_IPPARAM" = "school_vpn" ]; then
  /sbin/ip r add VPNを使用したいネットワークのCIDR via $PPP_LOCAL
  /sbin/ip r add VPNサーバIP via 自宅のGW dev eth0
fi
```

`"school_vpn"` には `--pppd-ipparam`で設定した接続名を指定する。

ここでは、VPNに流したい接続先ネットワークを`$PPP_LOCAL`を介するように設定する.

また、今回はVPNサーバが`VPNを使用したいネットワークのCIDR`の範囲内に存在したため、VPNサーバには自宅のGWを介するように設定する。

#### VPN切断時の設定
TODO:

### 4.ルーティングの設定(DHCP)
自宅内のPCがVPN接続したいIPへのパケットをラズパイを経由するようにDHCPでルーティング情報を配信する。

DHCPにはClassless Static Routes option (option 121)という、静的ルート情報をDHCPクライアントに配信する機能がある。

我が家ではSynology DHCP Serverを使用しているため、そこに設定する。

「設定方法」

- DNS Serverを開く
- ネットワークインターフェースから編集する
- 下部にあるサブネットマスクを選択して編集する
- DHCPオプション設定リストから、コード121のclassless-static-routeを有効にする
- 値を以下のように設定する

```
VPNを使用したいネットワークのCIDR,ラズパイのIP,0.0.0.0/0,自宅GW
```


