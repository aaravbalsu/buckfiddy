###
#
# Modified Intruder guide for C2 docker deployments
# https://www.redteam.cafe/red-team/walking-with-docker/self-hosting-havoc-c2-or-any-other-c2-in-docker#installing-havoc-c2-client
#
###
# Using the latest debian OS
ARG GO_VERSION="1.19.1"
FROM golang:${GO_VERSION}
#
ENV PATH=/root/.local/bin:$PATH
ENV USER=root
#
RUN apt update \
        && apt -y install \
        git \
        alien \
        debhelper \
        devscripts \
        golang-go \
        nasm \
        mingw-w64 \
        dh-golang \
        dh-make \
        fakeroot \
        pkg-config \
        python3-all-dev \
        python3-pip \
        rpm \
        sudo \
        libcap2-bin \
        upx-ucl \
        && pip install --upgrade jsonschema

# Pull the repo from Github
RUN git clone https://github.com/HavocFramework/Havoc

# IMPORTANT: Must run autoremove to prevent conflicts in pre-existing go 
# related paths. Makes it difficult for go to find the go.mod file. 
#RUN apt autoremove -y

# Installing Mods
RUN cd Havoc/teamserver && go mod download golang.org/x/sys && go mod download github.com/ugorji/go

#Building Teamserver 
RUN cd ..
RUN ls -lah
RUN make ts-build
EXPOSE 40056 443

#Running Havoc
ENTRYPOINT ["./havoc", "server", "--profile", "/Havoc/profiles/havoc.yaotl", "-v", "--debug"]
