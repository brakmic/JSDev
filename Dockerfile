FROM ubuntu:22.04

# (1) Set environment variables for pnpm
ARG PNPM_VERSION=9.15.1
ENV PNPM_VERSION=${PNPM_VERSION}
ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME:$PATH:/usr/local/bin

# Configure default system locale settings
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

###############################################################################
# (2) Install necessary packages
###############################################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    gnupg \
    software-properties-common \
    dirmngr \
    ca-certificates \
    xz-utils \
    libatomic1 \
    sudo \
    nano \
    unzip \
    build-essential \
    gcc \
    g++ \
    make \
    git \
    git-lfs \
    python3 \
    python3-pip \
    python3-distutils \
    bash-completion \
    locales \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (3) Install Node.js
###############################################################################
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

###############################################################################
# (4) Configure locales
###############################################################################
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

###############################################################################
# (5) Install pnpm package manager
###############################################################################
RUN curl -fsSL https://get.pnpm.io/install.sh | bash -s -- --version $PNPM_VERSION \
    && ln -s $PNPM_HOME/pnpm /usr/local/bin/pnpm \
    && pnpm -v

###############################################################################
# (6) Install global Node.js/TypeScript development tools
###############################################################################
RUN pnpm add -g typescript ts-node eslint prettier node-gyp

###############################################################################
# (7) Install nano syntax highlighting
###############################################################################
RUN mkdir -p /usr/share/nano-syntax \
    && curl -fsSL https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | bash

###############################################################################
# (8) Create a non-root user with passwordless sudo
###############################################################################
ARG NONROOT_USER=jsdev
ENV NONROOT_USER=${NONROOT_USER}
RUN useradd -m -s /bin/bash ${NONROOT_USER} \
    && echo "${NONROOT_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NONROOT_USER} \
    && chmod 0440 /etc/sudoers.d/${NONROOT_USER}

###############################################################################
# (9) Set default shell to bash
###############################################################################
SHELL ["/bin/bash", "-c"]

###############################################################################
# (10) Adjust file ownership for the non-root user
###############################################################################
WORKDIR /workspace
ENV HOME=/home/${NONROOT_USER}
RUN chown -R ${NONROOT_USER}:${NONROOT_USER} /workspace /pnpm /usr/local/bin/pnpm ${HOME}

###############################################################################
# (11) Switch to the non-root user
###############################################################################
USER ${NONROOT_USER}

###############################################################################
# (12) Configure default shell environment for the user
###############################################################################
RUN cp /etc/skel/.bashrc ${HOME}/.bashrc \
    && cp /etc/skel/.profile ${HOME}/.profile

###############################################################################
# (13) Add shell aliases
###############################################################################
RUN echo -e '\
alias ll="ls -la"\n\
alias la="ls -A"\n\
alias l="ls -CF"\n\
alias gs="git status"\n\
alias ga="git add"\n\
alias gp="git push"\n\
alias gl="git log"\n\
alias rm="rm -i"\n\
alias cp="cp -i"\n\
alias mv="mv -i"\n\
alias nano="nano -c"\n\
alias ..="cd .."\n\
alias ...="cd ../.."\n\
alias ....="cd ../../.."\n\
' >> ${HOME}/.bash_aliases

###############################################################################
# (14) Configure nano with syntax highlighting for the user
###############################################################################
RUN echo "include /usr/share/nano-syntax/*.nanorc" >> ${HOME}/.nanorc

###############################################################################
# (15) Set nano as the default editor and adjust ownership of config files
###############################################################################
RUN echo "export EDITOR=nano" >> ${HOME}/.bash_profile \
    && chown ${NONROOT_USER}:${NONROOT_USER} ${HOME}/.bashrc \
    ${HOME}/.profile \
    ${HOME}/.bash_profile \
    ${HOME}/.nanorc

###############################################################################
# (16) Customize the terminal prompt for the user
###############################################################################
ENV TERM=xterm-256color
RUN echo "\
# Colorized PS1 prompt\n\
export PS1=\"\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ \"\
" >> ${HOME}/.bashrc

###############################################################################
# (17) Default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
