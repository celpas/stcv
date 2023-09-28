FROM public.ecr.aws/ubuntu/ubuntu:23.04_stable

SHELL ["/bin/bash", "-c"]

#################################
# Parameters

# => Build-args
ARG STCV_INSTANCE_ADDRESS
ARG STCV_FIFTYONE_1_BUILD
ARG STCV_FIFTYONE_2_BUILD
ARG STCV_FIFTYONE_3_BUILD

# => ARG to ENV
ENV STCV_INSTANCE_ADDRESS="$STCV_INSTANCE_ADDRESS"
ENV STCV_FIFTYONE_1_BUILD="$STCV_FIFTYONE_1_BUILD"
ENV STCV_FIFTYONE_2_BUILD="$STCV_FIFTYONE_2_BUILD"
ENV STCV_FIFTYONE_3_BUILD="$STCV_FIFTYONE_3_BUILD"

# => Versions
ENV STCV_PYTHON_VERSION="3.9"
ENV STCV_NODE_VERSION="18.13.0"
ENV STCV_CODESERVER_VERSION="4.17.0"
ENV STCV_FIFTYONE_VERSION="0.22.0"
ENV STCV_S3FS_VERSION="1.93"

# => Fiftyone ports
ENV STCV_FIFTYONE_1_PORT="6010"
ENV STCV_FIFTYONE_2_PORT="6011"
ENV STCV_FIFTYONE_3_PORT="6012"

#################################
# Setup environment

USER root

RUN apt-get update && apt-get install -y gnupg curl && \
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libopencv-dev \
    libspdlog-dev \
    gnupg \
    libssl-dev \
    libprotobuf-dev protobuf-compiler \
    build-essential \
    libjpeg-dev \
    libpng-dev \
    ccache \
    cmake \
    gcc \
    g++ \
    git \
    vim \
    wget \
    unzip \
    nginx \
    php8.1-fpm \
    libcurl4 \
    mongodb-org \
    libfuse2 \
    libfuse-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    autotools-dev \
    automake \
    nano \
    sudo \
    lsof

# => Install miniconda & pip
RUN curl -fsSL -v -o ${HOME}/miniconda.sh -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ${HOME}/miniconda.sh && \
    bash ${HOME}/miniconda.sh -b -p /opt/conda && \
    rm ${HOME}/miniconda.sh && \
    /opt/conda/bin/conda install -y python=${STCV_PYTHON_VERSION} conda-build pyyaml numpy ipython cython typing typing_extensions mkl mkl-include ninja && \
    /opt/conda/bin/conda clean -ya
ENV PATH="/opt/conda/bin:${PATH}"

