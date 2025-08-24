FROM ubuntu:24.04

WORKDIR /tmp

RUN apt update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata 
RUN apt-get install -y gnupg software-properties-common wget && \
    wget -O- https://apt.releases.hashicorp.com/gpg |  \
        gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > \
        /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt update && \
    apt-get install terraform -y 

RUN apt-get install -y less git jq yq wget curl vim fontconfig

RUN apt-get install unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

RUN mkdir -p /usr/share/fonts/truetype/liberation && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/LiberationMono.zip && unzip -d /usr/share/fonts/truetype/liberation LiberationMono.zip && fc-cache -f

RUN apt-get install -y sudo && \
    echo "%sudo   ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

RUN echo '[core]\n    sshCommand = ssh -i ${SSH_KEY}\n[user]\n   name = ${GITNAME}\n   email = ${GITEMAIL}\n' > .gitconfig

RUN mkdir .config
COPY starship.toml .config 
RUN curl -sS https://starship.rs/install.sh > /tmp/install.sh && sudo sh /tmp/install.sh --yes && echo 'eval "$(starship init bash)"' > .bashrc
RUN echo "git clone git@github.com:lago-morph/iac-k8s" > clone.sh && chmod a+x clone.sh
