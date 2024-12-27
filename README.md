```markdown
# JSDev Docker Image

![Docker Pulls](https://img.shields.io/docker/pulls/brakmic/jsdev)
![Docker Image Size](https://img.shields.io/docker/image-size/brakmic/jsdev)
![License](https://img.shields.io/github/license/brakmic/jsdev)

## Overview

JSDev is a streamlined Docker image tailored for JavaScript, TypeScript, and Node.js development. Built on Ubuntu 22.04, it provides a robust and customizable environment, equipping developers with all the essential tools to build, test, and deploy modern web applications efficiently.

## Features

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

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your machine.
- (Optional) [Visual Studio Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension for an integrated development experience.

### Pull the Docker Image

```bash
docker pull brakmic/jsdev:latest
```

### Running the Container

To start a container using the `jsdev` image:

```bash
docker run -it --name my-jsdev-container brakmic/jsdev:latest
```

This command will launch an interactive bash shell within the container.

### Using with VS Code Dev Containers

To leverage the full potential of the JSDev Docker image within Visual Studio Code:

1. **Create a `.devcontainer` Directory:**

   In the root of your project, create a `.devcontainer` folder.

2. **Add `devcontainer.json`:**

   Inside `.devcontainer`, create a `devcontainer.json` file with the following content:

   ```json
   {
     "name": "JSDev Container",
     "image": "brakmic/jsdev:latest",
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

3. **Add Setup Scripts:**

   Place any necessary setup scripts (e.g., `setup-workspace.mjs`) inside the `.devcontainer` directory.

4. **Open in VS Code:**

   Open your project in VS Code. You should see a prompt to reopen the project in a Dev Container. Confirm to start using the JSDev environment.

## Customization

Feel free to modify the Dockerfile or the `devcontainer.json` to suit your specific development needs. Whether it's adding new global packages, configuring additional tools, or adjusting user settings, JSDev is designed to be flexible and adaptable.

## Contributing

Contributions are welcome! If you have suggestions, bug fixes, or improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](./LICENSE).
