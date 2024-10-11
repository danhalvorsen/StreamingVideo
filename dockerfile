# Use an NVIDIA base image with CUDA support
FROM nvidia/cuda:12.0-runtime-ubuntu22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    yasm \
    pkg-config \
    libssl-dev \
    wget \
    git \
    && apt-get clean

# Install ffmpeg with NVENC support
RUN git clone https://git.ffmpeg.org/ffmpeg.git /ffmpeg
WORKDIR /ffmpeg
RUN ./configure \
    --enable-cuda \
    --enable-cuvid \
    --enable-nvenc \
    --enable-nonfree \
    --enable-libnpp \
    --extra-cflags=-I/usr/local/cuda/include \
    --extra-ldflags=-L/usr/local/cuda/lib64 \
    --enable-openssl && \
    make -j$(nproc) && \
    make install

# Clean up the build files to reduce image size
WORKDIR /
RUN rm -rf /ffmpeg

# Set up entrypoint to use ffmpeg directly
ENTRYPOINT ["ffmpeg"]
