# 1. 使用专为大模型和 PyTorch 准备的轻量化基础镜像
FROM python:3.10-slim

# 2. 安装语音和音频处理必备的系统底层库
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    git \
    gcc \
    g++ \
    make \
    && rm -rf /lib/apt/lists/*

# 3. 设置容器内的工作目录
WORKDIR /workspace

# 4. 先复制依赖清单，利用 Docker 缓存加速后续打包
COPY requirements.txt .

# 5. 安装 Python 依赖（使用清华源加速）
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 6. 把项目的全部源码（包括刚才拉取的子模块）复制进去
COPY . .

# 7. 声明容器内部使用的 Gradio Web 默认端口
EXPOSE 7860

# 8. 默认启动命令：运行 Web 交互界面
CMD ["python", "app.py"]
