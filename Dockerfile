### runtime stage
FROM    golang:1.14.4-buster AS runtime
MAINTAINER  kawawa.y <kawawa.y@gmail.com>

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt-get update -y
RUN     apt-get install -y \
		apt-transport-https
#        gawk \
#        wget \
#        git-core \
#        diffstat \
#        unzip \
#        texinfo \
#        chrpath \
#        cpio \
#        python3 \
#        python3-pip \
#        python3-pexpect \
#        xz-utils \
#        debianutils \
#        locales \
#        apt-utils \
#        sudo \
#        curl

# User management
# 1000 is reserved by vagrant
RUN	groupadd -g 1001 build && \
	useradd -u 1001 -g 1001 -ms /bin/bash build && \
	usermod -a -G sudo build && \
	usermod -a -G users build


### build stage
FROM    runtime AS build

ADD	compile /usr/local/bin

# Clean up APT when done. 
RUN     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR	/home/build
USER	build


### dev stage
FROM    runtime AS dev

RUN	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
	install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d && \
	echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list

RUN	apt-get update -y && \
	apt-get install -y \
		openssh-server \
		vim \
		tmux \
		dnsutils \
		wireshark \
		code

# Clean up APT when done. 
RUN     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR	/home/build
USER	build
