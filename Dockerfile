# ใช้ Jenkins official image เป็น base image
FROM jenkins/jenkins:lts

# ติดตั้ง Flutter dependencies
USER root

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# เพิ่ม Dart repository
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://storage.googleapis.com/download.flutter.io/linux/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/dart_stable.list

# เพิ่ม key สำหรับ repository
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# ติดตั้ง Dart SDK
RUN apt-get update && apt-get install -y dart

# ติดตั้ง Flutter SDK
RUN curl -o flutter_linux.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.10-stable.tar.xz \
    && tar xf flutter_linux.tar.xz \
    && mv flutter /usr/local/flutter \
    && rm flutter_linux.tar.xz

# เพิ่ม Flutter และ Dart ลงใน PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:$PATH"

# รัน Flutter doctor เพื่อตรวจสอบการติดตั้ง
RUN flutter doctor

# กลับไปใช้ Jenkins user
USER jenkins

# ติดตั้ง Jenkins plugins ที่จำเป็น
RUN jenkins-plugin-cli --plugins "workflow-aggregator git junit blueocean"

# เปิดพอร์ตสำหรับ Jenkins
EXPOSE 8080
EXPOSE 50000
