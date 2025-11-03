ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

WORKDIR /working-env/open-ssh/public-keys-add

COPY ./keys ./keys
COPY ./add-key.sh ./add-key.sh
COPY ./create-authorized-keys-file.sh ./create-authorized-keys-file.sh
COPY ./create-ssh-folder.sh ./create-ssh-folder.sh
COPY ./create-user.sh ./create-user.sh
COPY ./go-threw-config.sh ./go-threw-config.sh

RUN chmod +x ./go-threw-config.sh
RUN ./go-threw-config.sh

WORKDIR /working-env/open-ssh
RUN rm -rf /working-env/open-ssh/public-keys-add