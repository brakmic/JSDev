FROM ubuntu:24.04

ARG JSDEV_IMAGE_REVISION=local
ARG JSDEV_VERSION=1.0.0

LABEL org.opencontainers.image.title="jsdev" \
      org.opencontainers.image.description="JavaScript and TypeScript development image with Node.js, pnpm, and common global tools" \
      org.opencontainers.image.source="https://github.com/brakmic/JSDev" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${JSDEV_VERSION}" \
      org.opencontainers.image.revision="${JSDEV_IMAGE_REVISION}"

# (1) Set environment variables for pnpm
ARG PNPM_VERSION=12.14.0
ENV PNPM_VERSION=${PNPM_VERSION}
ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME/bin:$PNPM_HOME:$PATH:/usr/local/bin

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
    bash-completion \
    locales \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (3) Install Node.js
###############################################################################
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
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
    && ln -sf $PNPM_HOME/bin/pnpm /usr/local/bin/pnpm \
    && pnpm -v

###############################################################################
# (6) Install global Node.js/TypeScript development tools
###############################################################################
RUN pnpm add -g typescript@5 ts-node@10 tsx@4 eslint@9 prettier@3 node-gyp@13 \
    && pnpm store prune

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
RUN set -eux; \
    userdel -r ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true; \
    groupadd --gid 1000 "${NONROOT_USER}"; \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash "${NONROOT_USER}"; \
    echo "${NONROOT_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${NONROOT_USER}"; \
    chmod 0440 "/etc/sudoers.d/${NONROOT_USER}"

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
RUN printf '%s\n' \
    'alias ll="ls -la"' \
    'alias la="ls -A"' \
    'alias l="ls -CF"' \
    'alias gs="git status"' \
    'alias ga="git add"' \
    'alias gp="git push"' \
    'alias gl="git log"' \
    'alias rm="rm -i"' \
    'alias cp="cp -i"' \
    'alias mv="mv -i"' \
    'alias nano="nano -c"' \
    'alias ..="cd .."' \
    'alias ...="cd ../.."' \
    'alias ....="cd ../../.."' \
    >> ${HOME}/.bash_aliases

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
