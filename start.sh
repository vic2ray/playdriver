#!/bin/bash
# 启动链路：Xvfb(虚拟显示器) -> x11vnc -> noVNC(网页) -> 你的脚本/服务
set -e

# 1. 虚拟显示器 :99
Xvfb :99 -screen 0 1280x800x24 &
export DISPLAY=:99

# 2. VNC 服务（内网调试用；生产环境建议加 -passwd 或只监听内网）
x11vnc -display :99 -forever -shared -nopw -rfbport 5900 &

# 3. noVNC：浏览器打开 http://宿主机IP:6080 即可实时观看
websockify --web /usr/share/novnc 6080 localhost:5900 &

sleep 1
echo "=== 可视化就绪 ==="
echo "noVNC: http://<宿主机IP>:6080   VNC: <宿主机IP>:5900"
echo "=================="

# 4. 执行传入的命令（默认是 demo.py）
exec "$@"
