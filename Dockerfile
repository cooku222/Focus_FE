# 기본 Debian 이미지 사용
FROM debian:bullseye-slim

# Flutter 설치에 필요한 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libstdc++6 \
    fonts-noto-color-emoji \
    cmake \
    && apt-get clean

# Flutter SDK 설치
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Flutter 초기화
RUN flutter doctor
RUN flutter precache

# 작업 디렉터리 설정
WORKDIR /app

# 프로젝트 복사
COPY . .

# Flutter 의존성 설치
RUN flutter pub get

# Flutter 웹 빌드
RUN flutter build web --release

# 빌드 결과물을 외부로 내보내기 위한 볼륨 지정
VOLUME ["/output"]

# Flutter 웹 서버 실행
CMD ["flutter", "run", "-d", "web-server", "--web-port=80"]
