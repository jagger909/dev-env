FROM ubuntu:latest
MAINTAINER JAGGER <jagger909@gmail.com>

# ------------------------------------------------------------------
# ------------------------------------------------------------------
# ------------------------------------------------------------------
# ------------------------------------------------------------------

# Start by changing the apt output, as stolen from Discourse's Dockerfiles.
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections && \

  apt-get update && \
  apt-get install -y ca-certificates &&\
  apt-get install -y openssh-client git build-essential zsh vim vim-nox tmux htop stow direnv ctags man make cmake ncurses-dev automake autoconf wget curl && \
  apt-get install -y python-dev python-pip software-properties-common && \

# Install ruby, which is used for github-auth
  apt-get install -y ruby && \

# Install the Github Auth gem, which will be used to get SSH keys from GitHub
# to authorize users for SSH
  gem install github-auth --no-rdoc --no-ri

RUN git config --global user.name "jagger909"
RUN git config --global user.email jagger909@gmail.com

# Install searching tools
RUN apt-get install -y ack-grep &&\
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb && \
    dpkg -i ripgrep_0.10.0_amd64.deb && \
    rm ripgrep_0.10.0_amd64.deb

# Install fzf
RUN wget https://github.com/junegunn/fzf-bin/releases/download/0.17.4/fzf-0.17.4-linux_amd64.tgz && \
    tar -zxvf fzf-0.17.4-linux_amd64.tgz && \
    mv fzf /usr/local/bin/fzf && \
    rm fzf-0.17.4-linux_amd64.tgz

# Install ZSH
RUN sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd
ENV SHELL /bin/zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/clarketm/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
# Install Tig
RUN git clone --depth 1 https://github.com/jonas/tig /tmp/tig \
  && cd /tmp/tig \
  #&& make configure \
  #&& ./configure \
  && make prefix=/usr/local \
  && make install prefix=/usr/local \
  && rm -rf /tmp/tig

# Dotfiles
RUN git clone --depth 1 https://github.com/chengbo/dotfiles /root/dotfiles \
  && rm /root/.zshrc \
  && cd /root/dotfiles \
  && stow vim zsh tmux

# Install VIM
WORKDIR /root/.vim/bundle
RUN git clone --depth 1 https://github.com/VundleVim/Vundle.vim \
  && git clone --depth 1 https://github.com/arcticicestudio/nord-vim \
  && git clone --depth 1 https://github.com/sheerun/vim-polyglot \
  && git clone --depth 1 https://github.com/tpope/vim-fugitive \
  && git clone --depth 1 https://github.com/vim-airline/vim-airline \
  && git clone --depth 1 https://github.com/vim-airline/vim-airline-themes \
  && git clone --depth 1 https://github.com/w0rp/ale \
  && git clone --depth 1 https://github.com/nvie/vim-flake8 \
  && git clone --depth 1 https://github.com/editorconfig/editorconfig-vim \
  && git clone --depth 1 https://github.com/mileszs/ack.vim \
  && git clone --depth 1 https://github.com/ctrlpvim/ctrlp.vim \
  && git clone --depth 1 https://github.com/scrooloose/nerdcommenter \
  && git clone --depth 1 https://github.com/scrooloose/nerdtree \
  && git clone --depth 1 https://github.com/Xuyuanp/nerdtree-git-plugin \
  && git clone --depth 1 https://github.com/tpope/vim-surround \
  && git clone --depth 1 https://github.com/easymotion/vim-easymotion \
  && git clone --depth 1 https://github.com/airblade/vim-gitgutter \
  && git clone --depth 1 https://github.com/Shougo/neocomplete.vim \
  && git clone --depth 1 https://github.com/Chiel92/vim-autoformat \
  && git clone --depth 1 https://github.com/terryma/vim-multiple-cursors \
  && git clone --depth 1 https://github.com/ntpeters/vim-better-whitespace \
  && git clone --depth 1 https://github.com/terryma/vim-expand-region \
  && git clone --depth 1 https://github.com/ap/vim-buftabline \
  && git clone --depth 1 https://github.com/davidhalter/jedi-vim \
  && git clone --depth 1 https://github.com/vim-python/python-syntax \
  && git clone --depth 1 https://github.com/vim-scripts/sessionman.vim \
  && git clone --depth 1 https://github.com/luochen1990/rainbow \
  && git clone --depth 1 https://github.com/mhinz/vim-startify \
  && git clone --depth 1 https://github.com/kshenoy/vim-signature \
  && git clone --depth 1 https://github.com/Yggdroot/indentLine

RUN pip install powerline-status jedi flake8
RUN vim +PluginInstall +qall > /dev/null 2>&1
RUN pip install tmuxp



# Clone config files
RUN mkdir -p /root/devtools && \
   git clone https://github.com/chasdev/config-files.git /root/devtools/config-files
  #ln -s /root/devtools/config-files/.vimrc /root/.vimrc && \
  #ln -s /root/devtools/config-files/.tmux.conf /root/.tmux.conf && \
  #ln -s /root/devtools/config-files/.bash_profile /root/.bash_profile && \
  #ln -s /root/devtools/config-files/.gitconfig /root/.gitconfig && \
  #ln -s /root/devtools/config-files/.gitignore /root/.gitignore && \
  #git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim && \
  #ln -s /root/devtools/config-files/my-snippets /root/.vim/my-snippets && \

# Set up SSH with SSH forwarding
RUN apt-get install -y openssh-server && \
  mkdir /var/run/sshd && \
  echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config

# Generate UTF-8 locale
RUN apt-get install -y locales && \
  locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

#RUN apt-get install -y sudo && \
  #    useradd dev -d /home/dev -m -s /bin/zsh &&\
  # adduser dev sudo && \
  # echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#USER dev

RUN mkdir -p /root/dev/working
WORKDIR /root/dev/

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

CMD ["chsh -s $(which zsh)"]

ADD ssh_key_adder.rb /root/ssh_key_adder.rb

# Expose SSH
EXPOSE 22

# Install the SSH keys of ENV-configured GitHub users before running the SSH
# server process. See README for SSH instructions.
CMD /root/ssh_key_adder.rb && /usr/sbin/sshd -D
