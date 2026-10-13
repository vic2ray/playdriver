# Playwright + Google Chrome + 远程可视化 一体镜像（初版）
# 底包：python:3.12-slim-bookworm
FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DISPLAY=:99

# ---- 1. 系统包：Chrome 官方源 + 可视化三件套 + 中文字体 ----
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget gnupg ca-certificates \
        xvfb x11vnc websockify novnc \
        fonts-noto-cjk \
    && install -m 0755 -d /etc/apt/keyrings \
    && wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
        | gpg --dearmor -o /etc/apt/keyrings/google.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable \
    && rm -rf /var/lib/apt/lists

# ---- 2. Python 依赖 ----
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
# 国内网络慢可换源，例如：
# RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

# ---- 3. 启动脚本 + 示例脚本 ----
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
# COPY scripts/ ./scripts/

# 6080: noVNC 网页  5900: VNC  8000: 预留给你自己的服务端口
EXPOSE 6080 5900 8000

# 默认跑冒烟测试；运行时可覆盖，例如：
# docker run ... 你的镜像 python scripts/你自己的脚本.py
# CMD ["/usr/local/bin/start.sh", "python", "scripts/demo.py"]