# => Install s3fs
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git ${HOME}/s3fs-fuse --depth 1 && \
    cd ${HOME}/s3fs-fuse && \
    git checkout -b v${STCV_S3FS_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ${HOME} && \
    rm -rf s3fs-fuse && \
    echo user_allow_other >> /etc/fuse.conf

# => Install mount-s3
RUN wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb -O ${HOME}/mount-s3.deb && \
    apt-get install -y ${HOME}/mount-s3.deb && \
    echo "user_allow_other" | tee /etc/fuse.conf

# => Create ec2-user
RUN userdel ubuntu && \
    adduser --disabled-password --gecos "" ec2-user && \
    adduser ec2-user sudo && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# => Active ec2-user
USER ec2-user
RUN mkdir -p /home/ec2-user && mkdir -p /home/ec2-user/SageMaker && mkdir -p /home/ec2-user/workspace
WORKDIR /home/ec2-user/workspace
ENV WORKSPACE_DIR="/home/ec2-user/workspace"

# => Install Node.js
ENV NVM_DIR="/home/ec2-user/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . ${NVM_DIR}/nvm.sh && \
    nvm install ${STCV_NODE_VERSION}  && \
    nvm alias default ${STCV_NODE_VERSION} && \
    nvm use default
ENV PATH="${NVM_DIR}/versions/node/v${STCV_NODE_VERSION}/bin/:${PATH}"
RUN npm install -g yarn

#################################
# Copy STCV

COPY /stcv ${WORKSPACE_DIR}/stcv

ENV STCV_CONFIGS_DIR="${WORKSPACE_DIR}/stcv/configs"
ENV STCV_HTML_DOCS_DIR="${WORKSPACE_DIR}/stcv/html_docs"
ENV STCV_SCRIPTS_DIR="${WORKSPACE_DIR}/stcv/scripts"

# => Fix permissions
RUN sudo chown -R ec2-user:ec2-user ${WORKSPACE_DIR}/stcv
RUN sudo chmod -R 777 ${WORKSPACE_DIR}/stcv

#################################
# Install FiftyOne

ENV STCV_FIFTYONE_URL="https://github.com/voxel51/fiftyone/archive/refs/tags/v$STCV_FIFTYONE_VERSION.tar.gz"

RUN if [ ${STCV_FIFTYONE_1_BUILD} = "True" ] || [ ${STCV_FIFTYONE_2_BUILD} = "True" ] || [ ${STCV_FIFTYONE_3_BUILD} = "True" ] ; \
    then \
        wget ${STCV_FIFTYONE_URL} --no-verbose ; \
    fi

ENV STCV_FIFTYONE_1_DIR="${WORKSPACE_DIR}/fiftyone_1"
RUN if [ ${STCV_FIFTYONE_1_BUILD} = "True" ] ; \
    then \
        mkdir -p $STCV_FIFTYONE_1_DIR ; \
        tar -zxf ${WORKSPACE_DIR}/v$STCV_FIFTYONE_VERSION.tar.gz -C $STCV_FIFTYONE_1_DIR --strip-components=1 ; \
        python -m venv ${WORKSPACE_DIR}/.envs/fo_1 ; \
        source ${WORKSPACE_DIR}/.envs/fo_1/bin/activate ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_1_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_1_PORT}" fix ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_1_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_1_PORT}" build ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_1_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_1_PORT}" install ; \
        rm -rf ${STCV_FIFTYONE_1_DIR} ; \
        deactivate ; \
    else \
        echo "FiftyOne session 1 not installed!" ; \
    fi

ENV STCV_FIFTYONE_2_DIR="${WORKSPACE_DIR}/fiftyone_2"
RUN if [ ${STCV_FIFTYONE_2_BUILD} = "True" ] ; \
    then \
        mkdir -p $STCV_FIFTYONE_2_DIR ; \
        tar -zxf ${WORKSPACE_DIR}/v$STCV_FIFTYONE_VERSION.tar.gz -C $STCV_FIFTYONE_2_DIR --strip-components=1 ; \
        python -m venv ${WORKSPACE_DIR}/.envs/fo_2 ; \
        source ${WORKSPACE_DIR}/.envs/fo_2/bin/activate ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_2_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_2_PORT}" fix ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_2_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_2_PORT}" build ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_2_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_2_PORT}" install ; \
        rm -rf ${STCV_FIFTYONE_2_DIR} ; \
        deactivate ; \
    else \
        echo "FiftyOne session 2 not installed!" ; \
    fi

ENV STCV_FIFTYONE_3_DIR="${WORKSPACE_DIR}/fiftyone_3"
RUN if [ ${STCV_FIFTYONE_3_BUILD} = "True" ] ; \
    then \
        mkdir -p $STCV_FIFTYONE_3_DIR ; \
        tar -zxf ${WORKSPACE_DIR}/v$STCV_FIFTYONE_VERSION.tar.gz -C $STCV_FIFTYONE_3_DIR --strip-components=1 ; \
        python -m venv ${WORKSPACE_DIR}/.envs/fo_3 ; \
        source ${WORKSPACE_DIR}/.envs/fo_3/bin/activate ; \
        git clone https://github.com/voxel51/fiftyone.git --depth 1 ${STCV_FIFTYONE_3_DIR} ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_3_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_3_PORT}" fix ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_3_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_3_PORT}" build ; \
        ${STCV_SCRIPTS_DIR}/f1_setup.bash "${STCV_FIFTYONE_3_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_3_PORT}" install ; \
        rm -rf ${STCV_FIFTYONE_3_DIR} ; \
        deactivate ; \
    else \
        echo "FiftyOne session 3 not installed!" ; \
    fi

#################################
# Install LabelStudio, MLFlow and TensorBoard

ENV PATH="/home/ec2-user/.local/bin:${PATH}"

RUN pip install mlflow tensorboard

