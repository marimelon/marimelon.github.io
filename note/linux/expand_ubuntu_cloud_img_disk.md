# Ubuntu Cloud Imageのディスクを拡張する

## 背景

Ubuntuが提供しているクラウドイメージをKVM環境で動かす際に、virt-customizeを使用して予めubuntu-desktopをインストールしようとしたところ、ディスク容量が足りなかったため拡張を行った。

virt-resizeによる拡張では `/dev/sda1` が `/dev/sda3`に変換されてしまいbootが失敗したため、partedを使用して拡張を行った。

## 使用イメージ

- jammy-server-cloudimg-amd64.img(2023-02-18)

```bash
$ qemu-img info jammy-server-cloudimg-amd64.img 
image: jammy-server-cloudimg-amd64.img
file format: qcow2
virtual size: 2.2 GiB (2361393152 bytes)
disk size: 648 MiB
cluster_size: 65536
Format specific information:
    compat: 0.10
    compression type: zlib
    refcount bits: 16
$ virt-filesystems --long --parts --filesystems -h -a jammy-server-cloudimg-amd64.img 
Name        Type        VFS   Label            MBR  Size  Parent
/dev/sda1   filesystem  ext4  cloudimg-rootfs  -    2.0G  -
/dev/sda15  filesystem  vfat  UEFI             -    104M  -
/dev/sda1   partition   -     -                -    2.1G  /dev/sda
/dev/sda14  partition   -     -                -    4.0M  /dev/sda
/dev/sda15  partition   -     -                -    106M  /dev/sda
```

## 手順

### Qcow2をRawに変換する

partedではqcow2を扱えないためイメージをrawに変換して`jammy-server-cloudimg-amd64.raw`として保存する

```bash
$ qemu-img convert -O raw jammy-server-cloudimg-amd64.img jammy-server-cloudimg-amd64.raw
```

### ディスクを拡張する

qemu-imgを使用して必要なディスク容量に拡張を行う

ubuntu-desktopのインストールは6GBあれば可能であった

```bash
$ qemu-img resize -f raw jammy-server-cloudimg-amd64.raw 6G
```

### パーティションを拡張する

partedを使用して拡張したディスクに合わせて`/dev/sda1`を拡張する

```bash
$ parted jammy-server-cloudimg-amd64.raw
```

パーティションの確認を行う

GPT(GUIDパーティションテーブル)を更新するか聞かれるので`Fix`を選択

```bash
(parted) p                                                                
Warning: Not all of the space available to /root/jammy-server-cloudimg-amd64.raw appears to be used, you can fix the GPT to use all of the space (anextra 7970816 blocks) or continue with the current setting? 
Fix/Ignore? Fix                                                           
Model:  (file)
Disk /root/ubuntu22.04_20230218/desktop2/jammy-server-cloudimg-amd64.raw: 6442MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
14      1049kB  5243kB  4194kB                     bios_grub
15      5243kB  116MB   111MB   fat32              boot, esp
 1      116MB   2361MB  2245MB  ext4
```

`cloudimg-rootfs` のあるNumber 1のパテーションをディスクに合わせて拡張する

```bash
(parted) resizepart 1 100%
```

partedを終了する

```bash
(parted) q
```

- スクリプトに組み込む際のコマンド(対話モードを使用しない)
    
    ```bash
    sgdisk jammy-server-cloudimg-amd64.raw -e
    parted -s jammy-server-cloudimg-amd64.raw resizepart 1 100%
    ```
    

### Qcow2フォーマットに戻す (Option)

下のコマンドでは元の`jammy-server-cloudimg-amd64.img`ファイルを上書きしている

```bash
$ qemu-img convert -f raw -O qcow2 jammy-server-cloudimg-amd64.raw jammy-server-cloudimg-amd64.img
```

### ファイルシステムを拡張する

virt-customizeを使用して`resize2fs`を実行し、ファイルシステムの拡張を行う

実行時にmachine IDが生成されるので最後に`/etc/machine-id`を空にしておく

```bash
$ virt-customize -a jammy-server-cloudimg-amd64.img \
--run-command "resize2fs /dev/sda1" \
--truncate /etc/machine-id
```

<details>
<summary>ubuntu-desktopのインストールも同時に行う場合</summary> 
    
    ```bash
    $ virt-customize -a jammy-server-cloudimg-amd64.img \
    --run-command "resize2fs /dev/sda1" \
    --install "ubuntu-gnome-desktop" \
    --truncate /etc/machine-id
    ```
</details>

## 確認

```bash
$ virt-filesystems --long --parts --filesystems -h -a jammy-server-cloudimg-amd64.img
Name        Type        VFS   Label            MBR  Size  Parent
/dev/sda1   filesystem  ext4  cloudimg-rootfs  -    5.6G  -
/dev/sda15  filesystem  vfat  UEFI             -    104M  -
/dev/sda1   partition   -     -                -    5.9G  /dev/sda
/dev/sda14  partition   -     -                -    4.0M  /dev/sda
/dev/sda15  partition   -     -                -    106M  /dev/sda
```

```bash
$ virt-df -h -a jammy-server-cloudimg-amd64.img 
Filesystem                                Size       Used  Available  Use%
jammy-server-cloudimg-amd64.img:/dev/sda1
                                          5.6G       4.4G       1.2G   78%
jammy-server-cloudimg-amd64.img:/dev/sda15
                                          104M       6.0M        98M    6%
```
