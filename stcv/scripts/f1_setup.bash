#!/bin/bash


# Show usage information
usage() {
    echo "Usage:  bash $0 $1 $2 $3 $4

Getting help:
-h      Display this help message.
"
}


set -e


# Parse positional args
export F1_DIR=$1
export F1_HOST=$2
export F1_PORT=$3
export ACTION=$4
echo "Fiftyone is located at $F1_DIR and will be installed under $F1_HOST:$F1_PORT"

cd $F1_DIR


if [ "${ACTION}" = "fix" ]; then
    echo "***** FIXING APP *****"
    cd ${F1_DIR}/app/packages/app/
    if [ -f ".env" ] ; then
        rm ".env"
    fi
    if [ -f ".env.development" ] ; then
        rm ".env.development"
    fi
    if [ -f ".env.development.local" ] ; then
        rm ".env.development.local"
    fi
    echo "VITE_API=$F1_HOST/proxy/$F1_PORT" >> .env
    cat .env

    old_value="vite build\","
    new_value="vite build --base=/proxy/${F1_PORT}/\","
    sed -i "s+${old_value}+${new_value}+g" ${F1_DIR}/app/packages/app/package.json

    old_value="http://{address}:{port}/"
    new_value="${F1_HOST}/proxy/${F1_PORT}/"
    sed -i "s+{old_value}+{new_value}+g" ${F1_DIR}/fiftyone/core/context.py

    old_value="?context="
    new_value="?polling=true\&context="
    sed -i "s+${old_value}+${new_value}+g" ${F1_DIR}/fiftyone/core/context.py
fi


if [ "${ACTION}" = "build" ]; then
    echo "***** BUILDING NODEJS APP *****"
    cd ${F1_DIR}/app
    yarn install > /dev/null 2>&1
    yarn build
fi


if [ "${ACTION}" = "install" ]; then
    echo "***** INSTALLING FIFTYONE *****"
    pip uninstall fiftyone fiftyone-brain fiftyone-db voxel51-eta -y

    echo "***** INSTALLING FIFTYONE-BRAIN *****"
    pip install fiftyone-brain

    echo "***** INSTALLING FIFTYONE *****"
    pip install -r requirements.txt
    pip install .
    pip uninstall opencv-python -y
    pip install opencv-python
    pip uninstall opencv-python-headless -y
    pip install opencv-python-headless

    echo "***** INSTALLING ETA *****"
    if [[ ! -d "eta" ]]; then
        echo "Cloning ETA repository"
        git clone https://github.com/voxel51/eta
    fi
    cd eta
    pip install .
    if [[ ! -f eta/config.json ]]; then
        echo "Installing default ETA config"
        cp config-example.json eta/config.json
    fi
fi


echo "***** TASKS COMPLETED *****"
