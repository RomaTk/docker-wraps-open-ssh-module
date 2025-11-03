ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

WORKDIR /working-env/open-ssh

COPY ./create-sshd-user.sh ./create-sshd-user.sh
RUN chmod +x ./create-sshd-user.sh

RUN ./create-sshd-user.sh

RUN rm -rf ./create-sshd-user.sh