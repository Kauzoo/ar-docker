# AR-Exercise on Linux

Since I ran into some really painfull setup issues I've written down some stuff I learned along the way. This repository contains some tips to setup your development environment for the exercises in the Augemented Reality lecutre. Recommendations about [building from source](#manual-installation) or using a [docker image](#docker) (recommended to save time).

## Manual Installation
If your distribution of choice does not have opencv in its repositories you have to install it using *homebrew* or build it from source.

**Relevant Links**  
- https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html
- https://docs.opencv.org/4.x/d0/da7/videoio_overview.html

**Notes on building from source**
- You need both the [opencv](https://github.com/opencv/opencv) and [opencv_contrib](https://github.com/opencv/opencv_contrib) repos
- Make sure `ffmpeg` is installed
- Check output of the cmake configuration stage to make sure everything you need is included
    - `VideoIO: FFMPEG On`
    - `Modules: core,imgcodecs,imgproc,videoio,objdetect,video,tracking`
- If the build refuses to include `ffmpeg`, try removing it, installing `pkg-config` and then reinstalling `ffmpeg` (potentially alongside `libavformat-dev libavcodec-dev libswscale-dev`)
- Using `make install` the `.so` files are only installed to `/usr/local/lib` which is not on the default linker path, therefore you either need to add it to your linker path (`LD_LIBRARY_PATH` for gcc) or copy all required `.so` files to your projects `bin` folder
- You might need to update your c++ header include path (`CPLUS_INCLUDE_PATH`)
- Build only selected modules using: `-DBUILD_LIST=<module-list>`
- Enable ffmpeg video backend: `-DWITH_FFMPEG=ON`
- Enable dynamically linked ffmpeg: `-DWITH_FFMPEG=ON -DVIDEOIO_PLUGIN_LIST=ffmpeg` 
- Inside your build directory
```
cmake -DOPENCV_EXTRA_MODULES_PATH=path/to/opencv_contrib-\<version>/modules -DBUILD_LIST=\<module-list> -DWITH_FFMPEG=ON \<-DVIDEOIO_PLUGIN_LIST=ffmpeg> path/to/opencv-\<verison>
```
- Exmaple Usage
```
cmake -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-4.9.0/modules -DBUILD_LIST=core,imgcodecs,imgproc,videoio,objdetect,video,tracking -DWITH_FFMPEG=ON -DVIDEOIO_PLUGIN_LIST=ffmpeg ../opencv-4.9.0
```
## Docker
Get Docker Image
```  
docker pull kauzoo/ar-docker:latest  
```
OpenCV is built from source, using only modules required for lecture and dependencies. Ffmpeg is used as dynamicaly linked VideoIO backend (libopencv_videoio_ffmpeg.so). Versions and module list can be tweaked using docker build-arguments (See [build](#build-for-custom-version)).    
- OpenCV-version: 4.9.0 (default)
- OpenCV_contrib-version: 4.9.0 (default)
- Godot-version: 4.4.0 (default)
- Godot-cpp-version: 4.4 (default)



### Devcontainer
You can use the docker container as your development environment for compilation and code editing. The godot editor should be run on your host machine (running it inside the container doesn't work properly). The `.devcontainer.json` file can be copied into the root of your project (next to sourcecode src/ and godotproject (probably demo) directory) to set your project up as a vscode dev container. Open your project folder with vscode and you should be prompted to *Reopen in Container*.
1. Pull docker image  
```
docker pull kauzoo/ar-docker:latest
```
2. In `.devcontainer.json` adjust 
    - `WORKSPACE_FOLDER` = project directory
    - `GODOT_PROJECT_NAME` = godot project directory (contains project.godot)

2. Copy `.devcontainer.json` to the root folder of your project (next to the `SConstruct` file etc.)
3. Open the project folder in vscode
4. Run `>Dev Containers: Reopen in Container` (`Ctrl+Shift+P`)
5. (First Usage) Copy godot-cpp to your project
```
cp -r /home/ardocker/export/godot-cpp "/workspaces/$WORKSPACE_FOLDER/godot-cpp"
``` 
6. (First Usage) Copy libs to your project
```
cp -r /usr/lib/libopencv_* "/workspaces/"$WORKSPACE_FOLDER/$GODOT_PROJECT_NAME/bin/
```
7. Build from inside the container
```
scons platform=linux
```
8. On Host machine: Open godot project like usual

### Exporting
If you just want to export all relevant files you can use the `export.sh` script. The latest version of the image will be pulled with default settings and the files will be exported. (**Hint:** Docker must be installed).
- opencv-libs (*.so): -> `./ar-docker-export/opencv/lib`
- opencv-headers: -> `./ar-docker-export/opencv/include`
- godot-cpp: -> `./ar-docker-export/godo-cpp`


### Build Custom Version
###### Build Arguments (Defaults)
- opencv_version=4.9.0
- godot_version=4.4-stable
- gd_cpp_version=4.4
- opencv_build_list=core,imgcodecs,imgproc,videoio,objdetect,video,tracking

**Example Usage**
```
$ docker build --build-arg opencv_version=4.9.0 --build-arg godot_version=4.4-stable --build-arg gd_cpp_version=4.4 --build-arg opencv_build_list=core,imgcodecs,imgproc,videoio,objdetect,video,tracking .
```

## Troubleshooting
- If godot produces the `Couldn't open camera.` error ffmpeg is proabably not enables as backend
