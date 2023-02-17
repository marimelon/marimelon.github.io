# 備忘録：VM Tamplate UbuntuDesktop JP

## Version
Ubuntu Desktop 日本語 Remix 20.04  
(ubuntu-ja-22.04-desktop-amd64.iso)

## 手順
1. インストールディスクから通常インストール 
- ファイルシステムはext4を使用  
  「インストールの種類」の高度な機能　-> なし(default)
- 初期ユーザは展開後も使用する (例 ubuntu)

2. 初期ユーザでログイン  
ログイン後端末(terminal)を開く

- ホームディレクトリを英語化
  ```
  LANG=C xdg-user-dirs-gtk-update
  ```

- rootユーザにスイッチ
  ```
  sudo su - root 
  ```

- シリアルコンソールを有効化  
  参考：https://qiita.com/wataash/items/b291cc0643d952d986d8

  - /etc/default/grub を編集
  ```
  GRUB_TIMEOUT=2 # 変更

  GRUB_TERMINAL="console serial" # 追加
  GRUB_SERIAL_COMMAND="serial --speed=115200" # 追加

  GRUB_CMDLINE_LINUX="console=tty1 console=ttyS0,115200"　# 変更
  ```

  - grub.cfgを生成  
  ```
  update-grub
  ```

- qemu-guest-agentをインストール
  ```
  apt install qemu-guest-agent
  systemctl enable qemu-guest-agent
  ```

- cloud-guest-utilsをインストール
  ```
  apt install cloud-guest-utils
  ```

- openssh-serverをインストール  
  ```
  apt install openssh-server
  ```

- ファイルシステム拡張用スクリプト配置  
  - /usr/local/bin/_growpart_fs.sh
  ```
  #!/bin/sh
  growpart /dev/sda 3 &&\
  resize2fs /dev/sda3
  ```

4. virt-sysprep実行  
sysprep作業はVM内ではなく、ホスト上で実行する
- 作成されたqcow2ファイルにvirt-sysprepを適用する  
  ※diskファイルは上書きされる
  ```
  virt-sysprep -a vmdisk.qcow2 \
  --operations defaults,-ssh-hostkeys \
  --firstboot-command '/bin/rm -v /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server && systemctl restart ssh' \
  --firstboot-command '/bin/sh /usr/local/bin/_growpart_fs.sh'
  ```

5. virt-sparsify実行  
virt-sparsifyを使用してディスクをスパース化  
- スパース化されたディスクがvmdisk_spars.qcow2として保存される
  
  ```
  virt-sparsify vmdisk.qcow2 vmdisk_spars.qcow2
  ```

6. 作成されたDiskイメージをテンプレートとして使用する