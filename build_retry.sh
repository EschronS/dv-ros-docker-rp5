#!/bin/bash

until docker build \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --build-arg USERNAME=$(whoami) \
  -t dv-ros-mnt .; do
  echo "Build failed, retrying in 20min..."
  sleep 1200
done

echo "Build succeeded!"
