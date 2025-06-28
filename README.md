# 📦 Nginx Proxy Manager Docker Compose Stack

This repository provides a self-contained Docker Compose stack to run [Nginx Proxy Manager](https://nginxproxymanager.com/), a modern UI for managing Nginx-based reverse proxies with automatic SSL via Let's Encrypt.

It supports optional ZFS integration for advanced users who wish to mount data volumes onto a ZFS dataset. The stack remains fully usable without ZFS.

---

## 📁 Directory Structure

```bash
tank/
├── docker/
│   ├── compose/
│   │   └── nginx-proxy-manager/              # Git repo lives here
│   │       ├── docker-compose.yml  # Main Docker Compose config
│   │       ├── .env                # Runtime environment variables and secrets (gitignored!)
│   │       ├── env.example         # Example .env file for reference
│   │       ├── env.template        # Optional template
│   │       ├── .woodpecker.yml     # CI/CD pipeline definition for auto-deploy
│   │       └── README.md           # This file
│   └── data/
│       └── nginx-proxy-manager/              # Volume mounts and persistent data
```

---

## 🧰 Prerequisites

* Docker Engine
* Docker Compose V2
* Git
* (Optional) ZFS on Linux for dataset management

> ⚠️ **Note:** These instructions assume your ZFS pool is named `tank`. If your pool has a different name (e.g., `rpool`, `zdata`, etc.), replace `tank` in all paths and commands
with your actual pool name.

---

## ⚙️ Setup Instructions

1. **Create the stack directory and clone the repository**

   If using ZFS:
   ```bash
   sudo zfs create -p tank/docker/compose/nginx-proxy-manager
   cd /tank/docker/compose/nginx-proxy-manager
   sudo git clone https://github.com/Vantasin/Nginx-Proxy-Manager.git .
   ```

   If using standard directories:
   ```bash
   mkdir -p ~/docker/compose/nginx-proxy-manager
   cd ~/docker/compose/nginx-proxy-manager
   git clone https://github.com/Vantasin/Nginx-Proxy-Manager.git .
   ```

2. **Create the runtime data directory** (optional)

   If using ZFS:
   ```bash
   sudo zfs create -p tank/docker/data/nginx-proxy-manager
   ```

   If using standard directories:
   ```bash
   mkdir -p ~/docker/data/nginx-proxy-manager
   ```

3. **Configure environment variables**

   Copy and modify the `.env` file:

   ```bash
   sudo cp env.example .env
   sudo nano .env
   sudo chmod 600 .env
   ```

   > Alternatively generate the `.env` file using the `env.template` template with Woodpecker CI's `.woodpecker.yml`.

4. **Start Nginx Proxy Manager**

   ```bash
   docker compose up -d
   ```

---


## 🌐 Access Nginx Proxy Manager

Once running, open your browser to:

```
http://localhost:81
```

Or replace `localhost` with your server’s IP address.

### 🔑 Initial Login Credentials

Use the following default credentials to log in for the first time:

- **Email:** `admin@example.com`
- **Password:** `changeme`

> **Note:** For security purposes, make sure to change the default password immediately after logging in.

---

## 🚀 Continuous Deployment with Woodpecker

This project includes a `.woodpecker.yml` pipeline for automated deployment using [Woodpecker CI](https://woodpecker-ci.org/).

When changes are pushed to the Git repository:
1. The pipeline is triggered by the Woodpecker server.
2. The `.env` file is rendered from `env.template` using `envsubst`.
3. The Docker Compose stack is restarted to apply updates.

---

## 🙏 Acknowledgments

- [ChatGPT](https://openai.com/chatgpt) for assistance in generating setup scripts and templates.
- [Docker](https://www.docker.com/) for container orchestration and runtime.
- [`envsubst`](https://man7.org/linux/man-pages/man1/envsubst.1.html) for lightweight environment variable substitution in template files.
- [jc21/nginx-proxy-manager](https://hub.docker.com/r/jc21/nginx-proxy-manager) the official Docker image used in this stack.
- [Nginx Proxy Manager](https://nginxproxymanager.com/) for making reverse proxy management accessible via a clean UI.
- [Woodpecker CI](https://woodpecker-ci.org/) for lightweight, self-hosted continuous integration.
- [ZFS](https://openzfs.org/) for advanced local filesystem features, dataset organization, and snapshotting.
