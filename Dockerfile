FROM openjdk:17-alpine3.14
RUN apk update && \
    apk add --update --no-cache python3 py3-pip curl wget jq bash neovim ctags openssh-server openssh-client ansible fzf git && \
    pip install jinja2-cli[yaml] && \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

RUN wget https://gosspublic.alicdn.com/ossutil/1.7.14/ossutil64 && \
    mv ./ossutil64 /usr/bin/ossutil64 && \
    chmod 750 /usr/bin/ossutil64
    
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY --from=restic/restic /usr/bin/restic /usr/bin/restic
COPY --from=minio/mc /usr/bin/mc /usr/bin/mc

ARG ARCH=amd64

ENV HELM_VERSION v3.9.0
ENV KUSTOMIZE_VERSION v4.5.5
ENV ETCD_VERSION v3.5.1
ENV RKE_VERSION v1.3.19

ENV HELM_URL_V3=https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz \
    ETCD_URL=https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz \
    KUSTOMIZE_URL=https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz \
    RKE_URL=https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_linux-${ARCH}

# set up helm 3 and kustomize
RUN curl ${HELM_URL_V3} | tar xvzf - --strip-components=1 -C /usr/bin && \
    curl -sLf ${KUSTOMIZE_URL} | tar -xzf - -C /usr/bin && \
    chmod +x /usr/bin/kustomize && \
    wget -O /usr/bin/rke ${RKE_URL} && \
    chmod +x /usr/bin/rke

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
    ln -s /usr/bin/k3s /usr/bin/k && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-save && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-restore && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-translate && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-save && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-restore && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-translate

RUN mkdir -p /var/lib/rancher/k3s/agent/images/ && \
    curl -sfL ${ETCD_URL} | tar xvzf - --strip-components=1 -C /usr/bin/ etcd-${ETCD_VERSION}-linux-${ARCH}/etcdctl

ENV ETCDCTL_API=3
ENV SSL_CERT_DIR /etc/rancher/ssl
ENV PATH="$PATH:/bin/aux"

ENV CRI_CONFIG_FILE="/var/lib/rancher/k3s/agent/etc/crictl.yaml"

RUN \
    ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew \
    )

ENV PATH=${PATH}:/root/.krew/bin

RUN kubectl krew install ns && \
    kubectl krew install ctx && \
    kubectl krew install neat 

WORKDIR /data/

RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    