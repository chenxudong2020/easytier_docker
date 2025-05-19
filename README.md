# easytier_docker
easytier docker 版本源码 可以通过命令行或者配置文件运行 配置文件优先</br> 
## 配置参数运行
docker run -itd --name easytier -v ./config.yaml:/config.yaml --device=/dev/net/tun --net=host --restart=always --cap-add=NET_ADMIN --cap-add=SYS_ADMIN registry.cn-hangzhou.aliyuncs.com/dubux/easytier:latest </br>
## 命令行参数运行
docker run -itd --name easytier -e COMMNAD="" --device=/dev/net/tun --net=host --restart=always --cap-add=NET_ADMIN --cap-add=SYS_ADMIN registry.cn-hangzhou.aliyuncs.com/dubux/easytier:latest </br>
