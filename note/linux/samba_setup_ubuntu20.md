# [Sambaのインストール(Ubuntu20)](https://marimelon.github.io/note/linux/samba_setup_ubuntu20)

## Sambaのインストール

```sh
$ sudo apt install -y samba
```

## Sambaユーザの追加

```sh
$ USERNAME=user
$ sudo pdbedit -a ${USERNAME}
```

## 設定ファイル編集
`/etc/samba/smb.conf`を編集

- プリンタ共有を無効化  
`[printers]`,`[print$]`のセクションをコメントアウト

- Homeディレクトリを共有
```diff
- ;[homes]
- ;   comment = Home Directories
- ;   browseable = no
+ [homes]
+    comment = Home Directories
+    browseable = no
```

- 書き込みを許可  
`[homes]`セクション内の `read only`を`no`にする
```diff
- ;   read only = yes
+     read only = no
```

- アクセス可能なユーザの設定
```diff
- ;   valid users = %S
+     valid users = %S
```

## 設定を反映する
- 設定ファイルの構文チェック
```sh
$ testparm
```

- Sabmaを再起動して設定を反映
```
$ sudo systemctl restart smbd
```