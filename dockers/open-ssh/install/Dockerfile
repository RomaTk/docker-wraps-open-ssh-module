ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

ARG VERSION=""
ARG CONFIGURE_OPTIONS=""
RUN echo "Using version ${VERSION}"
RUN echo "Using configure options ${CONFIGURE_OPTIONS}"

WORKDIR /working-env/open-ssh

COPY ./saved-versions/${VERSION}.tar.gz ./saved-versions/downloaded.tar.gz
COPY ./install.sh ./install.sh

RUN chmod +x ./install.sh
RUN ./install.sh "${CONFIGURE_OPTIONS}"

RUN rm -rf ./install.sh
RUN rm -rf ./saved-versions
