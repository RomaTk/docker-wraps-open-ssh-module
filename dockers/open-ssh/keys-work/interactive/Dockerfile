ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

WORKDIR /working-env/open-ssh/keys-work/interactive/

COPY ./config.cfg ./config.cfg
COPY ./remove.sh ./remove.sh
COPY ./create.sh ./create.sh
COPY ./get.sh ./get.sh
COPY ./main.sh ./main.sh