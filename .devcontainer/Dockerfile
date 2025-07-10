FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 必要なパッケージのインストール
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    wget curl git unzip xz-utils zip libglu1-mesa \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK のダウンロードとインストール
ARG FLUTTER_VERSION=3.32.6-stable
RUN cd /usr/local && \
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}.tar.xz && \
    rm flutter_linux_${FLUTTER_VERSION}.tar.xz && \
    chown -R vscode:vscode /usr/local/flutter

# PATH の設定
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# vscode ユーザーに切り替え
USER vscode

# Flutter の設定
RUN flutter config --enable-web && \
    flutter config --no-analytics && \
    flutter precache

# 作業ディレクトリの設定
WORKDIR /workspace

# ポートの公開
EXPOSE 3000 8080 9000