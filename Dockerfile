FROM debian:jessie-slim
LABEL maintainer="Michael Lynch <michael@mtlynch.io>"

ARG SIA_VERSION="1.0.1"
ENV SIA_VERSION $SIA_VERSION
ARG SIA_PACKAGE="Sia-v${SIA_VERSION}-linux-amd64"
ENV SIA_PACKAGE $SIA_PACKAGE
ARG SIA_ZIP="${SIA_PACKAGE}.zip"
ENV SIA_ZIP $SIA_ZIP
ARG SIA_RELEASE="https://github.com/NebulousLabs/Sia/releases/download/v${SIA_VERSION}/${SIA_ZIP}"
ENV SIA_RELEASE $SIA_RELEASE
ARG SIA_DIR="/sia"
ENV SIA_DIR $SIA_DIR
ENV SIA_DATA_DIR="/sia-data"
ENV SIA_MODULES gctwhr

RUN apt-get update && apt-get install -y \
  socat \
  wget \
  unzip

RUN wget "$SIA_RELEASE" && \
      mkdir "$SIA_DIR" && \
      unzip -j "$SIA_ZIP" "${SIA_PACKAGE}/siac" -d "$SIA_DIR" && \
      unzip -j "$SIA_ZIP" "${SIA_PACKAGE}/siad" -d "$SIA_DIR"

# Clean up.
RUN apt-get remove -y wget unzip && \
    rm "$SIA_ZIP" && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc && \
    rm -Rf /usr/share/man && \
    apt-get autoremove -y && \
    apt-get clean

EXPOSE 9980 9981 9982

WORKDIR "$SIA_DIR"
ENTRYPOINT socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 & \
  ./siad \
    --modules "$SIA_MODULES" \
    --sia-directory "$SIA_DATA_DIR" \
    --api-addr "localhost:8000"
