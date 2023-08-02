#!/bin/bash

STCV_PIP_CONF_PATH=$1

rm -rf ~/.config/pip/pip.conf

cp ${STCV_PIP_CONF_PATH} ~/.config/pip/pip.conf
