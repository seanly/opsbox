#!/bin/bash

set -ex

BUILDER_NAME=opsbox-builder
if ! $(docker buildx ls |grep -q ${BUILDER_NAME}); then
  docker buildx create --name ${BUILDER_NAME}
fi

docker buildx use ${BUILDER_NAME}
docker buildx inspect --bootstrap

if [ $# -eq 1 ]; then
  _svc_name=$1
fi

function docker_buildx_svc() {
  _svc=$1
  _image=$(docker-compose config |yq ".services|to_entries|.[]| select(.key==\"${_svc}\")|.value.image")
  _context=$(docker-compose config |yq ".services|to_entries|.[]| select(.key==\"${_svc}\")|.value.build.context")
  docker buildx build --platform linux/amd64,linux/arm64 -t ${_image} ${_context} --push
}

if [ -n "$_svc_name" ]; then
  docker_buildx_svc ${_svc_name}
  exit 0
else
  for svc in $(docker-compose config |yq '.services|to_entries|.[]|.key')
  do
    docker_buildx_svc ${svc}
  done
fi