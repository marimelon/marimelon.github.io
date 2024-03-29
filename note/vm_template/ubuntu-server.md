# [備忘録：VM Tamplate UbuntuServer](https://marimelon.github.io/note/vm_template/ubuntu-server)

## Version
Ubuntu Server 20.04

## 手順  
1. インストールディスクから通常インストール  
- ファイルシステムはLVMを選択
- 初期ユーザは適当に作成 (例: ubuntu)

2. 初期ユーザでログイン
- rootユーザにパスワードを設定
  ```
  sudo passwd root
  ```

- ログアウト
  ```
  exit
  ```

3. rootユーザでログイン
- 初期ユーザを削除
  ```
  userdel -r ubuntu
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


- cloud-initを無効化
  ```
  touch /etc/cloud/cloud-init.disabled
  ```

- rootユーザでsshを許可
  - /etc/ssh/sshd_config  
  ```
  PermitRootLogin yes
  ```

- qemu-guest-agentをインストール
  ```
  apt install qemu-guest-agent
  systemctl enable qemu-guest-agent
  ```

- ファイルシステム拡張用スクリプト配置  
  - /usr/local/bin/_growpart_fs.sh
  ```
  #!/bin/sh
  growpart /dev/sda 3 &&\
  lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv &&\
  resize2fs /dev/ubuntu-vg/ubuntu-lv
  ```

- シャットダウン
  ```
  shutdown now
  ```

4. virt-sysprep実行  
sysprep作業はVM内ではなく、ホスト上で実行する
- 作成されたqcow2ファイルにvirt-sysprepを適用する  
  ※diskファイルは上書きされる
  ```
  virt-sysprep -a vmdisk.qcow2 \
  --operations defaults,-ssh-hostkeys \
  --firstboot-command '/bin/rm -v /etc/ssh/ssh_host_* && /usr/bin/ssh-keygen -A -v && systemctl restart ssh' \
  --firstboot-command '/bin/sh /usr/local/bin/_growpart_fs.sh'
  ```

5. virt-sparsify実行  
virt-sparsifyを使用してディスクをスパース化  
- スパース化されたディスクがvmdisk_spars.qcow2として保存される
  
  ```
  virt-sparsify vmdisk.qcow2 vmdisk_spars.qcow2
  ```

6. 作成されたDiskイメージをテンプレートとして使用する