# Base image
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    && apt-get clean

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Pre-cache Flutter dependencies
RUN flutter doctor
RUN flutter precache

# Set working directory
WORKDIR /app

# Copy your Flutter project
COPY . /app

# Run flutter pub get to fetch packages
RUN flutter pub get

# Command to run the application (default to bash)
CMD ["bash"]
