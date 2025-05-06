FROM ubuntu:latest AS builder
# Build args
ARG opencv_version=4.9.0
ARG godot_version=4.4-stable
ARG gd_cpp_version=4.4
ARG opencv_build_list=core,imgcodecs,imgproc,videoio,objdetect,video,tracking
ARG gdproj_name=demo

# Update & Install dependencies for opencv, godot
RUN apt update
RUN apt install -y pkg-config
RUN apt install -y build-essential cmake g++ wget unzip scons git ffmpeg libavformat-dev libavcodec-dev libswscale-dev 
# Create non priviliged user
RUN groupadd -g 1234 ardocker && \
    useradd -m -u 1234 -g ardocker ardocker
USER ardocker
WORKDIR /home/ardocker
# INSTALL GODOT & DUMP CPP BINDINGS
# Download Godot 4.4
RUN wget https://github.com/godotengine/godot-builds/releases/download/${godot_version}/Godot_v${godot_version}_linux.x86_64.zip && \
    unzip Godot_v${godot_version}_linux.x86_64.zip && \
    mv Godot_v${godot_version}_linux.x86_64 godot
## Compile api
RUN git clone -b ${gd_cpp_version} https://github.com/godotengine/godot-cpp
RUN ./godot --headless --dump-extension-api
WORKDIR /home/ardocker/godot-cpp
RUN scons platform=linux custom_api_file=/home/ardocker/extension_api.json
# INSTALL OPENCV
# Download and unpack sources
WORKDIR /home/ardocker
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/${opencv_version}.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/${opencv_version}.zip && \
    unzip opencv.zip && unzip opencv_contrib.zip && mkdir build
# BUILD
# Configure
WORKDIR /home/ardocker/build
RUN cmake -DOPENCV_EXTRA_MODULES_PATH=/home/ardocker/opencv_contrib-${opencv_version}/modules -DBUILD_LIST=${opencv_build_list} -DWITH_FFMPEG=ON -DVIDEOIO_PLUGIN_LIST=ffmpeg /home/ardocker/opencv-${opencv_version}
 
# Build
RUN cmake --build .
USER root
RUN make install
USER ardocker
WORKDIR /home/ardocker
