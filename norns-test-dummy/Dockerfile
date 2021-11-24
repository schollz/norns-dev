FROM wwinder/norns-dev:latest

# Tag can be a commit hashes or branch name.
ENV \
    MAIDEN_TAG=1daf030c2c81b8d8fadadda22e1de5d1ec1381f1 \
    MAIDEN_REPO=https://github.com/monome/maiden.git \
    NORNS_TAG=740cbeed0fd4890f420d9fbc8691ccefbe73b5e4 \
    NORNS_REPO=https://github.com/monome/norns.git

RUN groupadd we -g 1000 && \
    useradd we -g 1000 -u 1000 -m -s /bin/bash

RUN apt-get update -q && \
    apt-get install -qy --no-install-recommends \
            python3-pip \
            python3-setuptools \
            python3-wheel \
            tmux \
            vim \
            libboost-dev \
            # oled display
            libsdl2-dev \
            x11vnc \
            xvfb \
            # display server
            x11-apps \
            icecast2 \
            darkice \
            imagemagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install tmuxp==1.4.0

# darkice installs libjack-jackd2-0, we need to remove it
RUN dpkg --remove --force-depends libjack-jackd2-0

USER we
WORKDIR /home/we

# MAIDEN - build release then install it.
RUN git clone $MAIDEN_REPO maiden_src && \
    cd maiden_src && \
    git checkout $MAIDEN_TAG && \
    make release-local && \
    tar -xvf dist/maiden.tgz -C /home/we && \
    /home/we/maiden/project-setup.sh

# MATRON - build with desktop mode enabled.
RUN git clone $NORNS_REPO && \
    cd /home/we/norns && \
    git checkout $NORNS_TAG && \
    git submodule update --init --recursive && \
    ./waf configure --desktop && \
    ./waf

# Supercollider - Install extensions.
RUN mkdir -p /home/we/.local/share/SuperCollider/Extensions/norns && \
    cd /home/we/norns/sc && \
    ./install.sh && \
    echo | sclang

# DUST - Configure maiden data directory.
RUN /home/we/maiden/project-setup.sh


COPY ["jackdrc", "/etc/jackdrc"]
COPY ["matronrc.lua", "/home/we/norns/matronrc.lua"]
COPY ["norns.yaml", "/home/we/.tmuxp/norns.yaml"]
COPY ["tmux.conf", "/home/we/.tmux.conf"]
COPY ["oled-server.go", "/home/we/oled-server.go"]
COPY ["oled-server2.go", "/home/we/oled-server2.go"]
COPY ["go.mod", "/home/we/go.mod"]
COPY ["go.sum", "/home/we/go.sum"]
COPY ["static", "/home/we/static"]
COPY repl-endpoints.json /home/we/maiden/app/build/repl-endpoints.json
COPY icecast.xml /etc/icecast2/icecast.xml
COPY darkice.cfg /etc/darkice.cfg


CMD tmuxp load norns
