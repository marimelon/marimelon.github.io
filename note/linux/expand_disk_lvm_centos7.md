
# CentOS7でのディスク拡張(LVM)

以下の順番でディスクの拡張を行う。

1. パーティションサイズの拡張
2. Physical Volumeの拡張
3. Logical Volumeの拡張
4. ファイルシステム拡張

### 状態確認
- ディスクサイズ(sda) 200G  
- パーティションサイズ(sda2) 151.1G

```sh
$ lsblk 
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda               8:0    0   200G  0 disk 
├─sda1            8:1    0     1G  0 part /boot
└─sda2            8:2    0   159G  0 part 
  ├─centos-root 253:0    0 151.1G  0 lvm  /
  └─centos-swap 253:1    0   7.9G  0 lvm  [SWAP]
sr0              11:0    1   364K  0 rom  
synosnap0       252:0    0     1G  1 disk 
synosnap1       252:1    0 151.1G  1 disk 
```

### パーティションサイズ拡張
- parted起動

```sh
$ parted /dev/sda
GNU Parted 3.1
/dev/sda を使用
GNU Parted へようこそ！ コマンド一覧を見るには 'help' と入力してください。
```

- パーティション状態を確認  
/dev/vdaのサイズと拡張するパーティションのNumberを確認  
対象パーティション 2

```
(parted) p                                                                
モデル: QEMU QEMU HARDDISK (scsi)
ディスク /dev/sda: 215GB
セクタサイズ (論理/物理): 512B/512B
パーティションテーブル: msdos
ディスクフラグ: 

番号  開始    終了    サイズ  タイプ   ファイルシステム  フラグ
 1    1049kB  1075MB  1074MB  primary  xfs               boot
 2    1075MB  172GB   171GB   primary                    lvm
```

- パーティションを拡張  

```
(parted) resizepart 2
終了?  [172GB]? 100% 
```

- parted終了

```
(parted) quit
```

### PV拡張

- Physical Volumeを拡張する

```sh
$ pvresize /dev/sda2
  Physical volume "/dev/sda2" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
```

- 空き容量がない場合エラーが出るため不要なファイルを削除して容量を空ける

```sh
$ pvresize /dev/sda2
  Couldn't create temporary archive name.
  0 physical volume(s) resized or updated / 1 physical volume(s) not resized
```

- 確認

```sh
$ pvscan
  PV /dev/sda2   VG centos          lvm2 [<199.00 GiB / 40.00 GiB free]
  Total: 1 [<199.00 GiB] / in use: 1 [<199.00 GiB] / in no VG: 0 [0   ]
```

### LV拡張

- Logical Volumeの拡張

```sh
$ lvextend -l +100%FREE /dev/mapper/centos-root
  Size of logical volume centos/root changed from 151.12 GiB (38687 extents) to 191.12 GiB (48927 extents).
  Logical volume centos/root successfully resized.
```

- 確認

```sh
$ lvdisplay /dev/centos/root
  --- Logical volume ---
  LV Path                /dev/centos/root
  LV Name                root
  VG Name                centos
  LV UUID                N4fpXY-dnU3-JznW-KTWX-VphN-nXCs-y21CKL
  LV Write Access        read/write
  LV Creation host, time localhost, 2019-11-17 03:32:27 +0900
  LV Status              available
  # open                 2
  LV Size                191.12 GiB
  Current LE             48927
  Segments               3
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
```

### ファイルシステム拡張

```sh
$ xfs_growfs /dev/mapper/centos-root
meta-data=/dev/mapper/centos-root isize=512    agcount=13, agsize=3276800 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=39615488, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=6400, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 39615488 to 50101248
```

### 確認

```sh
$ lsblk 
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda               8:0    0   200G  0 disk 
├─sda1            8:1    0     1G  0 part /boot
└─sda2            8:2    0   199G  0 part 
  ├─centos-root 253:0    0 191.1G  0 lvm  /
  └─centos-swap 253:1    0   7.9G  0 lvm  [SWAP]
sr0              11:0    1   364K  0 rom  
synosnap0       252:0    0     1G  1 disk 
synosnap1       252:1    0 151.1G  1 disk
```