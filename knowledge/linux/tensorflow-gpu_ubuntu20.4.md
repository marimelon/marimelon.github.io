# [TensorFlowでGPUを使う(Ubuntu20.4)](https://marimelon.github.io/knowledge/knowledge/linux/tensorflow-gpu_ubuntu20.4)

## 環境
- Ubuntu20.4
- GeForce RTX 3060
- Nvidia Driver 470
- CUDA 11.4
- cuDNN 8.2.4.15-1
- tensorflow-2.6.0

## Driver Install

最新の470を使用

```sh
$ apt search nvidia-driver # ドライバの検索
$ apt install nvidia-driver-470
```

```sh
$ nvidia-smi
Mon Oct  4 09:46:47 2021       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.63.01    Driver Version: 470.63.01    CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:01.0 Off |                  N/A |
| 30%   37C    P0     1W / 170W |      0MiB / 12053MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

## CUDA Install

下記URLからCUDAのインストールコマンドを調べる

https://developer.nvidia.com/cuda-downloads


Linux->x86_64->Ubuntu->20.04->deb_local の場合
```sh
$ wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
$ sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
$ wget https://developer.download.nvidia.com/compute/cuda/11.4.2/local_installers/cuda-repo-ubuntu2004-11-4-local_11.4.2-470.57.02-1_amd64.deb
$ sudo dpkg -i cuda-repo-ubuntu2004-11-4-local_11.4.2-470.57.02-1_amd64.deb
$ sudo apt-key add /var/cuda-repo-ubuntu2004-11-4-local/7fa2af80.pub
$ sudo apt-get update
$ sudo apt-get -y install cuda
```

## cuDNN Install

Nvidia DeveloperからcuDNNをダウンロードする。(ログイン必要)  
https://developer.nvidia.com/rdp/cudnn-download

### dpkgを使用する場合

- cuDNN Runtime Library for Ubuntu20.04 x86_64 (Deb)  
- cuDNN Developer Library for Ubuntu20.04 x86_64 (Deb)

をダウンロード

```sh
$ ls -1
libcudnn8-dev_8.2.4.15-1+cuda11.4_amd64.deb
libcudnn8_8.2.4.15-1+cuda11.4_amd64.deb

$ dpkg -i libcudnn8_8.2.4.15-1+cuda11.4_amd64.deb
$ dpkg -i libcudnn8-dev_8.2.4.15-1+cuda11.4_amd64.deb
```

## Tensorflow Install

```
$ pip install tensorflow
$ pip install tensorflow-gpu
```

## 確認

tensorflowでGPUが利用可能か調べる

```py
from tensorflow.python.client import device_lib
device_lib.list_local_devices()
```

```python
$ python3
Python 3.8.10 (default, Jun  2 2021, 10:49:15) 
[GCC 9.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from tensorflow.python.client import device_lib
>>> device_lib.list_local_devices()
[name: "/device:CPU:0"
device_type: "CPU"
memory_limit: 268435456
locality {
}
incarnation: 15140049844309232047
, name: "/device:GPU:0"
device_type: "GPU"
memory_limit: 10756358144
locality {
  bus_id: 1
  links {
  }
}
incarnation: 2827924341623256560
physical_device_desc: "device: 0, name: NVIDIA GeForce RTX 3060, pci bus id: 0000:01:01.0, compute capability: 8.6"
]
```