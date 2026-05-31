# 1. 使用官方轻量 Python 环境
FROM python:3.10-slim

# 2. 安装语音底层工具，并补全 Python-dev 编译头文件
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    git \
    gcc \
    g++ \
    make \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. 设置工作目录
WORKDIR /workspace

# 4. 先把源码全部复制进去
COPY . .

# 5. 限制 pip 的缓存和并发，防止挤爆阿里云服务器的内存 (防爆核心)
ENV PIP_NO_CACHE_DIR=1
ENV PIP_NEVER_CHECK_VERSION=1

# 6. 分步安装依赖，减轻服务器瞬间内存压力 (限流核心)
RUN pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install numpy==1.24.3 -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install onnxruntime==1.16.3 -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install -r requirements_onnx.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 7. 声明 Gradio 默认端口
EXPOSE 7860

# 8. 默认启动命令
CMD ["python", "app_onnx.py"]
