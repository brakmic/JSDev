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
	
# Install necessary libraries for Puppeteer and Chromium
RUN apt-get update && apt-get install -y \
		gconf-service \
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
		libatk1.0-0 \
		libatk-bridge2.0-0 \
		libcups2 \
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
		ca-certificates \
		fonts-liberation \
		libnss3 \
		lsb-release \
		xdg-utils \
		wget \
		&& rm -rf /var/lib/apt/lists/*


###############################################################################
# (5) Add existing user to the Docker group
###############################################################################
RUN groupadd -f docker \
    && usermod -aG docker jsdev

# Ensure that the jsdev user has the correct permissions for Docker
RUN mkdir -p /home/jsdev/.docker \
    && chown -R jsdev:docker /home/jsdev/.docker

# Switch back to the non-root user
USER jsdev


###############################################################################
# (6) Install Chrome for Puppeteer
###############################################################################
RUN pnpx puppeteer browsers install chrome

###############################################################################
# (7) Set default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
