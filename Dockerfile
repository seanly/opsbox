FROM alpine:3.17.2

RUN apk update && \
    apk add --update --no-cache python3 py3-pip curl wget jq bash bash-completion neovim \ 
        ctags openssh-server openssh-client ansible fzf git rsync openssl openssl-dev \
        certbot ncurses sshpass busybox-extras bzip2 tmux tar zsh && \
    pip install jinja2-cli[yaml] && \
    sed -i 's/ash/zsh/g' /etc/passwd

# tools
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY --from=seanly/toolset:mkcert /usr/bin/mkcert /usr/bin/mkcert

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

# docker
COPY --from=seanly/toolset:docker /install/docker/usr/bin/* /usr/bin/

COPY --from=seanly/toolset:krew /root/.krew /root/.krew
ENV PATH="${PATH}:/root/.krew/bin"

RUN set -eux \
  ; sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
RUN set -eux \
  ; git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  ; git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  ; git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search.git ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search \
  ; git clone --depth 1 https://github.com/Dbz/kube-aliases.git ~/.oh-my-zsh/custom/plugins/kube-aliases \
  ; sed -i 's;=(git);=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting kube-aliases kube-ps1);g' ~/.zshrc \
  ;echo "PROMPT='\$(kube_ps1)'\$PROMPT" >> ~/.zshrc \
  ;mkdir -p ~/.kube 

# vimrc
COPY --from=seanly/toolset:vimrc /package/vim/init.vim ~/.vimrc
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    ;mkdir -p /root/.config/nvim; ln -s ~/.vimrc ~/.config/nvim/init.vim \
    ;echo "alias vim=nvim" >> ~/.zshrc \
    ;echo "alias k=kubectl" >> ~/.zshrc \
    ;echo "alias vi=nvim" >> ~/.zshrc

WORKDIR /data

ENV SHELL=/bin/zsh
CMD ["/bin/zsh"]
