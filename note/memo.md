# [メモ](https://marimelon.github.io/note/memo)

## GPUストレステスト
https://github.com/GpuZelenograd/memtest_vulkan

## UbuntuVM ディスク拡張

```
sudo growpart /dev/sda 3
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```