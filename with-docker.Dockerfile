ARG JSDEV_BASE=brakmic/jsdev:latest

FROM ${JSDEV_BASE}

ARG JSDEV_IMAGE_REVISION=local

LABEL org.opencontainers.image.title="jsdev-docker" \
      org.opencontainers.image.description="JSDev with Docker Engine, Buildx, Compose, and Chrome for Puppeteer" \
      org.opencontainers.image.source="https://github.com/brakmic/JSDev" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.revision="${JSDEV_IMAGE_REVISION}"

# Switch to root to perform system-level installations
USER root

###############################################################################
# (3) Install Docker
###############################################################################
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && . /etc/os-release \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
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

###############################################################################
# (4) Install libraries for Puppeteer and Chromium
###############################################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-liberation \
        libasound2t64 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libdrm2 \
        libexpat1 \
        libfontconfig1 \
        libgbm1 \
        libgdk-pixbuf-2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
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
        libxkbcommon0 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        wget \
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (5) Add the jsdev user to the Docker group
###############################################################################
RUN groupadd -f docker \
    && usermod -aG docker jsdev

RUN mkdir -p /home/jsdev/.docker \
    && chown -R jsdev:docker /home/jsdev/.docker

# Switch back to the non-root user
USER jsdev

###############################################################################
# (6) Install Chrome for Puppeteer
###############################################################################
RUN pnpx puppeteer browsers install chrome

###############################################################################
# (7) Default command
###############################################################################
CMD ["bash", "-i"]
