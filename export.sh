#!/bin/sh
EXPORT_DIR=./ar-docker-export
mkdir -p $EXPORT_DIR/{godot-cpp,opencv/{lib,include}}
docker create --pull missing --name ar-docker-export kauzoo/ar-docker:latest
echo Exporting to $EXPORT_DIR
docker cp ar-docker-export:/home/ardocker/export/opencv/lib/ $EXPORT_DIR/opencv/lib
docker cp ar-docker-export:/home/ardocker/export/opencv/include/ $EXPORT_DIR/opencv/include
docker cp ar-docker-export:/home/ardocker/export/godot-cpp/ $EXPORT_DIR/godot-cpp
docker rm ar-docker-export
