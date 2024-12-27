# Use the brakmic/jsdev:latest image as the base
FROM brakmic/jsdev:latest

# Switch to root to perform system-level installations
USER root

###############################################################################
# (3) Install Docker
###############################################################################
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

###############################################################################
# (4) Add existing user to the Docker group
###############################################################################
RUN groupadd -f docker \
    && usermod -aG docker jsdev

# Ensure that the jsdev user has the correct permissions for Docker
RUN mkdir -p /home/jsdev/.docker \
    && chown -R jsdev:docker /home/jsdev/.docker

# Switch back to the non-root user
USER jsdev

###############################################################################
# (17) Set default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
