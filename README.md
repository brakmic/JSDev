# JSDev Docker Image

![Docker Pulls](https://img.shields.io/docker/pulls/brakmic/jsdev)
![Docker Image Size](https://img.shields.io/docker/image-size/brakmic/jsdev)
![License](https://img.shields.io/github/license/brakmic/jsdev)

## Overview

JSDev is a streamlined Docker image tailored for JavaScript, TypeScript, and Node.js development. Built on Ubuntu 22.04, it provides a robust and customizable environment, equipping developers with all the essential tools to build, test, and deploy modern web applications efficiently.

For developers who require Docker tools within their development environment, an extended version of this image is also available, integrating essential Docker utilities seamlessly.

## Features

### Base Image: `brakmic/jsdev:latest`

- **Ubuntu 22.04 Base:** Reliable and up-to-date operating system.
- **Node.js v22:** Latest stable version for cutting-edge JavaScript features.
- **pnpm Package Manager:** Fast and efficient package management.
- **Global Development Tools:**
  - TypeScript
  - ts-node
  - ESLint
  - Prettier
  - node-gyp
- **Non-Root User:** `jsdev` user with passwordless sudo for enhanced security.
- **Enhanced Terminal Experience:**
  - Nano with syntax highlighting
  - Custom shell aliases for productivity
  - Colorized prompt for better readability
- **Development Ready:** Pre-installed build essentials, Git, Git LFS, Python3, and more.

### Extended Image: `brakmic/jsdev-docker:latest`

- **Includes All Features of `brakmic/jsdev:latest`**
- **Docker Tools Installed:**
  - **Docker Engine (`docker-ce`):** Core Docker functionality for container management.
  - **Docker CLI (`docker-ce-cli`):** Command-line interface for interacting with Docker.
  - **Containerd (`containerd.io`):** High-level container runtime.
  - **Docker Buildx Plugin (`docker-buildx-plugin`):** Advanced builder CLI plugin for multi-platform builds.
  - **Docker Compose Plugin (`docker-compose-plugin`):** Tool for defining and running multi-container Docker applications.
- **Configured Docker Group:**
  - The `jsdev` user is added to the `docker` group, allowing Docker commands to be executed without `sudo`.

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your machine.
- (Optional) [Visual Studio Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension for an integrated development experience.

### Pull the Docker Images

#### Pull the Base Image

```bash
docker pull brakmic/jsdev:latest
```

#### Pull the Extended Image (with Docker Tools)

```bash
docker pull brakmic/jsdev-docker:latest
```

### Running the Containers

#### Running the Base JSDev Container

To start a container using the `jsdev` image:

```bash
docker run -it --name my-jsdev-container brakmic/jsdev:latest
```

This command will launch an interactive bash shell within the container.

#### Running the Extended JSDev Docker Container

To start a container using the `jsdev-docker` image with Docker tools:

```bash
docker run -it --name my-jsdev-docker-container brakmic/jsdev-docker:latest
```

This command will launch an interactive bash shell within the container, with Docker tools installed and configured for the `jsdev` user.

### Using with VS Code Dev Containers

To leverage the full potential of the JSDev Docker images within Visual Studio Code:

1. **Create a `.devcontainer` Directory:**

   In the root of your project, create a `.devcontainer` folder.

2. **Add `devcontainer.json`:**

   Inside `.devcontainer`, create a `devcontainer.json` file with the following content:

   ```json
   {
     "name": "JSDev Container",
     "image": "brakmic/jsdev:latest", // Use "brakmic/jsdev-docker:latest" if Docker tools are needed
     "workspaceFolder": "/workspace",
     "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached",
     "customizations": {
       "vscode": {
         "settings": {
           "files.exclude": {
             "**/.git": true,
             "**/.DS_Store": true
           }
         }
       }
     },
     "mounts": [
       "source=${localWorkspaceFolder}/.devcontainer/setup-workspace.mjs,target=/workspace/.devcontainer/setup-workspace.mjs,type=bind"
     ],
     "postCreateCommand": "node /workspace/.devcontainer/setup-workspace.mjs && ln -sf /workspace/dev.code-workspace /home/jsdev/.vscode-server/dev.code-workspace",
     "remoteUser": "jsdev"
   }
   ```

   - **Note:** If you intend to use Docker tools within the Dev Container, update the `"image"` field to `"brakmic/jsdev-docker:latest"`.

3. **Add Setup Scripts:**

   Place any necessary setup scripts (e.g., `setup-workspace.mjs`) inside the `.devcontainer` directory.

4. **Open in VS Code:**

   Open your project in VS Code. You should see a prompt to reopen the project in a Dev Container. Confirm to start using the JSDev environment.

## Customization

Feel free to modify the Dockerfiles or the `devcontainer.json` to suit your specific development needs. Whether it's adding new global packages, configuring additional tools, or adjusting user settings, JSDev is designed to be flexible and adaptable.

## Contributing

Contributions are welcome! If you have suggestions, bug fixes, or improvements, please open an issue or submit a pull request.

## 🐳 **Additional Information for the Extended Image**

The extended Docker image `brakmic/jsdev-docker:latest` is designed for developers who require Docker functionalities within their development environment. This setup is ideal for those working on containerized applications, microservices, or requiring Docker for testing and deployment processes.

### **Installed Docker Tools:**

- **Docker Engine (`docker-ce`):** Enables containerization and management of Docker containers.
- **Docker CLI (`docker-ce-cli`):** Provides the command-line interface to interact with Docker.
- **Containerd (`containerd.io`):** An industry-standard container runtime.
- **Docker Buildx Plugin (`docker-buildx-plugin`):** Facilitates advanced image building capabilities, including multi-platform builds.
- **Docker Compose Plugin (`docker-compose-plugin`):** Simplifies the management of multi-container Docker applications.

### **User Configuration:**

- **Docker Group Membership:** The `jsdev` user is part of the `docker` group, allowing seamless execution of Docker commands without the need for `sudo`. Verify by running:

  ```bash
  groups
  ```

  Expected output should include `docker`:

  ```
  jsdev sudo docker
  ```

### **Usage Example with Docker Tools:**

After running the extended container, you can verify Docker installation:

1. **Check Docker Version:**

   ```bash
   docker --version
   ```

   *Expected Output:*

   ```
   Docker version 20.10.7, build f0df350
   ```

2. **Run a Test Docker Container:**

   ```bash
   docker run hello-world
   ```

   *Expected Output:*

   ```
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   ...
   ```
   
## License

This project is licensed under the [MIT License](./LICENSE).
