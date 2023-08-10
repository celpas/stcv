#!/bin/bash

STCV_DIR="/home/ec2-user/SageMaker/.stcv"
STCV_DOCKER_DIR=$1

sudo -u ec2-user mkdir -p ${STCV_DIR}

echo "=> Changing Docker images directory from /var/lib/docker to ${STCV_DOCKER_DIR}"
sudo service docker stop
if [ ! -d ${STCV_DOCKER_DIR} ]; then
    sudo mkdir -p ${STCV_DOCKER_DIR}
fi
sudo mv /var/lib/docker /var/lib/docker_old
sudo ln -s ${STCV_DOCKER_DIR} /var/lib/docker
sudo service docker start

echo "=> Setting persistent environment variables"
cat << EOF >> /home/ec2-user/.bashrc

export FIFTYONE_DATABASE_URI=mongodb://127.0.0.1:27017
export FIFTYONE_DEFAULT_DATASET_DIR=/home/ec2-user/SageMaker/.stcv/fiftyone_data_dir

EOF
source /home/ec2-user/.bashrc
