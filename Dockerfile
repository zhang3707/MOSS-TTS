# 1. 依然使用官方轻量 Python 环境
FROM python:3.10-slim

# 2. 仅安装音频处理绝对必不可少的底层工具（砍掉所有重型编译工具，防止服务器死机）
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

# 6. 一行安装：直接强制使用预编译好的二进制包（不给服务器任何当场编译的机会！）
RUN pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install numpy==1.24.3 -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install -r requirements_onnx.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 7. 声明 Gradio 默认网页端口
EXPOSE 7860

# 8. 默认启动命令
CMD ["python", "app_onnx.py"]
