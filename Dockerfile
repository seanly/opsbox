FROM alpine:3.17.2

RUN apk update && \
    apk add --update --no-cache python3 py3-pip curl wget jq bash neovim \ 
        ctags openssh-server openssh-client ansible fzf git rsync openssl openssl-dev \
        certbot ncurses sshpass busybox-extras bzip2 && \
    pip install jinja2-cli[yaml] && \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Set up K3s: copy the necessary binaries from the K3s image.
COPY --from=rancher/k3s:v1.22.6-k3s1 \
        /bin/blkid \
        /bin/charon \
        /bin/cni \
        /bin/conntrack \
        /bin/containerd \
        /bin/containerd-shim-runc-v2 \
        /bin/ethtool \
        /bin/ip \
        /bin/ipset \
        /bin/k3s \
        /bin/losetup \
        /bin/pigz \
        /bin/runc \
        /bin/swanctl \
        /bin/which \
        /bin/aux/xtables-legacy-multi \
    /usr/bin/

RUN ln -s /usr/bin/cni /usr/bin/bridge && \
    ln -s /usr/bin/cni /usr/bin/flannel && \
    ln -s /usr/bin/cni /usr/bin/host-local && \
    ln -s /usr/bin/cni /usr/bin/loopback && \
    ln -s /usr/bin/cni /usr/bin/portmap && \
    ln -s /usr/bin/k3s /usr/bin/crictl && \
    ln -s /usr/bin/k3s /usr/bin/ctr && \
    ln -s /usr/bin/k3s /usr/bin/k3s-agent && \
    ln -s /usr/bin/k3s /usr/bin/k3s-etcd-snapshot && \
    ln -s /usr/bin/k3s /usr/bin/k3s-server && \
    ln -s /usr/bin/k3s /usr/bin/kubectl && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-save && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-restore && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-translate && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-save && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-restore && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-translate
    
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY --from=minio/mc /usr/bin/mc /usr/bin/mc
COPY --from=seanly/toolset:restic /usr/bin/restic /usr/bin/restic
COPY --from=seanly/toolset:ossutil /usr/bin/ossutil* /usr/bin/ossutil
COPY --from=seanly/toolset:rke /usr/bin/rke /usr/bin/rke
COPY --from=seanly/toolset:helm /usr/bin/helm /usr/bin/helm
COPY --from=seanly/toolset:kustomize /usr/bin/kustomize /usr/bin/kustomize
COPY --from=seanly/toolset:velero /usr/bin/velero /usr/bin/velero
COPY --from=seanly/toolset:docker /package/docker.tar.gz /package/docker.tar.gz

# vimrc
COPY --from=seanly/vimrc /package/vim/init.vim /root/.vimrc
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    mkdir -p /root/.config/nvim; ln -s /root/.vimrc /root/.config/nvim/init.vim && \
    echo "alias vim=nvim" >> /root/.bashrc && \
    echo "alias k=kubectl" >> /root/.bashrc && \
    echo "alias vi=nvim" >> /root/.bashrc 

COPY --from=seanly/toolset:krew /root/.krew /root/.krew
ENV PATH="${PATH}:/root/.krew/bin"

WORKDIR /ws