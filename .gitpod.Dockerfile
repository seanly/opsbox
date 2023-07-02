FROM gitpod/workspace-full
# More information: https://www.gitpod.io/docs/config-docker/

RUN brew install yq tig nvim

ENV DOCKER_BUILDKIT=1

ENV BUILDX_VERSION=0.10.4
RUN mkdir -p /home/gitpod/.docker/cli-plugins
RUN wget https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64 -O /home/gitpod/.docker/cli-plugins/docker-buildx
RUN chmod a+x /home/gitpod/.docker/cli-plugins/docker-buildx
