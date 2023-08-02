#!/bin/bash

STCV_BASHRC_PATH=$1

rm -rf ~/.bashrc

cp ${STCV_BASHRC_PATH} ~/.bashrc
