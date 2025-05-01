#!/bin/bash
CONTAINER_NAME=my-angular-app
IMAGE=jordanhenman/henman-ceg3120

docker pull $IMAGE
docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
docker run -d --name $CONTAINER_NAME -p 80:80 $IMAGE
