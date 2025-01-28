# ==============================
# Base Image
# ==============================
FROM ubuntu:22.04

# ==============================
# Environment Variables
# ==============================
# Configure default system locale settings
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color

# Set non-root user name
ARG NONROOT_USER=psdev
ENV NONROOT_USER=${NONROOT_USER}
ENV HOME=/home/${NONROOT_USER}
ENV NVM_DIR=/usr/local/nvm

# Set Node.js version to major version only for flexibility
ARG NODE_VERSION=22
ENV NODE_VERSION=${NODE_VERSION}

# ==============================
# Install Necessary Packages
# ==============================
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
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libdrm2 \
    libxkbcommon0 \
    libgbm1 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    fonts-liberation \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# ==============================
# Configure Locales
# ==============================
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# ==============================
# Install NVM, Node.js, and Global npm Packages
# ==============================
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && \
             nvm install $NODE_VERSION && \
             nvm alias default $NODE_VERSION && \
             nvm use default && \
             node -v && npm -v && \
             npm install -g typescript ts-node eslint prettier node-gyp"

# ==============================
# Install Docker
# ==============================
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================
# Install PureScript and Spago
# ==============================
RUN bash -c "source $NVM_DIR/nvm.sh && npm install -g purescript spago"

# ==============================
# Create a Non-Root User (psdev)
# ==============================
RUN useradd -m -s /bin/bash ${NONROOT_USER} \
    && echo "${NONROOT_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NONROOT_USER} \
    && chmod 0440 /etc/sudoers.d/${NONROOT_USER}

# ==============================
# Add User to Docker Group
# ==============================
RUN groupadd -f docker \
    && usermod -aG docker ${NONROOT_USER}

# ==============================
# Adjust File Ownership
# ==============================
WORKDIR /workspace
RUN mkdir -p /home/${NONROOT_USER}/.docker && \
    chown -R ${NONROOT_USER}:${NONROOT_USER} /workspace /usr/local/nvm /home/${NONROOT_USER}

# ==============================
# Configure Nano with Syntax Highlighting
# ==============================
RUN mkdir -p /usr/share/nano-syntax && \
    curl -fsSL https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | bash && \
    echo "include /usr/share/nano-syntax/*.nanorc" >> /home/${NONROOT_USER}/.nanorc && \
    chown ${NONROOT_USER}:${NONROOT_USER} /home/${NONROOT_USER}/.nanorc

# ==============================
# Switch to Non-Root User
# ==============================
USER ${NONROOT_USER}

# ==============================
# Configure Shell Environment
# ==============================
RUN cp /etc/skel/.bashrc ${HOME}/.bashrc \
    && cp /etc/skel/.profile ${HOME}/.profile

# Source NVM in bashrc
RUN echo 'export NVM_DIR=/usr/local/nvm' >> ${HOME}/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ${HOME}/.bashrc

# ==============================
# Add Shell Aliases
# ==============================
RUN printf '\
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

# ==============================
# Set Default Editor and Adjust Ownership
# ==============================
RUN echo "export EDITOR=nano" >> ${HOME}/.bash_profile && \
    chown ${NONROOT_USER}:${NONROOT_USER} ${HOME}/.bashrc \
    ${HOME}/.profile \
    ${HOME}/.bash_profile \
    ${HOME}/.nanorc

# ==============================
# Customize the Terminal Prompt
# ==============================
RUN echo "\
# Colorized PS1 prompt\n\
export PS1=\"\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ \"\
" >> ${HOME}/.bashrc

# ==============================
# Set Work Directory
# ==============================
WORKDIR /workspace

# ==============================
# Default Command
# ==============================
CMD ["bash", "-i"]
