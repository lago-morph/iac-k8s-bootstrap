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

RUN apt-get install -y less git jq yq wget curl vim fontconfig make bind9-dnsutils

RUN apt-get install unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

RUN mkdir -p /usr/share/fonts/truetype/liberation && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/LiberationMono.zip && unzip -d /usr/share/fonts/truetype/liberation LiberationMono.zip && fc-cache -f

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN apt-get install -y sudo && \
    echo "%sudo   ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu

RUN ARCH=amd64 && PLATFORM=$(uname -s)_$ARCH && \
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" && \
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz && \
    sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

USER ubuntu
WORKDIR /home/ubuntu

RUN echo '[core]\n    sshCommand = ssh -i ${SSH_KEY}\n[user]\n   name = ${GITNAME}\n   email = ${GITEMAIL}\n' > .gitconfig

RUN mkdir .config
COPY starship.toml .config 
RUN curl -sS https://starship.rs/install.sh > /tmp/install.sh && \
    sudo sh /tmp/install.sh --yes && \
    echo 'eval "$(starship init bash)"' > .bashrc && \
    echo "git clone git@github.com:lago-morph/iac-k8s-bootstrap" > clone.sh && \
    echo "git clone git@github.com:lago-morph/iac-k8s-admin" >> clone.sh && \
    echo "git clone git@github.com:lago-morph/iac-k8s-team-alpha" >> clone.sh && \
    chmod a+x clone.sh

RUN sudo apt-get install pipx python3-venv -y && \
    pipx install jinja2-cli && \
    pipx ensurepath

RUN echo 'export PATH="$PATH:/home/ubuntu/.local/bin"' >> .bashrc && \
    echo '. /usr/share/bash-completion/bash_completion' >> .bashrc && \
    echo 'source <(kubectl completion bash)' >> .bashrc
 
RUN sudo apt-get install --yes groff bash-completion

RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
    rm argocd-linux-amd64
