# [Hyper-V上のUbuntuセットアップ(備忘録)](https://marimelon.github.io/note/hyper-v/ubuntu-setup)

## 環境
Ubuntu20.4 Desktop 日本語エディション  
- ubuntu-ja-20.04.1-desktop-amd64.iso

## ディスプレイ解像度を変更
- ブートローダーの設定を変更する

    ```
    sudo vi /etc/default/grub
    ```
    
    - 解像度を指定 (1920x1080を指定している)
    ```diff
    # /etc/default/grub
    - GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
    + GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1920x1080"
    ```

- 設定を更新

    ```
    sudo update-grub
    ```

- 再起動

    ```
    sudo reboot
    ```

## VNC Serverをインストール

- Vinoをインストール

    ```
    sudo apt install vino
    ```

- VNCサーバーを有効化

    設定->共有->画面共有 から有効にする

- 暗号化を無効化する

    ```
    gsettings set org.gnome.Vino require-encryption false
    ```