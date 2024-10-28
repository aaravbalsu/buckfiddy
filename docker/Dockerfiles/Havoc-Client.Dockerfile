# ------------------------------------------------------------------------------
# Dockerfile for Havoc-C2 Teamserver Client
#
# Commands for usage:
#
# 	Create Data storage for persistence
#       'docker volume create havoc-c2-client-volume'
#	Build image file:
#		'docker build -t havoc-client -f Client-Dockerfile .'
#
#	*Let your (Linux)host accept the connection:*
#		`xhost +"local:docker@"`
#	Run Havoc Teamserver client from a container:
#		`sudo docker run -t -d --net=host -e DISPLAY=$DISPLAY  havoc-client`
#	Enter the Container and launch the teamserver client:
#		`sudo docker exec -it <container_name> bash`
#	Once inside the container, issue the following command to launch the teamserver client:
#		`cd /go/Build/Bin/ && ./Havoc`
#	You should now see the Havoc teamserver client running in a window!

# Extras
# 	Create Data storage for persistence
#       'docker volume create havoc-c2-client-volume'
#
# 	Enter Container:
#		'docker run exec -it <containerID> bash'
# ------------------------------------------------------------------------------
    FROM ubuntu:20.04
    # Set ENVs
    ENV PATH=/root/.local/bin:$PATH
    ENV TZ=Europe/Kiev
    ENV USER=root
    RUN cat /etc/os-release
    
    # Take care of TZ dep
    RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
    #
    RUN echo > /etc/apt/sources.list\
        && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list \
        && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list \
        && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list \
        && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list
    
    # Manual cmake install
    RUN apt-get update && apt-get -y install wget
    #
    # Install dependencies                                            
    RUN apt-get update && apt-get install -y \
        git \
        build-essential \
        apt-utils \
        cmake \
        libfontconfig1 \
        libglu1-mesa-dev \
        libgtest-dev \
        libspdlog-dev \
        libboost-all-dev \
        mesa-common-dev \  
        mingw-w64 \
        nasm \
        sudo \
        python3 \
        python3-all-dev \
        python3-pip
    #
    # qt5-default is deprecated on Ubuntu 22.04...
    RUN apt-get update && apt-get install -y \
        qtbase5-dev \
        qtchooser \
        qt5-qmake \
        qtbase5-dev-tools \
        libqt5websockets5 \
        libqt5websockets5-dev \
        qtdeclarative5-dev
    
    # Build cmake as the repo version is out-of-date...
    RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-Linux-x86_64.sh -O cmake.sh
    RUN sh cmake.sh --prefix=/usr/local/ --exclude-subdir
    
    # add python source 
    RUN apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa
    # Install Python3.10
    RUN apt-get install -y python3.10-dev libpython3.10 libpython3.10-dev python3.10 build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
    # Install go 1.20
    RUN rm -rf /usr/local/go  && wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz -O /usr/local/src/go1.20.tar.gz && tar -C /usr/local -xzf /usr/local/src/go1.20.tar.gz && ln -s /usr/local/go/bin/go /usr/bin/go
    # Pull the repo from Github
    RUN git clone -b dev https://github.com/HavocFramework/Havoc.git --depth=1
    #
    # Build the cloned repos copy of the Teamserver-Client
    RUN cd Havoc/client/ && make
    #
    # Add VNC Support
    RUN apt-get update && apt-get install -y x11vnc xvfb
    #RUN echo "exec /Build/Bin/Havoc" > ~/.xinitrc && chmod +x ~/.xinitrc
    #CMD ["x11vnc", "-create", "-forever"]
    #CMD /Havoc/client/Havoc
    # Cleanup
    RUN rm -rf /var/lib/apt/lists/*

    EXPOSE 40056 443