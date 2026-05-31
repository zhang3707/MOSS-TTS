# 1. 依然使用最稳定的 Debian 11 纯净系统
FROM python:3.10-slim-bullseye

# 2. 安装音频处理必不可少的工具（补回纯净版 gcc/g++ 以防万一，Bullseye系统装这个很快，不卡死）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    git \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 3. 设置工作目录
WORKDIR /workspace

# 4. 把项目的全部源码复制进去
COPY . .

# 5. 开启防爆内存环境变量
ENV PIP_NO_CACHE_DIR=1
ENV PIP_NEVER_CHECK_VERSION=1

# 6. 绕过原厂 requirements_onnx.txt，直接手动安装核心依赖（核心防御策略！）
RUN pip install --upgrade pip && \
    pip install numpy==1.24.3 scipy librosa soundfile gradio && \
    pip install onnxruntime==1.16.3

# 7. 声明 Gradio 默认网页端口
EXPOSE 7860

# 8. 默认启动命令
CMD ["python", "moss_tts_local/app.py"]
