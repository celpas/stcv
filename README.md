# SageMaker Toolkit for Computer Vision

![alt splash](_data/splash.jpeg)

## Features

- Persistent conda environments
- S3 bucket mounting
- Upgrade of jupyter-server-proxy
- Some useful tools: VS Code, Label Studio, FiftyOne, TensorBoard and elFinder


## Instructions

1. Set [lifecycle configuration](/lifecycle_sm.bash) to your SageMaker notebook instance (remember to set your bucket name).
2. Visit ```https://<<INSTANCE_NAME>>.notebook.<<REGION>>.sagemaker.aws/proxy/1199/```.

Note that VSCode starts automatically while for other tools the relative notebook should be used.
