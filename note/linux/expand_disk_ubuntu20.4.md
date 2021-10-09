
# [Ubuntu20.4でのディスク拡張(ext4)](https://marimelon.github.io/note/linux/expand_disk_ubuntu20.4)

### 状態確認
ディスクサイズ(vda) 10GB  
パーティションサイズ(vda1) 2.1G
```sh
$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0      11:0    1  364K  0 rom
vda     252:0    0   10G  0 disk
├─vda1  252:1    0  2.1G  0 part /
├─vda14 252:14   0    4M  0 part
└─vda15 252:15   0  106M  0 part /boot/efi
```

### パーティションサイズ拡張
- parted起動
```sh
$ parted /dev/vda
Using /dev/vda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted)
```

- パーティション状態を確認  
/dev/vdaのサイズと拡張するパーティションのNumberを確認  
  
DiskSize 10.7GB  
対象パーティション 1
```
(parted) p
Warning: Not all of the space available to /dev/vda appears to be used, you can fix the GPT to use all of the space (an extra 4194304 blocks) or
continue with the current setting?
Fix/Ignore? Fix
Model: Virtio Block Device (virtblk)
Disk /dev/vda: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
14      1049kB  5243kB  4194kB                     bios_grub
15      5243kB  116MB   111MB   fat32              boot, esp
 1      116MB   2361MB  2245MB  ext4
```

- パーティションを拡張  
サイズ指定の部分は `100%` 等でも可
```
(parted) resizepart 1
Warning: Partition /dev/vda1 is being used. Are you sure you want to continue?
Yes/No? Yes
End?  [2361MB]? 10.7GB
```

- parted終了
```
(parted) quit
```

### ファイルシステム拡張
```sh
$ resize2fs /dev/vda1
```