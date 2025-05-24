FROM golang:latest AS builder
WORKDIR /app

RUN  apt-get update && apt-get install git jq curl unzip -y
#RUN  LATEST_TAG=$(curl -s https://api.github.com/repos/EasyTier/EasyTier/tags | jq -r '.[0].name') && \
#     wget -O /app/easytier.zip https://github.com/EasyTier/EasyTier/releases/download/$LATEST_TAG/easytier-linux-x86_64-$LATEST_TAG.zip

RUN mkdir -p /app/easytier && wget -O /app/easytier/easytier.zip https://github.com/chenxudong2020/easytier_docker/raw/refs/heads/main/easytier-linux-x86_64.zip    

RUN  cd /app/easytier && \
     unzip easytier.zip && rm -rf easytier.zip


ENV S6_OVERLAY_VERSION="3.2.0.2"
RUN cd /tmp && \
    curl -L -o /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz && \     
    curl -L -o /tmp/s6-overlay-x86_64.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz     

FROM busybox:stable-glibc

ENV COMMAND="" \
    PATH="/command:${PATH}" \
    BASE_PATH="/etc/s6-overlay/s6-rc.d"

COPY --chmod=755 ./rootfs /
COPY --from=builder /app/easytier ${BASE_PATH}/easytier
COPY --from=builder /tmp/s6-overlay-noarch.tar.xz /tmp
COPY --from=builder /tmp/s6-overlay-x86_64.tar.xz /tmp

RUN tar -C / -Jxf /tmp/s6-overlay-noarch.tar.xz && \
    rm -f /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxf /tmp/s6-overlay-x86_64.tar.xz && \
    rm -f /tmp/s6-overlay-x86_64.tar.xz && \
    ln -sf /run /var/run && \
    rm -rf /root/*
    


HEALTHCHECK --interval=10s --timeout=5s CMD /healthcheck.sh

ENTRYPOINT ["/init"]