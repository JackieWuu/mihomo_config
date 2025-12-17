### 一、说明

两个 `yaml` 文件是博主自用的 OpenClash 配置文件，里面自带了多个在线更新的规则集，可以满足绝大部分的使用场景，并且读者只需要在配置文件中填写上自己的订阅地址，即可直接使用。

### 二、配置文件使用方法

#### 1. 下载配置文件并保存为 `.yaml` 格式

![配置文件下载-1](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0lRRDVUbE9yUTNvRlI0TlZ6UFNiVmtvdEFSWU5rS1ZNNjM1cmg0Mlg4TkZHYlRJP2U9akRyZ1VE.jpg "点击“原始数据”")

![配置文件下载-2](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0lRQjRlTFZub2wwaFNLaGpwZ1R3bW1tMkFUN2lydXExMlFnVDF0M1hNc1dyYmI4P2U9dEpxNGhF.jpg "保存配置文件为.yaml格式")

#### 2. 将下载下来的配置文件上传到 OpenClash

![配置文件上传](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VYa3hyQkhic2JwTWpBM1c4ejMzaGlvQjU5Z19SZi1Fd3NoUHZMcHJoYWNyR0E_ZT1uREJzVHY.jpg "在“配置管理”中上传yaml文件")

#### 3. 编辑配置文件，并填写订阅地址

> 如果有多个订阅地址，请根据文件里面的注释自行添加。

![填写订阅地址](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VVUkp3RHZkUzYxTmprQU1XYTFOREhRQkpLQUZYVnRfZ1ZnMlFrTmlTYU40VUE_ZT1VNjZDWkU.jpg "添加订阅地址")

#### 4. 运行配置脚本

复制以下命令到 OpenWRT 命令行中运行。脚本的作用是下载 `GeoSite.dat` 和 `GeoIP.dat` 文件，以及获取 openclash 的配置（脚本发布在 [Github](https://github.com/JackieWuu/mihomo_config/blob/main/openclash/geo_file_update.sh) 上）。

```
sh -c "$(wget -qO- https://gh-proxy.org/https://raw.githubusercontent.com/JackieWuu/mihomo_config/refs/heads/main/openclash/geo_file_update.sh)"
```
