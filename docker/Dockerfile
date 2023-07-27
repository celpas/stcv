FROM public.ecr.aws/ubuntu/ubuntu:23.04_stable

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
ENV STCV_PYTHON_VERSION="3.8"
ENV STCV_NODE_VERSION="18.13.0"
ENV STCV_CODESERVER_VERSION="4.15.0"
ENV STCV_FIFTYONE_VERSION="0.21.4"

# => Fiftyone ports
ENV STCV_FIFTYONE_1_PORT="6010"
ENV STCV_FIFTYONE_2_PORT="6011"
ENV STCV_FIFTYONE_3_PORT="6012"

#################################
# Setup environment

USER root
RUN mkdir -p /home/ec2-user && mkdir -p /home/ec2-user/SageMaker
RUN mkdir -p /root/workspace
WORKDIR /root/workspace

RUN apt-get update && apt-get install -y gnupg curl && \
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libopencv-dev libspdlog-dev \
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
    && rm -rf /var/lib/apt/lists/*

# => Install Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${STCV_NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${STCV_NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${STCV_NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${STCV_NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version
RUN npm install -g yarn

# => Install miniconda & pip
RUN curl -fsSL -v -o ~/miniconda.sh -O  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -y python=${STCV_PYTHON_VERSION} conda-build pyyaml numpy ipython cython typing typing_extensions mkl mkl-include ninja && \
    /opt/conda/bin/conda clean -ya
ENV PATH="/opt/conda/bin:${PATH}"

#################################
# Copy STCV

COPY /stcv /root/workspace/stcv

#################################
# Install FiftyOne

SHELL ["/bin/bash", "-c"]

RUN chmod +x /root/workspace/stcv/scripts/f1_setup.bash

ENV STCV_FIFTYONE_URL="https://github.com/voxel51/fiftyone/archive/refs/tags/v$STCV_FIFTYONE_VERSION.tar.gz"

RUN if [ ${STCV_FIFTYONE_1_BUILD} = "True" ] || [ ${STCV_FIFTYONE_2_BUILD} = "True" ] || [ ${STCV_FIFTYONE_3_BUILD} = "True" ] ; \
    then \
        wget ${STCV_FIFTYONE_URL} --no-verbose ; \
    fi

ENV STCV_FIFTYONE_1_DIR="/root/workspace/fiftyone_1"
RUN if [ ${STCV_FIFTYONE_1_BUILD} = "True" ] ; \
    then \
        mkdir -p $STCV_FIFTYONE_1_DIR ; \
        tar -zxf /root/workspace/v$STCV_FIFTYONE_VERSION.tar.gz -C $STCV_FIFTYONE_1_DIR --strip-components=1 ; \
        python -m venv /root/workspace/.envs/fo_1 ; \
        source /root/workspace/.envs/fo_1/bin/activate ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_1_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_1_PORT}" fix ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_1_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_1_PORT}" build ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_1_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_1_PORT}" install ; \
        rm -rf ${STCV_FIFTYONE_1_DIR} ; \
        deactivate ; \
    else \
        echo "FiftyOne session 1 not installed!" ; \
    fi

ENV STCV_FIFTYONE_2_DIR="/root/workspace/fiftyone_2"
RUN if [ ${STCV_FIFTYONE_2_BUILD} = "True" ] ; \
    then \
        mkdir -p $STCV_FIFTYONE_2_DIR ; \
        tar -zxf /root/workspace/v$STCV_FIFTYONE_VERSION.tar.gz -C $STCV_FIFTYONE_2_DIR --strip-components=1 ; \
        python -m venv /root/workspace/.envs/fo_2 ; \
        source /root/workspace/.envs/fo_2/bin/activate ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_2_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_2_PORT}" fix ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_2_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_2_PORT}" build ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_2_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_2_PORT}" install ; \
        rm -rf ${STCV_FIFTYONE_2_DIR} ; \
        deactivate ; \
    else \
        echo "FiftyOne session 2 not installed!" ; \
    fi

ENV STCV_FIFTYONE_3_DIR="/root/workspace/fiftyone_3"
RUN if [ ${STCV_FIFTYONE_3_BUILD} = "True" ] ; \
    then \
        mkdir -p $STCV_FIFTYONE_3_DIR ; \
        tar -zxf /root/workspace/v$STCV_FIFTYONE_VERSION.tar.gz -C $STCV_FIFTYONE_3_DIR --strip-components=1 ; \
        python -m venv /root/workspace/.envs/fo_3 ; \
        source /root/workspace/.envs/fo_3/bin/activate ; \
        git clone https://github.com/voxel51/fiftyone.git --depth 1 ${STCV_FIFTYONE_3_DIR} ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_3_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_3_PORT}" fix ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_3_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_3_PORT}" build ; \
        /root/workspace/stcv/scripts/f1_setup.bash "${STCV_FIFTYONE_3_DIR}" "${STCV_INSTANCE_ADDRESS}" "${STCV_FIFTYONE_3_PORT}" install ; \
        rm -rf ${STCV_FIFTYONE_3_DIR} ; \
        deactivate ; \
    else \
        echo "FiftyOne session 3 not installed!" ; \
    fi

ENV FIFTYONE_DEFAULT_DATASET_DIR=$STCV_FIFTYONE_DATA_DIR

#################################
# Install LabelStudio, MLFlow and TensorBoard

RUN pip install mlflow tensorboard

RUN git clone https://github.com/HumanSignal/label-studio.git --depth 1

RUN chmod +x /root/workspace/stcv/scripts/ls_setup.bash && \
    /root/workspace/stcv/scripts/ls_setup.bash /root/workspace/label-studio && \
    cd /root/workspace/label-studio && \
    pip install . && \
    rm -rf /root/workspace/label-studio

#################################
# Install s3fs

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git --depth 1 && \
    cd s3fs-fuse && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

#################################
# Configure STCV

ENV STCV_CONFIGS_DIR="/root/workspace/stcv/configs"
ENV STCV_HTML_DOCS_DIR="/root/workspace/stcv/html_docs"

# => VS Code
RUN wget https://raw.githubusercontent.com/coder/code-server/main/install.sh -O /root/workspace/install.sh && \
    chmod +x /root/workspace/install.sh && \
    /root/workspace/install.sh --version ${STCV_CODESERVER_VERSION} && \
    rm -rf /root/.config/code-server/config.yaml && \
    mkdir -p /root/.config/code-server && \
    cp ${STCV_CONFIGS_DIR}/config.yaml /root/.config/code-server/config.yaml && \
    code-server --install-extension ms-python.python --force && \
    code-server --install-extension ms-toolsai.jupyter --force

# => elFinder
ENV ELFINDER_DIR="/root/workspace/elFinder-2.1.62"
RUN wget https://github.com/Studio-42/elFinder/archive/refs/tags/2.1.62.tar.gz && \
    tar -zxf /root/workspace/2.1.62.tar.gz && \
    cp ${STCV_CONFIGS_DIR}/connector.minimal.php ${ELFINDER_DIR}/php/connector.minimal.php && \
    mv ${ELFINDER_DIR} ${STCV_HTML_DOCS_DIR}/finder && \
    rm -rf ${STCV_HTML_DOCS_DIR}/finder/elfinder.html && \
    cp ${STCV_CONFIGS_DIR}/elfinder.html ${STCV_HTML_DOCS_DIR}/finder/elfinder.html

# => eZ
RUN git clone https://github.com/shevabam/ezservermonitor-web.git --depth 1 && \
    cp -R /root/workspace/ezservermonitor-web ${STCV_HTML_DOCS_DIR}/ez && \
    rm -rf ${STCV_HTML_DOCS_DIR}/ez/index.php && \
    rm -rf ${STCV_HTML_DOCS_DIR}/ez/conf/esm.config.json && \
    rm -rf ${STCV_HTML_DOCS_DIR}/ez/web/css/frontend.css && \
    cp ${STCV_CONFIGS_DIR}/index.php ${STCV_HTML_DOCS_DIR}/ez/index.php && \
    cp ${STCV_CONFIGS_DIR}/esm.config.json ${STCV_HTML_DOCS_DIR}/ez/conf/esm.config.json && \
    cp ${STCV_CONFIGS_DIR}/frontend.css ${STCV_HTML_DOCS_DIR}/ez/web/css/frontend.css

# => nginx
RUN rm -f /etc/nginx/nginx.conf
RUN cp ${STCV_CONFIGS_DIR}/nginx.conf /etc/nginx/nginx.conf
RUN chmod -R 777 ${STCV_HTML_DOCS_DIR}

# => php
RUN rm -f /etc/php/8.1/fpm/pool.d/www.conf
RUN cp ${STCV_CONFIGS_DIR}/www.conf /etc/php/8.1/fpm/pool.d/www.conf
RUN rm -f /etc/php/8.1/fpm/php.ini
RUN cp ${STCV_CONFIGS_DIR}/php.ini /etc/php/8.1/fpm/php.ini

#################################
# Start

# => cleaning
RUN pip cache purge && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /root/.cache && \
    rm -rf /var/lib/apt/lists/*

# => start stcv
RUN chmod +x /root/workspace/stcv/scripts/start_stcv.bash
ENTRYPOINT ["/root/workspace/stcv/scripts/start_stcv.bash"]
