# OpenNebula構築手順記録 (CentOS7)

## 共通処理
### リポジトリ登録

`/etc/yum.repos.d/opennebula.repo`

```
[opennebula]
name=OpenNebula Community Edition
baseurl=https://downloads.opennebula.io/repo/6.0/CentOS/7/$basearch
enabled=1
gpgkey=https://downloads.opennebula.io/repo/repo.key
gpgcheck=1
repo_gpgcheck=1
```

### Firewalld無効化

```shell
$ sudo systemctl stop firewalld
$ sudo systemctl disable firewalld
```

### SELinux無効化

`/etc/selinux/config`

```
SELINUX=disabled
```

・再起動

## フロントエンド構築
### インストール
```shell
$ sudo yum makecache fast -y
$ sudo yum install -y epel-release centos-release-scl-rh
$ sudo yum install -y opennebula opennebula-sunstone opennebula-fireedge \
opennebula-gate opennebula-flow opennebula-provision
```

### 管理者パスワード設定

```shell
$ sudo -u oneadmin /bin/bash
[oneadmin@localhost ~]$ echo 'oneadmin:mypassword' > ~/.one/one_auth
[oneadmin@localhost ~]$ exit
```

### NFS設定(Option)

```shell
$ sudo yum install -y nfs-utils
$ sudo systemctl start rpcbind nfs
$ sudo systemctl enable rpcbind nfs
```

共有するストレージを指定する

`/etc/exports`

```
/var/lib/one/datastores/<storage_id> *(rw,sync,no_subtree_check,root_squash)
```

<!--
・firewall

```
$ sudo firewall-cmd --permanent --add-service mountd
$ sudo firewall-cmd --permanent --add-service rpc-bind
$ sudo firewall-cmd --permanent --add-service nfs
$ sudo firewall-cmd --reload
```


## ファイアウォール設定
OpenNebulaが使用するポートを開放する。

```shell
$ sudo firewall-cmd --zone=public --permanent \
--add-port=2474/tcp \
--add-port=2616/tcp \
--add-port=2633/tcp \
--add-port=4124/tcp \
--add-port=5030/tcp \
--add-port=9869/tcp \
--add-port=29876/tcp
$ sudo firewall-cmd --reload
```
-->

## 各種設定
### 日本語に変更
```sh
$ sudo sed -i -e 's/:lang: en_US/:lang: ja/g' /etc/one/sunstone-server.conf
```

### Firegate設定

`/etc/one/sunstone-server.conf`

```
:public_fireedge_endpoint: http://one.example.com:2616
```

### LDAP設定
LDAPによるグループ設定を無効化しNebulaでグループ割当を可能にする

`/etc/one/auth/ldap_auth.conf`

```
:host:
:base:
:mapping_generate: false
```

`/etc/one/oned.conf`

```
AUTH_MAD_CONF = [
    NAME = "ldap",
    PASSWORD_CHANGE = "NO",
    DRIVER_MANAGED_GROUPS = "NO",
    DRIVER_MANAGED_GROUP_ADMIN = "NO",
    MAX_TOKEN_TIME = "86400"
]
```

## 起動

```sh
$ sudo systemctl start opennebula opennebula-sunstone opennebula-fireedge \
opennebula-gate opennebula-flow
$ sudo systemctl enable opennebula opennebula-sunstone opennebula-fireedge \
opennebula-gate opennebula-flow
```

・ブラウザからポート9869で管理画面にアクセス可能になる。

## ノード構築(KVM)
### インストール
```sh
$ sudo yum install -y epel-release
$ sudo yum install -y centos-release-qemu-ev opennebula-node-kvm
$ sudo yum install -y qemu-kvm-ev
```

### ネットワーク設定
```sh
$ INTERFACE=eth0    #物理インタフェースを指定
$ sudo nmcli con add type bridge ifname br0
$ sudo nmcli con mod bridge-br0 bridge.stp no
$ sudo nmcli con add type bridge-slave ifname ${INTERFACE} master bridge-br0
$ sudo systemctl restart network
$ sudo nmcli con del ${INTERFACE} #物理インタフェースを指定
```

固定IP割り当て時

```
$ sudo nmcli con mod bridge-br0 ipv4.method manual ipv4.addresses X.X.X.X/24
$ sudo nmcli con mod bridge-br0 ipv4.gateway  X.X.X.X/24
$ sudo nmcli con mod bridge-br0 +ipv4.dns X.X.X.X
$ sudo nmcli con mod bridge-br0 +ipv4.dns Y.Y.Y.Y
```

### ファイアウォール設定
VNC,SPICE利用のための設定が必要。(5900~/tcp)

### ネットワークストレージ設定
未

```
$ sudo yum install nfs-utils
```

`/var/lib/one//datastores`配下のsharedストレージに当たるidのディレクトリをマウントする。

`/etc/fstab`

```sh
# Example(storageId = 101)
150.89.236.105:/var/lib/one//datastores/101 /var/lib/one//datastores/101 nfs   soft,intr,rsize=8192,wsize=8192,nfsvers=4.2
```

<!--
SELinuxの有効時は以下を設定する必要がある。

