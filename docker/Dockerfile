FROM ubuntu

ARG bosh_cli_url="https://github.com/cloudfoundry/bosh-cli/releases/download/v6.2.1/bosh-cli-6.2.1-linux-amd64"
ARG bosh_cli_sha1="476e1f95bc4ba4f51d864c8602774507bfce9f65"

ARG yq_cli_url="https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64"
ARG yq_cli_sha1="7c77a1d71a42ded8335a2a2629e0c77c5d7fb331"

ARG jq_cli_url="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
ARG jq_cli_sha1="056ba5d6bbc617c29d37158ce11fd5a443093949"

RUN apt-get update && apt install -y git wget curl ruby coreutils &&\
    gem install bundler

RUN true \
  && wget -qO /bin/bosh ${bosh_cli_url} \
  && echo "${bosh_cli_sha1}  /bin/bosh" | sha1sum -c \
  && chmod +x /bin/bosh

RUN true \
  && wget -qO /bin/yq ${yq_cli_url} \
  && echo "${yq_cli_sha1}  /bin/yq" | sha1sum -c \
  && chmod +x /bin/yq

RUN true \
  && wget -qO /bin/jq ${jq_cli_url} \
  && echo "${jq_cli_sha1}  /bin/jq" | sha1sum -c \
  && chmod +x /bin/jq