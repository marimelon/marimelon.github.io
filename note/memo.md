# [メモ](https://marimelon.github.io/note/memo)

## GPUストレステスト
https://github.com/GpuZelenograd/memtest_vulkan

## UbuntuVM ディスク拡張

```
sudo growpart /dev/sda 3
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

## UbuntuVM ホスト名変更

```
hostnamectl set-hostname new.hostname.local
```

## Dcoker Install

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo gpasswd -a ${USER} docker
```

## Rclone Install

```
sudo -v ; curl https://rclone.org/install.sh | sudo bash
```

## DiskIO 測定

https://github.com/buty4649/fio-cdm

※ fioのインストールが必要

```
curl -s https://raw.githubusercontent.com/buty4649/fio-cdm/master/fio-cdm | sh /dev/stdin /path/to/hoge
```