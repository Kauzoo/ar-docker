FROM ubuntu:latest AS builder
# Update etc
RUN apt update
# Install dependencies for opencv
RUN apt install -y cmake g++ wget unzip scons git

# Create non priviliged user
RUN groupadd -g 1234 ardocker && \
    useradd -m -u 1234 -g ardocker ardocker
# Switch to non-priviliged user
USER ardocker
# Set the workdir
WORKDIR /home/ardocker

# INSTALL OPENCV
# Download and unpack sources
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.x.zip && \
    unzip opencv.zip && unzip opencv_contrib.zip
 
# Create build directory
RUN mkdir build
RUN cd ./build

# Configure
RUN cmake -DOPENCV_EXTRA_MODULES_PATH=/home/ardocker/opencv_contrib-4.x/modules -DBUILD_LIST=core,imgcodecs,imgproc,videoio,objdetect,video,tracking /home/ardocker/opencv-4.x
 
# Build
RUN cmake --build .
USER root
RUN make install
USER ardocker
WORKDIR /home/ardocker

# Download Godot 4.4
RUN wget https://github.com/godotengine/godot-builds/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip && \
    unzip Godot_v4.4-stable_linux.x86_64.zip && \
    mv Godot_v4.4-stable_linux.x86_64 godot
# Compile api
RUN git clone -b 4.4 https://github.com/godotengine/godot-cpp
RUN ./godot --headless --dump-extension-api
WORKDIR /home/ardocker/godot-cpp
RUN scons platform=linux custom_api_file=/home/ardocker/extension_api.json


# STAGE 2
FROM ubuntu:latest
RUN apt update && \
    apt install -y g++ scons git
COPY --from=builder /usr/local/include/opencv4/ /usr/local/include
COPY --from=builder /usr/local/lib /usr/lib
RUN useradd -m ardocker
# Switch to non-priviliged user
USER ardocker
# Set the workdir
WORKDIR /home/ardocker
RUN mkdir -p opencv/lib && mkdir -p opencv/include && mkdir godot
ENV PATH=$PATH:/home/ardocker/godot
COPY --from=builder /home/ardocker/godot /home/ardocker/godot/
COPY --from=builder /home/ardocker/godot-cpp /home/ardocker/godot-cpp
WORKDIR /home/ardocker/ar-workspace/
USER root