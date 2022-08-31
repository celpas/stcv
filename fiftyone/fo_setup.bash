#!/bin/bash


# Show usage information
usage() {
    echo "Usage:  bash $0 [-h] [-e] [-p]

Getting help:
-h      Display this help message.

Custom installations:
-e      Developer installation.
-p      Build NodeJS app.
"
}


# Parse flags
SHOW_HELP=false
DEV_INSTALL=false
BUILD_APP=false
while getopts "hdempv" FLAG; do
    case "${FLAG}" in
        e) DEV_INSTALL=true ;;
        p) BUILD_APP=true ;;
        *) usage ;;
    esac
done
[ ${SHOW_HELP} = true ] && usage && exit 0


set -e


cd fiftyone


if [ ${BUILD_APP} = true ]; then
    echo "***** BUILDING NODEJS APP *****"
    cd app
    yarn install > /dev/null 2>&1
    yarn build
    cd ..
fi


echo "***** INSTALLING FIFTYONE *****"
if [ ${DEV_INSTALL} = true ]; then
    pip uninstall fiftyone fiftyone-brain fiftyone-db voxel51-eta -y

    echo "***** INSTALLING FIFTYONE-BRAIN *****"
    pip install fiftyone-brain

    echo "***** INSTALLING FIFTYONE *****"
    pip install -r requirements.txt
    pip install .
    pip uninstall opencv-python -y
    pip install opencv-python==4.1.2.30
    pip uninstall opencv-python-headless -y
    pip install opencv-python-headless==4.1.2.30

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
    cd ..
fi


cd ..


echo "***** TASKS COMPLETED *****"
