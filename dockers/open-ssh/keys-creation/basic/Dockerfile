ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

VOLUME [ "/working-env/open-ssh/keys-creation/basic/keys" ]

WORKDIR /working-env/open-ssh/keys-creation/basic/

COPY ./config.cfg ./config.cfg
COPY ./remove.sh ./remove.sh
COPY ./create.sh ./create.sh