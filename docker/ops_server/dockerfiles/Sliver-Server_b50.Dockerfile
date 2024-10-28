# STAGE: production-slim (about 1Gb smaller)
FROM kalilinux/kali-rolling

### Install production packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y install \
    git \
    golang \
    curl \
    zip \
    make

WORKDIR /root

RUN git clone https://github.com/BishopFox/sliver && \
cd sliver && \
chmod +x ./go-assets.sh && \
./go-assets.sh

# Some clean up is nice
RUN rm -rf /tmp/tmp.tch6xLauE8 

WORKDIR /root/sliver

# Build the sliver binaries
RUN make

ENTRYPOINT [ "./sliver-server" ]

