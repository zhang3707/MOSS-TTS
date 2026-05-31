# 1. 锁死最稳定的 Debian 11 (Bullseye) 纯净系统
FROM python:3.10-slim-bullseye

# 2. 安装音频处理绝对必不可少的底层工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# 3. 设置工作目录
WORKDIR /workspace

# 4. 把项目的全部源码复制进去
COPY . .

# 5. 开启防爆内存环境变量
ENV PIP_NO_CACHE_DIR=1
ENV PIP_NEVER_CHECK_VERSION=1

# 6. 删掉清华源，直接使用官方源（海外机器直连官方源，速度极快且版本最全）
RUN pip install --upgrade pip && \
    pip install -r requirements_onnx.txt

# 7. 声明 Gradio 默认网页端口
EXPOSE 7860

# 8. 默认启动命令
CMD ["python", "app_onnx.py"]
