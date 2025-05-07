# Godot + OpenCV Linux Support

This repository contains some info to setup linux for usage in the exercises of the Augmented Reality lecture.

### Docker
OpenCV is built from source, only modules required for lecture and dependencies. Ffmpeg is used as dynamicaly linked VideoIO backend (libopencv_videoio_ffmpeg.so). List and version of opencv modules built can be tweaked using docker build args. Godot is downloaded as precompiled binary.    
- OpenCV-version: 4.9.0 (default)
- OpenCV_contrib-version: 4.9.0 (default)
- Godot-version: 4.4.0 (default)
- Godot-cpp-version: 4.4 (default)

#### Build for custom version
###### Build Arguments
- opencv_version=4.9.0
- godot_version=4.4-stable
- gd_cpp_version=4.4
- opencv_build_list=core,imgcodecs,imgproc,videoio,objdetect,video,tracking
> `$ docker build --build-arg opencv_version=4.9.0 --build-arg godot_version=4.4-stable --build-arg gd_cpp_version=4.4 --build-arg opencv_build_list=core,imgcodecs,imgproc,videoio,objdetect,video,tracking .`