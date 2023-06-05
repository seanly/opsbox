# opsbox

## usage

1. install crane 

```bash
#!/bin/bash
CRANE_URL=https://github.com/google/go-containerregistry/releases/download/v0.15.2/go-containerregistry_Linux_x86_64.tar.gz
curl -sL $CRANE_URL > go-containerregistry.tar.gz
tar -zxvf go-containerregistry.tar.gz -C /usr/bin/ crane
```

2. install docker

```bash
mkdir -p /data/docker
cd /data/docker/

# install/docker/usr/bin/docker-compose
crane blob seanly/toolset:docker@sha256:00cdf3639c091d6c154f9b9d5074ca5abbf5bcdcca6ea1e9a2f08fce92cefd1b | tar -xz
mv install/docker/usr/bin/docker-compose /usr/bin/
# install/docker & package/docker.tar.gz
crane blob seanly/toolset:docker@sha256:2616ef4691baaa7c4f334153ca8439373d2b29d85d11e3b0a7f1f61d66b5c9c2 | tar -xz
# 通过 package/docker.tar.gz
cd install/package
tar -xzf docker.tar.gz
bash scripts/install.sh
```
3. run toolset

Copy the `docker-compose.yml` from this repository to the environment, and start it with `docker-compose up -d`. Access the environment with `docker-compose exec toolset bash`.
