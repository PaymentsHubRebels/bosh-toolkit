FROM ubuntu

ARG bosh_cli_url="https://github.com/cloudfoundry/bosh-cli/releases/download/v6.2.1/bosh-cli-6.2.1-linux-amd64"
ARG bosh_cli_sha1="476e1f95bc4ba4f51d864c8602774507bfce9f65"

RUN apt-get update && apt install -y git wget curl ruby &&\
    gem install bundler

RUN true \
  && wget -qO /bin/bosh ${bosh_cli_url} \
  && echo "${bosh_cli_sha1}  /bin/bosh" | sha1sum -c \
  && chmod +x /bin/bosh