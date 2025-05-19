FROM golang:latest AS builder
WORKDIR /app

RUN  apt-get update && apt-get install git curl unzip -y && \
     LATEST_TAG=$(curl -s https://api.github.com/repos/EasyTier/EasyTier/tags | jq -r '.[0].name') && \
     wget -O /app/easytier.zip https://github.com/EasyTier/EasyTier/releases/download/$LATEST_TAG/easytier-linux-x86_64-$LATEST_TAG.zip && \
     cd /app/ && \
     unzip easytier.zip && \
     mv easytier-linux-x86_64 easytier

FROM alpine:latest

ENV COMMAND="" \
    PATH="/command:${PATH}" \
    BASE_PATH="/etc/s6-overlay/s6-rc.d"


ARG S6_OVERLAY_VERSION="3.2.0.2"

COPY --chmod=755 ./rootfs /
COPY --from=builder /app/easytier ${BASE_PATH}/easytier

RUN wget -O /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxf /tmp/s6-overlay-noarch.tar.xz \
    && rm -f /tmp/s6-overlay-noarch.tar.xz \
    && wget -O /tmp/s6-overlay-x86_64.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz \
    && tar -C / -Jxf /tmp/s6-overlay-x86_64.tar.xz \
    && rm -f /tmp/s6-overlay-x86_64.tar.xz \
    &&  rm -rf /root/*
    


HEALTHCHECK --interval=10s --timeout=5s CMD /healthcheck.sh

ENTRYPOINT ["/init"]