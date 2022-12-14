#!/bin/bash

# Parameters
export STCV_VERSION="v0.8.7"
export REGION="eu-central-1"
export BUCKET_NAME="<<BUCKET_NAME>>"
export BUCKET_MNT_DIR="/tmp/bucket"
export MONGODB_DATA_DIR="/home/ec2-user/SageMaker/.mongodb_data"

# Disable exit if there is an error
set +e

# Update packages
sudo yum update -y

echo "=> Setting up persisted conda environments"
PERSISTED_CONDA_DIR="${PERSISTED_CONDA_DIR:-/home/ec2-user/SageMaker/.persisted_conda}"
mkdir -p ${PERSISTED_CONDA_DIR} && chown ec2-user:ec2-user ${PERSISTED_CONDA_DIR}
envdirs_clean=$(grep "envs_dirs:" /home/ec2-user/.condarc || echo "clean")
if [[ "${envdirs_clean}" != "clean" ]]; then
    echo "envs_dirs config already exists in /home/ec2-user/.condarc. No idea what to do. Exiting!"
    exit 1
fi
echo "Adding ${PERSISTED_CONDA_DIR} to list of conda env locations"
cat << EOF >> /home/ec2-user/.condarc
envs_dirs:
  - ${PERSISTED_CONDA_DIR}
  - /home/ec2-user/anaconda3/envs
EOF

echo "=> Installing Goofys"
sudo amazon-linux-extras install epel -y
sudo yum install s3fs-fuse -y
sudo yum install golang -y
sudo -u ec2-user wget https://github.com/kahing/goofys/releases/download/v0.24.0/goofys -O /home/ec2-user/goofys
sudo -u ec2-user chmod a+x /home/ec2-user/goofys

echo "=> Mounting S3 bucket"
sudo -u ec2-user mkdir -p $BUCKET_MNT_DIR
sudo -u ec2-user chmod a+w $BUCKET_MNT_DIR
sudo -u ec2-user /home/ec2-user/goofys --uid 1000 --gid 1000 --region $REGION $BUCKET_NAME $BUCKET_MNT_DIR
#s3fs $BUCKET_NAME $BUCKET_MNT_DIR -o umask=0007,uid=1000,gid=1000,endpoint=$REGION,iam_role=auto

echo "=> Installing NodeJS"
sudo yum remove libuv -y
sudo wget https://download-ib01.fedoraproject.org/pub/epel/8/Modular/x86_64/Packages/l/libuv-1.43.0-2.module_el8+13804+34326f90.x86_64.rpm
sudo rpm -i libuv-1.43.0-2.module_el8+13804+34326f90.x86_64.rpm
sudo yum install nodejs npm --enablerepo=epel -y
sudo npm -g install yarn

echo "=> Installing MongoDB v5.x"
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-server-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-database-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-database-tools-extra-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-shell-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-mongos-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-org-tools-5.0.9-1.amzn2.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-mongosh-1.5.4.x86_64.rpm
sudo wget https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/RPMS/mongodb-database-tools-100.5.4.x86_64.rpm
sudo yum localinstall mon*.rpm -y

# To include bugfix PR328: https://github.com/jupyterhub/jupyter-server-proxy/pull/328
echo "=> Updating nbserverproxy"
sudo -u ec2-user /home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/pip uninstall -y nbserverproxy jupyter-server-proxy
sudo -u ec2-user /home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/pip install jupyter-server-proxy==3.2.2
sudo systemctl restart jupyter-server

echo "=> Starting MongoDB as a daemon"
sudo mkdir -p $MONGODB_DATA_DIR
sudo mongod --fork --dbpath $MONGODB_DATA_DIR --bind_ip_all --logpath /var/log/mongodb/mongod.log

echo "=> Cloning STCV repository"
sudo -u ec2-user git clone -b $STCV_VERSION \
                 https://github.com/celpas/stcv.git \
                 /home/ec2-user/cv-utils

echo "=> Installing PHP"
sudo amazon-linux-extras install php7.4 -y
sudo yum install php-gd -y
sudo chown ec2-user:ec2-user /var/log/php-fpm/ -R
sudo chown ec2-user:ec2-user /run/php-fpm/ -R
sudo chown ec2-user:ec2-user /etc/php-fpm.d/ -R
sudo -u ec2-user cp /home/ec2-user/cv-utils/php/www.conf /etc/php-fpm.d/www.conf
sudo rm -f /etc/php.ini
sudo cp /home/ec2-user/cv-utils/php/php.ini /etc/php.ini
sudo chown ec2-user:ec2-user /etc/php.ini
sudo -u ec2-user mkdir /home/ec2-user/.finder_trash
sudo -u ec2-user mkdir /home/ec2-user/.thumb
sudo -u ec2-user /usr/sbin/php-fpm

echo "=> Installing nginx"
sudo yum install nginx -y
sudo rm -f /etc/nginx/nginx.conf
sudo cp /home/ec2-user/cv-utils/nginx/nginx.conf /etc/nginx/nginx.conf 
sudo chown ec2-user:ec2-user /usr/share/nginx/ -R
sudo -u ec2-user cp -ar /home/ec2-user/cv-utils/nginx/www/. /usr/share/nginx/html/
sudo chown ec2-user:ec2-user /var/lib/nginx/ -R
sudo systemctl restart nginx

echo "=> Installing code-server"
sudo -u ec2-user wget https://raw.githubusercontent.com/coder/code-server/main/install.sh -O /home/ec2-user/install.sh
sudo -u ec2-user chmod a+w /home/ec2-user/install.sh
HOME=/home/ec2-user sudo -u ec2-user bash /home/ec2-user/install.sh
sudo systemctl enable --now code-server@ec2-user
sudo rm -f /home/ec2-user/.config/code-server/config.yaml
sudo mkdir -p /home/ec2-user/.config/code-server
sudo -u ec2-user cat > /home/ec2-user/.config/code-server/config.yaml << EOF
bind-addr: 127.0.0.1:8080
auth: none
password: 9bdf71aa2d84a20e70e73b0e
cert: false
EOF
sudo -u ec2-user code-server --install-extension ms-python.python --force
sudo -u ec2-user code-server --install-extension ms-toolsai.jupyter --force
sudo systemctl start code-server@ec2-user

echo "=> Removing environment bash prefix"
sudo -u ec2-user -i << 'EOF'
conda activate JupyterSystemEnv
conda config --set env_prompt '($(basename {default_env})) '
conda deactivate
EOF
