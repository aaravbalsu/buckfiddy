# STAGE: production-slim (about 1Gb smaller)
FROM debian:bookworm-slim as production-slim

### Install production packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade

### Cleanup unneeded packages
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### Add sliver user
RUN groupadd -g 999 sliver \
    && useradd -r -u 999 -g sliver sliver \
    && mkdir -p /home/sliver/ \
    && chown -R sliver:sliver /home/sliver

### Copy compiled binary
COPY --from=base /opt/sliver-server  /opt/sliver-server

### Unpack Sliver:
USER sliver
RUN /opt/sliver-server unpack --force 

WORKDIR /home/sliver/
VOLUME [ "/home/sliver/.sliver" ]
ENTRYPOINT [ "/opt/sliver-server" ]