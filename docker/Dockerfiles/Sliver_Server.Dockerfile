# STAGE: production-slim (about 1Gb smaller)
FROM debian:bookworm-slim

# Sliver Environment variables
ENV HOST=ops.b50 OPRTR_FILE="${PWD}/sliver-server/operator.list"

### Install production packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y install make curl \
    git build-essential zlib1g zlib1g-dev wget zip unzip

### Cleanup unneeded packages
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### Add sliver user
RUN groupadd -g 999 sliver \
    && useradd -r -u 999 -g sliver sliver \
    && mkdir -p /home/sliver/ \
    && chown -R sliver:sliver /home/sliver

### Build sliver:
RUN mkdir -p /go/src/github.com/bishopfox
WORKDIR /go/src/github.com/bishopfox
RUN git clone https://github.com/BishopFox/sliver.git && \
cd sliver && \
chmod +x ./go-assets.sh && \
./go-assets.sh
RUN make clean-all
RUN make 
RUN cp -vv sliver-server /opt/sliver-server 

### Unpack Sliver:
USER sliver
RUN /opt/sliver-server unpack --force 

# Create user profiles from sliver_users file
COPY $OPRTR_FILE ${PWD}/operator.list
# Iterate through operators list and add them to sliver-server
RUN FILENAME=${PWD}/operator.list
RUN if [[ -f "$FILENAME" ]]; then mapfile -t operators < "$FILENAME"; \
for handle in "${operators[@]}"; \
do ./sliver_server  operator --name $handle --lhost $HOST --save $handle.cfg; \
done; \
fi

WORKDIR /home/sliver/
VOLUME [ "/home/sliver/.sliver" ]
ENTRYPOINT [ "/opt/sliver-server" ]

