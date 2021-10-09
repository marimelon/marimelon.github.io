# [JupyterHubの構築メモ](https://marimelon.github.io/note/linux/jupyter_hub_install_ubuntu20.4)

## 環境
- Ubuntu20.4
- Python3.8

condaを使わずpipを使用  
JupyterLabを同一サーバ上で実行

## Install

### Python,pip

Pythonはデフォルトで入っているものを使用(3.8系)

```sh
$ python3 -V
Python 3.8.5

$ apt install python3-pip
$ pip -V
pip 20.0.2 from /usr/lib/python3/dist-packages/pip (python 3.8)
```

### Node

condaを使用しない場合はnpmが必要

```sh
$ curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
$ apt install npm
```

### JupyterHub 

```sh
$ pip install jupyterhub
$ npm install -g configurable-http-proxy
$ pip install jupyterlab
```

## コンフィルファイルの生成

```sh
$ mkdir /etc/jupyterhub
$ cd /etc/jupyterhub
$ jupyterhub --generate-config
$ ls
jupyterhub_config.py
```

デフォルトでJupyterLabを起動するための設定

```python:jupyterhub_config.py
# jupyterhub_config.py
c.Spawner.default_url = 'lab'
```


## ログインユーザを作成

rootとしてjupyterLabを起動できないため新しくユーザを作成する  
※正確にはログインは可能だがJupyterLabを起動できない

```sh
$ adduser user_name
$ gpasswd -a user_name sudo # sudo権限を付与する場合
```


## systemdに登録

- /etc/systemd/system/jupyterhub.service

```sh:/etc/systemd/system/jupyterhub.service
[Unit]
Description=JupyterHub
After=syslog.target network.target

[Service]
User=root 
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
ExecStart=/usr/local/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target
```

## 起動

```
$ systemctl start jupyterhub
$ systemctl enable jupyterhub
```

デフォルトでは`8000`ポートを使用して公開される  
作成したLinuxユーザアカウントでログインできる


## ライブラリの追加
すべてのユーザにpipライブラリを追加する際のコマンド

```sh
$ sudo -E pip install LibraryName
```

- 日本語化

```
$ sudo -E pip install jupyterlab-language-pack-ja-JP
```

ブラウザをリロード後 `Settings->Language->Japanese`
