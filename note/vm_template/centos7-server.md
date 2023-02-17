# 備忘録：VM Tamplate CentOS7

## Version
CentOS-7-x86_64-DVD-2207-02.iso

## 手順  
1. インストールディスクから通常インストール  
- rootユーザのパスワードのみ設定

2. rootユーザでログイン  

- シリアルコンソールを有効化

- パッケージを更新
  ```
  yum update
  ```

- シリアルコンソールを有効化  
  参考: https://takeda-h.hatenablog.com/entry/2019/10/06/222503

  - /etc/default/grub を編集  

  ```
  GRUB_TERMINAL_OUTPUT="serial console" # 変更
  
  # "console=tty0 console=ttyS0,9600 console=ttyS1,9600" を追記  
  GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet console=tty0 console=ttyS0,9600 console=ttyS1,9600"
  
  GRUB_TERMINAL="console serial"　# 追記
  GRUB_SERIAL_COMMAND="serial --speed=9600 --unit=0 --word=8 --parity=no --stop=1" # 追記
  ```

  - grub.cfgを更新  

  ```
  grub2-mkconfig -o /boot/grub2/grub.cfg
  ```
  
- qemu-guest-agentをインストール
  ```
  yum install qemu-guest-agent
  systemctl enable qemu-guest-agent
  ```

- growpartをインストール  
  ```
  yum install cloud-utils-growpart
  ```

- ファイルシステム拡張用スクリプト配置  
  - /usr/local/bin/_growpart_fs.sh
  ```
  #!/bin/sh
  growpart /dev/sda 2 &&\
  pvresize /dev/sda2 &&\
  lvextend -l +100%FREE /dev/centos/root &&\
  xfs_growfs /dev/mapper/centos-root
  ```

3. virt-sysprep実行  
sysprep作業はVM内ではなく、ホスト上で実行する
- 作成されたqcow2ファイルにvirt-sysprepを適用する  
  ※diskファイルは上書きされる
  ```
  virt-sysprep -a vmdisk.qcow2 \
  --firstboot-command '/bin/sh /usr/local/bin/_growpart_fs.sh'
  ```

4. virt-sparsify実行  
virt-sparsifyを使用してディスクをスパース化  
- スパース化されたディスクがvmdisk_spars.qcow2として保存される
  
  ```
  virt-sparsify vmdisk.qcow2 vmdisk_spars.qcow2
  ```

5. 作成されたDiskイメージをテンプレートとして使用する