ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

WORKDIR /working-env/open-ssh/sshd/basic

COPY  ./sshd-actions.lock ./sshd-actions.lock
COPY ./start.sh ./start.sh
COPY ./stop.sh ./stop.sh