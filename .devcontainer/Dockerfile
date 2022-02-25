FROM debian:bullseye-slim

RUN apt update -y && apt upgrade -y

#install dependencies
RUN apt-get install -y gnupg software-properties-common curl unzip git wget

#installing helm repo
RUN curl -fsSL https://baltocdn.com/helm/signing.asc | apt-key add -
RUN apt-get install apt-transport-https --yes
RUN apt-add-repository "deb https://baltocdn.com/helm/stable/debian/ all main"

#installing terraform repo
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

RUN apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#installing terraform helm
RUN apt-get update -y  &&  apt-get install terraform helm -y

# installing aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

RUN unzip awscliv2.zip

RUN ./aws/install

RUN curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/$(dpkg --print-architecture)/kubectl

#installing k8s
RUN chmod +x ./kubectl

RUN mkdir -p $HOME/bin && cp ./kubectl /usr/bin/kubectl && export PATH=$PATH:$HOME/bin

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

RUN  mv /tmp/eksctl /usr/local/bin/eksctl

RUN eksctl version

#installing zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -p git -p terraform \
    -p ssh-agent \
    -p kubectl \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/djui/alias-tips

CMD ["sleep", "infinity"]