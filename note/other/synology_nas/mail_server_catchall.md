# SynologyNasのMailServerでキャッチオールを設定する

NASにSSHでログインし、ファイルを書き換えたあとパッケージセンターからMailServerを再起動する。  
`user_name`は受信したいユーザ名に置き換える

-  /var/packages/MailServer/target/etc/main.cf

```diff
+ luser_relay = user_name
```

```diff
- # local_recipient_maps =
+ local_recipient_maps =
```