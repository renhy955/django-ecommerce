# ============================================
# 第一阶段：构建阶段 - 安装依赖和准备环境
# ============================================
FROM ubuntu:20.04 AS builder

# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置工作目录
WORKDIR /app

# 更新包列表并安装系统依赖
# 包括 Python 3、pip、以及 Pillow 所需的图像处理库
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖包
# 使用 --no-cache-dir 减小镜像大小
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# 复制项目文件到构建目录
COPY . .

# 设置环境变量以避免收集静态文件时的交互式提示
ENV DJANGO_SETTINGS_MODULE=djecommerce.settings.development
ENV SECRET_KEY="django-insecure-build-key-temporary"
ENV DEBUG="True"
ENV STRIPE_TEST_PUBLIC_KEY="pk_test_build"
ENV STRIPE_TEST_SECRET_KEY="sk_test_build"

# 收集静态文件
RUN python3 manage.py collectstatic --noinput

# ============================================
# 第二阶段：运行阶段 - 创建最终镜像
# ============================================
FROM ubuntu:20.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=djecommerce.settings.development

# 设置工作目录
WORKDIR /app

# 安装运行时依赖（仅包含必要的包）
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    libjpeg8 \
    zlib1g \
    libpng16-16 \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制 Python 包
COPY --from=builder /usr/local/lib/python3.8/dist-packages /usr/local/lib/python3.8/dist-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 从构建阶段复制项目文件
COPY --from=builder /app /app

# 创建必要的目录
# 用于存储 SQLite 数据库和媒体文件
RUN mkdir -p /app/media_root /app/static_root

# 创建数据卷用于持久化数据
VOLUME ["/app/media_root", "/app/static_root"]

# 暴露端口 8000
EXPOSE 8000

# 创建启动脚本
# 包含数据库迁移、初始化数据和服务启动命令
RUN echo '#!/bin/bash\n\
    set -e\n\
    echo "正在执行数据库迁移..."\n\
    python3 manage.py migrate --noinput\n\
    echo "数据库迁移完成"\n\
    echo "正在初始化数据..."\n\
    python3 /app/init_data.py\n\
    echo "数据初始化完成"\n\
    echo "正在启动 Django 服务..."\n\
    python3 manage.py runserver 0.0.0.0:8000\n\
    ' > /app/start.sh && chmod +x /app/start.sh

# 健康检查
# 每 30 秒检查一次服务是否正常运行
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

# 设置默认环境变量（可被 docker run -e 覆盖）
ENV SECRET_KEY="django-insecure-development-key-change-in-production-12345"
ENV STRIPE_TEST_PUBLIC_KEY="pk_test_example"
ENV STRIPE_TEST_SECRET_KEY="sk_test_example"
ENV DEBUG="True"
ENV ALLOWED_HOSTS="localhost,127.0.0.1,0.0.0.0,[::1]"

# 启动命令
CMD ["/app/start.sh"]
