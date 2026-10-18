# JSDev Docker Image

![Docker Pulls](https://img.shields.io/docker/pulls/brakmic/jsdev)
![Docker Image Size](https://img.shields.io/docker/image-size/brakmic/jsdev)
![License](https://img.shields.io/github/license/brakmic/jsdev)

## Overview

JSDev is a development image for JavaScript, TypeScript, and Node.js. It is
built on Ubuntu 24.04 with Node.js 24, pnpm, and a set of global development
tools.

An extended image adds Docker Engine, Buildx, Compose, and Chrome for Puppeteer.

For pure PureScript development, see [PSDev](https://github.com/brakmic/PSDev).

## Features

### Base image: `brakmic/jsdev:latest`

- Ubuntu 24.04
- Node.js 24
- pnpm 12.14.0
- Global tools: TypeScript 5, ts-node 10, tsx 4, ESLint 9, Prettier 3, node-gyp 13
- Non-root user `jsdev` with UID 1000 and passwordless sudo
- Build essentials, Git, Git LFS, Python 3
- Nano with syntax highlighting, shell aliases, colorized prompt

### Extended image: `brakmic/jsdev-docker:latest`

- Everything from the base image
- Docker Engine, Docker CLI, containerd, Buildx, and Compose plugins
- The `jsdev` user is a member of the `docker` group
- Chrome installed for Puppeteer

## Getting started

```sh
docker pull brakmic/jsdev:latest
docker run -it --name my-jsdev-container brakmic/jsdev:latest
```

Extended image:

```sh
docker pull brakmic/jsdev-docker:latest
docker run -it --name my-jsdev-docker-container brakmic/jsdev-docker:latest
```

The extended image needs the Docker daemon of the host, for example by mounting
the socket:

```sh
docker run -it -v /var/run/docker.sock:/var/run/docker.sock brakmic/jsdev-docker:latest
```

Docker-in-Docker is also possible when the container runs privileged.

The container runs as UID 1000. On Linux hosts, make sure the mounted project
directory is writable by that UID; Docker Desktop on Windows and macOS maps file
ownership automatically.

## Image tags

Both images are published with these tags:

- `latest`
- `1.0`
- `1.0.0`
- `node24`

The `jsdev` image is published for `amd64` and `arm64`. The `jsdev-docker` image
is published for `amd64`.

## Dev containers

The repository contains `.devcontainer/devcontainer.json`, which builds the
local Dockerfile. In VS Code, run **Dev Containers: Reopen in Container**.

To use the published image in another project, add a `.devcontainer/devcontainer.json`:

```json
{
  "name": "JSDev",
  "image": "brakmic/jsdev:latest",
  "remoteUser": "jsdev",
  "workspaceFolder": "/workspace",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached"
}
```

Use `brakmic/jsdev-docker:latest` when Docker tools are needed.

## Build the images

```sh
docker build -t jsdev:local .
docker build --build-arg JSDEV_BASE=jsdev:local -f with-docker.Dockerfile -t jsdev-docker:local .
```

## Publishing

The release workflow publishes to GHCR and Docker Hub when a `v*` tag is pushed.
Docker Hub automated builds are not used; GitHub Actions is the only publisher.

Repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

The tag must match `JSDEV_VERSION` in the Dockerfile.

## License

MIT
