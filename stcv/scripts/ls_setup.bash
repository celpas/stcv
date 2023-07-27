#!/bin/bash

export LS_DIR=$1

before_str="os.path.join(BASE_DIR, 'static_build')"
after_str="os.path.join(BASE_DIR, 'static')"
sed -i "s+${before_str}+${after_str}+g" ${LS_DIR}/label_studio/core/settings/base.py

before_str="STATICFILES_DIRS"
after_str="#STATICFILES_DIRS"
sed -i "s+${before_str}+${after_str}+g" ${LS_DIR}/label_studio/core/settings/base.py

before_str="STATICFILES_STORAGE"
after_str="#STATICFILES_STORAGE"
sed -i "s+${before_str}+${after_str}+g" ${LS_DIR}/label_studio/core/settings/base.py

before_str="USE_ENFORCE_CSRF_CHECKS = "
after_str="USE_ENFORCE_CSRF_CHECKS = False  #"
sed -i "s+${before_str}+${after_str}+g" ${LS_DIR}/label_studio/core/settings/base.py
