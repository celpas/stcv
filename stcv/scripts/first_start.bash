#!/bin/bash

STCV_DIR="/home/ec2-user/SageMaker/.stcv"
STCV_DOCKER_DIR=$1

echo "=> Changing Docker images directory from /var/lib/docker to ${STCV_DOCKER_DIR}"
sudo service docker stop
if [ ! -d ${STCV_DOCKER_DIR} ]; then
    sudo mkdir -p ${STCV_DIR} && mkdir -p ${STCV_DOCKER_DIR}
    sudo mv /var/lib/docker ${STCV_DOCKER_DIR}
fi
sudo rm -rf /var/lib/docker
sudo ln -s ${STCV_DOCKER_DIR} /var/lib/docker
sudo service docker start
