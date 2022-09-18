# SageMaker Toolkit for Computer Vision

![alt splash](_data/splash.jpeg)


## Features

- Persistent conda environments
- S3 bucket mounting
- Upgrade of jupyter-server-proxy
- Some useful tools: VS Code, Label Studio, FiftyOne, TensorBoard, elFinder and eZ Server Monitor


## Instructions

1. Set [lifecycle configuration](/lifecycle_sm.bash) to your SageMaker notebook instance (remember to set your bucket name).
2. Visit ```https://<<INSTANCE_NAME>>.notebook.<<REGION>>.sagemaker.aws/proxy/1199/```.
3. Done!

Note that VSCode starts automatically while for other tools the relative notebook should be used.


## Requirements

A notebook instance with Amazon Linux 2.


## How to update a lifecycle using CLI?

```bash
LIFECYCLE_CONFIG_NAME="<<LIFECYCLE_NAME>>"
aws sagemaker update-notebook-instance-lifecycle-config \
    --notebook-instance-lifecycle-config-name "$LIFECYCLE_CONFIG_NAME" \
    --on-start Content="$((cat lifecycle_sm.bash) | base64 -w 0)"
```