```
$ sudo setsebool -P virt_use_nfs on
```
-->

### 起動
```shell
$ sudo systemctl start libvirtd
$ sudo systemctl enable libvirtd
```

ブラウザ管理画面からホストを追加する。

## GPUパススルー設定
### IOMMU 有効化
AMDCPUはデフォルトでiommuがonになっている？

### カーネルオプション追加
GRUB_CMDLINE_LINUXに`intel_iommu=on`を追加する。

`/etc/default/grub`

```sh
GRUB_CMDLINE_LINUX="rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet intel_iommu=on"
```
### 適用
**UEFIブートの場合**

```sh
$ sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.config
```

**BIOSブートの場合**

```sh
$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 再起動する
```sh
$ sudo reboot
```

```sh
# IOMMU enabledと表示されるか確認する
$ dmesg | grep -E "DMAR|IOMMU"
```

### ドライバ設定

#### GPU Driverを無効化

起動時にGPUがGPU Driverにバインドされないようにする。

- AMD GPU  
`/etc/modprobe.d/blacklist.conf`
```
blacklist radeon
blacklist amdgpu
```

- Nvidia GPU  
`/etc/modprobe.d/blacklist.conf`
```
blacklist nouveau
options nouveau modeset=0
```

### vfio-pci設定
起動時にvfio-pciにGPUをバインドする。

```sh
$ lspci -nn | grep -i -e nvidia -e amd
01:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Caicos XTX [Radeon HD 8490 / R5 235X OEM] [1002:6771]
01:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Caicos HDMI Audio [Radeon HD 6450 / 7450/8450/8490 OEM / R5 230/235/235X OEM] [1002:a...
```

上記で調べた[ベンダID:デバイスID]を指定する

`/etc/modprobe.d/vfio.conf`

```
options vfio-pci ids=1002:6771,1002:aa98
```

起動時にvfio-pciモジュールを読み込む

```sh
$ echo "vfio-pci" | sudo tee /etc/modules-load.d/vfio-pci.conf
$ sudo reboot
```

**確認**

```sh
$ dmesg | grep -i vfio
[    5.980978] VFIO - User Level meta-driver version: 0.3
[    5.990642] vfio_pci: add [1002:6771[ffff:ffff]] class 0x000000/00000000
[    5.990652] vfio_pci: add [1002:aa98[ffff:ffff]] class 0x000000/00000000
```

### quemにデバイスへのアクセス許可を与える

`/etc/libvirt/qemu.conf`の`cgroup_device_acl`に`"/dev/vfio/vfio"`と `"/dev/vfio/<number>"`を追加する。

`<number>`はGPUのIOMMUグループを指定する。

`/etc/libvirt/qemu.conf`

```
cgroup_device_acl = [
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
    "/dev/rtc","/dev/hpet", "/dev/sev",
    "/dev/vfio/vfio", "/dev/vfio/1"
]
```

**IOMMUグループとPCIカードのリストを取得する**

```sh
$ sudo find /sys/kernel/iommu_groups/ -type l
/sys/kernel/iommu_groups/0/devices/0000:00:00.0
/sys/kernel/iommu_groups/1/devices/0000:00:01.0 # PCI bridge
/sys/kernel/iommu_groups/1/devices/0000:01:00.0 # VGA compatible controller
/sys/kernel/iommu_groups/1/devices/0000:01:00.1 # Audio device: Advanced Micro Devices
/sys/kernel/iommu_groups/2/devices/0000:00:02.0
/sys/kernel/iommu_groups/3/devices/0000:00:03.0
/sys/kernel/iommu_groups/4/devices/0000:00:14.0
/sys/kernel/iommu_groups/5/devices/0000:00:16.0
/sys/kernel/iommu_groups/5/devices/0000:00:16.3
/sys/kernel/iommu_groups/6/devices/0000:00:19.0
/sys/kernel/iommu_groups/7/devices/0000:00:1a.0
/sys/kernel/iommu_groups/8/devices/0000:00:1b.0
/sys/kernel/iommu_groups/9/devices/0000:00:1d.0
/sys/kernel/iommu_groups/10/devices/0000:00:1f.0
/sys/kernel/iommu_groups/10/devices/0000:00:1f.2
/sys/kernel/iommu_groups/10/devices/0000:00:1f.3
```

### /dev/vfio/N の所有権をoneadminに変更する

```sh
$ sudo chown oneadmin:oneadmin /dev/vfio/N
$ ls /dev/vfio/ -l
Total 0
crw------- 1 oneadmin oneadmin 242,   0  9月 24 16:59 28
crw------- 1 oneadmin oneadmin 242,   1  9月 24 16:59 57
crw-rw-rw- 1 root     root      10, 196  9月 24 16:59 vfio
```


### Opennebulaの設定(※フロントで設定)
Opennebulaで監視するPCIデバイスのフィルタ
今回はGPUのベンダIDでフィルタを掛ける。

`/var/lib/one/remotes/etc/im/kvm-probes.d/pci.conf`

```
:filter: '1002:*'
```

管理画面から インフラストラクチャー→ホスト→PCI にてデバイスが表示されるか確認する。