RUN git clone https://github.com/HumanSignal/label-studio.git --depth 1 && \
    ${STCV_SCRIPTS_DIR}/ls_setup.bash ${WORKSPACE_DIR}/label-studio && \
    cd ${WORKSPACE_DIR}/label-studio && \
    pip install . && \
    rm -rf ${WORKSPACE_DIR}/label-studio

#################################
# Configure STCV

# => code-server
RUN sudo -u ec2-user wget https://raw.githubusercontent.com/coder/code-server/main/install.sh -O ${WORKSPACE_DIR}/install.sh && \
    chmod +x ${WORKSPACE_DIR}/install.sh && \
    ${WORKSPACE_DIR}/install.sh --version ${STCV_CODESERVER_VERSION} && \
    rm -rf ${HOME}/.config/code-server/config.yaml && \
    mkdir -p ${HOME}/.config/code-server && \
    cp ${STCV_CONFIGS_DIR}/config.yaml ${HOME}/.config/code-server/config.yaml && \
    code-server --install-extension ms-python.python --force && \
    code-server --install-extension ms-toolsai.jupyter --force && \
    mkdir -p /home/ec2-user/.local/share/code-server && \
    mkdir -p /home/ec2-user/.local/share/code-server/User && \
    rm -rf /home/ec2-user/.local/share/code-server/User/settings.json && \
    cp ${STCV_CONFIGS_DIR}/settings.json /home/ec2-user/.local/share/code-server/User/settings.json

# => nginx
RUN sudo rm -rf /etc/nginx/nginx.conf && \
    sudo cp ${STCV_CONFIGS_DIR}/nginx.conf /etc/nginx/nginx.conf

# => php
RUN sudo rm -rf /etc/php/8.1/fpm/pool.d/www.conf && \
    sudo rm -rf /etc/php/8.1/fpm/php.ini && \
    sudo cp ${STCV_CONFIGS_DIR}/www.conf /etc/php/8.1/fpm/pool.d/www.conf && \
    sudo cp ${STCV_CONFIGS_DIR}/php.ini /etc/php/8.1/fpm/php.ini

# => elfinder
ENV ELFINDER_DIR="${WORKSPACE_DIR}/elFinder-2.1.62"
RUN wget https://github.com/Studio-42/elFinder/archive/refs/tags/2.1.62.tar.gz && \
    tar -zxf ${WORKSPACE_DIR}/2.1.62.tar.gz && \
    cp ${STCV_CONFIGS_DIR}/connector.minimal.php ${ELFINDER_DIR}/php/connector.minimal.php && \
    mv ${ELFINDER_DIR} ${STCV_HTML_DOCS_DIR}/finder && \
    rm -rf ${STCV_HTML_DOCS_DIR}/finder/elfinder.html && \
    cp ${STCV_CONFIGS_DIR}/elfinder.html ${STCV_HTML_DOCS_DIR}/finder/elfinder.html && \
    rm -rf ${WORKSPACE_DIR}/2.1.62.tar.gz

# => ez
RUN git clone https://github.com/shevabam/ezservermonitor-web.git --depth 1 && \
    cp -R ${WORKSPACE_DIR}/ezservermonitor-web ${STCV_HTML_DOCS_DIR}/ez && \
    rm -rf ${STCV_HTML_DOCS_DIR}/ez/index.php && \
    rm -rf ${STCV_HTML_DOCS_DIR}/ez/conf/esm.config.json && \
    rm -rf ${STCV_HTML_DOCS_DIR}/ez/web/css/frontend.css && \
    cp ${STCV_CONFIGS_DIR}/index.php ${STCV_HTML_DOCS_DIR}/ez/index.php && \
    cp ${STCV_CONFIGS_DIR}/esm.config.json ${STCV_HTML_DOCS_DIR}/ez/conf/esm.config.json && \
    cp ${STCV_CONFIGS_DIR}/frontend.css ${STCV_HTML_DOCS_DIR}/ez/web/css/frontend.css && \
    rm -rf ${WORKSPACE_DIR}/ezservermonitor-web

#################################
# Start

# => Cleaning
USER root
RUN pip cache purge
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /home/ec2-user/.cache && \
    rm -rf /var/lib/apt/lists/*

# => Start stcv
USER ec2-user
ENTRYPOINT ["/home/ec2-user/workspace/stcv/scripts/start_stcv.bash"]
