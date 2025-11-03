ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

VOLUME [ "/working-env/open-ssh/connect-via-ssh/basic/keys" ]

WORKDIR /working-env/open-ssh/connect-via-ssh/basic

COPY ./connect.sh ./connect.sh

COPY ./ssh-agent-expect.sh ./ssh-agent-expect.sh
RUN chmod +x ./ssh-agent-expect.sh