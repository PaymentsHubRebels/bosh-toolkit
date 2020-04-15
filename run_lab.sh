#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LAB_DIR="$THIS_SCRIPT_DIR/lab"

BUCC_URL="https://github.com/starkandwayne/bucc"

#
# There are 4 buckets required that are not being created:
# - binary-releases-repo (where the releases are exported once deployed successfully)
# - blobs (temporary, as I could't find Kafka Manager already built)
# - bosh-releases-semver (where the versions are stored)
# - triggers (use for triggering cleanup job)
#
function run_minio {
  already_existing_container_id="$(docker ps -a | grep minio | head -1 | awk '{print $1}')"

  pushd "$LAB_DIR"
    if [[ "$already_existing_container_id" != "" ]]; then
      docker start "$already_existing_container_id"
    else  
      docker run -d -p 9000:9000 minio/minio server /data
    fi
  popd
}

function bucc_up {
  mkdir -p "$LAB_DIR/bucc"
  if [[ ! -d "$LAB_DIR/bucc" ]]; then
    pushd "$LAB_DIR"
      git clone "$BUCC_URL" "bucc"
    popd 
  fi

  pushd "$LAB_DIR/bucc"
    source .envrc
    git pull
    bucc up --lite --recreate
  popd
}

function update_cloud_config {
  pushd "$LAB_DIR/bucc"
    bosh --non-interactive update-cloud-config src/bosh-deployment/warden/cloud-config.yml
  popd
}

function feed_credhub {

  source "$LAB_DIR/.secrets"

  pushd "$LAB_DIR/bucc"
    source .envrc
    credhub set -n /concourse/main/docker_hub_user -t value -v "$docker_hub_user"
    credhub set -n /concourse/main/docker_hub_password -t password -w "$docker_hub_password"
    credhub set -n /concourse/main/github_owner -t value -v "$github_owner"
    credhub set -n /concourse/main/github_token -t password -w  "$github_token"
    credhub set -n /concourse/main/s3_access_key_id -t value -v "$s3_access_key_id"
    credhub set -n /concourse/main/s3_secret_access_key -t password -w "$s3_secret_access_key"
    credhub set -n /concourse/main/s3_endpoint -t value -v  "$s3_endpoint"
    credhub set -n /concourse/main/bosh_target -t value -v  "$bosh_target"
    credhub set -n /concourse/main/bosh_client -t value -v "$bosh_client"
    credhub set -n /concourse/main/bosh_client_secret -t password -w "$bosh_client_secret"
    credhub set -n /concourse/main/bosh_ca_cert -t certificate --certificate "$bosh_ca_cert"
  popd
}

function set_progenitor {
  pushd "$LAB_DIR/bucc"
    source .envrc
    bucc fly && \
    fly -t bucc set-pipeline -p progenitor -c "$THIS_SCRIPT_DIR/pipelines/progenitor.yml" --non-interactive
    fly -t bucc unpause-pipeline -p progenitor
    for pipeline in $(fly -t bucc pipelines | awk '{print $1}' | grep -v progenitor ); do
      fly -t bucc pause-pipeline -p "$pipeline"
    done
  popd
}

function say_ready {
  echo "Everything is ready! For accessing,"
  pushd "$LAB_DIR/bucc"
    source .envrc
    bucc info
  popd
}

function main {
  run_minio && \
  bucc_up && \
  feed_credhub 
  update_cloud_config && \
  set_progenitor && \
  say_ready
}

mkdir -p "$LAB_DIR"

main
