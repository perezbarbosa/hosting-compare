#!/bin/bash

docker rm $(docker ps -a -q)
images=$(docker images | grep minute | awk '{ print $3}')

for image in $images
do
  docker rmi $image
done
