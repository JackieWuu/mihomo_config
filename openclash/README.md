### 一、说明

两个 `yaml` 文件是博主自用的 OpenClash 配置文件，里面自带了多个在线更新的规则集，可以满足绝大部分的使用场景，并且读者只需要在配置文件中填写上自己的订阅地址，即可直接使用。

### 二、配置文件使用方法

#### 1.首先下载配置文件

![配置文件下载-1](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VhVzhPY3JteHZCS25YZGNQYlNHQzRzQnFRa01ybWw5V2tpMkstS01wZkgzdVE_ZT1EZ0Z5am0.jpg "点击“原始数据”")

![配置文件下载-2](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VYSjd0OWZkaTBOTnQ5UzU0QmxjemhZQjZQYzk2S0pnZ2F3Tmc4dnVMRmZNWXc_ZT1KTzNxTUs.jpg "保存配置文件为.yaml格式")

![配置文件下载-3](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VUMWUxLWxGNFRCRGt2djFZcFdFbWVBQnh6a0NwWlNNeGJJUWFSNlpQV21yM0E_ZT15SkZjYTQ.jpg "删除txt后缀进行保存")

#### 2.将下载下来的配置文件上传到 OpenClash

![配置文件上传](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VYa3hyQkhic2JwTWpBM1c4ejMzaGlvQjU5Z19SZi1Fd3NoUHZMcHJoYWNyR0E_ZT1uREJzVHY.jpg "在“配置管理”中上传yaml文件")

#### 3.编辑配置文件，并填写订阅地址

>如果有多个订阅地址，请根据文件里面的注释自行添加。

![填写订阅地址](https://dlink.host/1drv/aHR0cHM6Ly8xZHJ2Lm1zL2kvYy80YzkxYzM0ZDhjYThjYTMyL0VVUkp3RHZkUzYxTmprQU1XYTFOREhRQkpLQUZYVnRfZ1ZnMlFrTmlTYU40VUE_ZT1VNjZDWkU.jpg "添加订阅地址")

#### 4.下载配置好的 WebUI 配置文件

请注意！请使用如下命令获取 OpenClash 的 luci 配置，以配合配置文件使用，否则可能不能正常使用博主的配置：

```
wget -O /etc/config/openclash https://gitee.com/jackiewuu/unraid/raw/master/openclash/openclash
```
下载之后即可正常启动 openclash 。

#### 解决因 Geoip.dat 文件无法下载导致 openclash 无法启动的解决办法
如果是在 openwrt 上面使用 openclash，请使用如下命令在 openwrt 上手动下载 `Geoip.dat` 文件到 openclash 的配置我文件夹：

```
wget -O GeoIP.dat https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat
```
下载之后即可正常启动 openclash 。
