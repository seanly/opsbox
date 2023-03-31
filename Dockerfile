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

ENV HELM_VERSION v3.9.0
ENV KUSTOMIZE_VERSION v4.5.5
ENV RKE_VERSION v1.3.8
ENV VELERO_VERSION v1.10.2
ENV OSSUTIL_VERSION 1.7.15
ENV RESTIC_VERSION 0.15.1

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    HELM_URL_V3=https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz && \
    curl ${HELM_URL_V3} | tar xvzf - --strip-components=1 -C /usr/bin && \
    KUSTOMIZE_URL=https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    curl -sLf ${KUSTOMIZE_URL} | tar -xzf - -C /usr/bin && \
    chmod +x /usr/bin/kustomize && \
    RKE_URL=https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_linux-${ARCH} && \
    wget -O /usr/bin/rke ${RKE_URL} && \
    chmod +x /usr/bin/rke && \
    VELERO_URL=https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-${ARCH}.tar.gz && \
    curl -sLf ${VELERO_URL} | tar xvzf - --strip-components=1 -C /usr/bin && \
    OSSUTIL_URL=https://gosspublic.alicdn.com/ossutil/${OSSUTIL_VERSION}/ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}.zip  && \
    wget ${OSSUTIL_URL} && \
    unzip -d /tmp/ ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}.zip && \
    chmod 750 /tmp/ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}/* && \
    cp -r /tmp/ossutil-v${OSSUTIL_VERSION}-linux-${ARCH}/* /usr/bin/ && \
    RESTIC_URL=https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${ARCH}.bz2 && \
    curl -fsSLO ${RESTIC_URL} && \
    bzip2 -d restic_${RESTIC_VERSION}_linux_${ARCH}.bz2 && \
    mv restic_${RESTIC_VERSION}_linux_${ARCH} /usr/bin/restic && \
    chmod 750 /usr/bin/restic && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew \
    )

ENV PATH="${PATH}:/root/.krew/bin"

RUN kubectl krew install ns && \
    kubectl krew install ctx && \
    kubectl krew install neat 
    
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY --from=minio/mc /usr/bin/mc /usr/bin/mc

# docker
COPY --from=seanly/toolset:docker /package/docker.tar.gz /package/docker.tar.gz

# vimrc
COPY --from=seanly/vimrc /package/vim/init.vim /root/.vimrc
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    mkdir -p /root/.config/nvim; ln -s /root/.vimrc /root/.config/nvim/init.vim && \
    echo "alias vim=nvim" >> /root/.bashrc && \
    echo "alias k=kubectl" >> /root/.bashrc && \
    echo "alias vi=nvim" >> /root/.bashrc 

WORKDIR /ws