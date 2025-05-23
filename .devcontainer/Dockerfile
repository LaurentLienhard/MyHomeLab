FROM python:3.10-buster

RUN python3 -m pip install ansible  
# If you want to install ansible-core, just run the same command but with "ansible-core" instead of "ansible"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends && \
    apt-get install -y sudo git make vim direnv virtualenv\
    sshpass

RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

WORKDIR /workspaces/MyHomeLab/ansible
