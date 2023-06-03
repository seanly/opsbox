FROM alpine:3.17.2

RUN apk update && \
    apk add --update --no-cache python3 py3-pip curl wget jq bash bash-completion neovim \ 
        ctags openssh-server openssh-client ansible fzf git rsync openssl openssl-dev \
        certbot ncurses sshpass busybox-extras bzip2 tmux tar && \
    pip install jinja2-cli[yaml] && \
    sed -i 's/ash/bash/g' /etc/passwd && \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# tools
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq

# backup/oss
COPY --from=minio/mc /usr/bin/mc /usr/bin/mc
COPY --from=seanly/toolset:restic /usr/bin/restic /usr/bin/restic
COPY --from=seanly/toolset:ossutil /usr/bin/ossutil* /usr/bin/ossutil

# kubernetes
COPY --from=seanly/toolset:rke /usr/bin/rke /usr/bin/rke
COPY --from=seanly/toolset:helm /usr/bin/helm /usr/bin/helm
COPY --from=seanly/toolset:kustomize /usr/bin/kustomize /usr/bin/kustomize
COPY --from=seanly/toolset:kubectl /usr/bin/kubectl /usr/bin/kubectl
COPY --from=seanly/toolset:velero /usr/bin/velero /usr/bin/velero

COPY --from=seanly/toolset:krew /root/.krew /root/.krew
ENV PATH="${PATH}:/root/.krew/bin"

# docker
COPY --from=seanly/toolset:docker /install/docker/usr/bin/* /usr/bin/

# vimrc
COPY --from=seanly/toolset:vimrc /package/vim/init.vim /root/.vimrc
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    mkdir -p /root/.config/nvim; ln -s /root/.vimrc /root/.config/nvim/init.vim && \
    echo "alias vim=nvim" >> ~/.bashrc  \
    ;echo "alias k=kubectl" >> ~/.bashrc \
    ;echo "alias vi=nvim" >> ~/.bashrc  \
    ;echo 'plugins=(git bashmarks progress ansible kubectl)' >> ~/.bashrc  \
    ;echo "source \$OSH/oh-my-bash.sh" >> ~/.bashrc  \
    ;git clone --depth 1 https://github.com/jonmosco/kube-ps1.git ~/.plugins/kube-ps1  \
    ;echo "source ~/.plugins/kube-ps1/kube-ps1.sh" >> ~/.bashrc \
    ;echo "export PS1='[\$(kube_ps1) \u@\h \W]\$ '">> ~/.bashrc  \
    ;echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc  \
    ;sed -i 's;^OSH_THEME;#OSH_THEME;g' ~/.bashrc \
    ;mkdir -p /root/.kube \
    ;source ~/.bashrc 

WORKDIR /root

CMD ["/bin/bash"]