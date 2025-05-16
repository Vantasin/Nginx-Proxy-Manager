# 🌐 Nginx Proxy Manager Docker Stack with Optional ZFS Integration

This repository provides a self-contained Docker Compose stack to run [Nginx Proxy Manager](https://nginxproxymanager.com/), a modern UI for managing Nginx-based reverse proxies with automatic SSL via Let's Encrypt.

It supports optional ZFS integration for advanced users who wish to mount data volumes onto a ZFS dataset. The stack remains fully usable without ZFS.

---

## 📁 Features

- 🌐 Deploys `jc21/nginx-proxy-manager:latest` via Docker Compose  
- 🔐 Persistent storage for config and SSL certs using `.env`  
- 📜 Includes `preflight.sh` to verify and create ZFS datasets if needed  
- ⚙️ Compatible with Ansible templating and GitOps workflows  
- 🛡️ Uses `network_mode: host` for clean port binding (optional for homelab setups)

---

## ⚙️ Requirements

- Docker and Docker Compose installed
- (Optional) ZFS installed if you want dataset-backed volumes
- (Optional) Ansible for templating `.env` files via `env.j2`

---

## 🚀 Usage

### 📦 1. Clone the Repository

```bash
git clone https://github.com/Vantasin/Nginx-Proxy-Manager.git
cd Nginx-Proxy-Manager
```

### ⚙️ 2. Set Up the `.env` File

```bash
cp env.example .env
nano .env
```

Customize:

```ini
TZ=America/Toronto

# Optional ZFS settings
ZPOOL=tank
NPM_DATASET_PATH=docker/volumes/Nginx-Proxy-Manager
NPM_DATASET=tank/docker/volumes/Nginx-Proxy-Manager
NPM_DATA_VOLUME=/tank/docker/volumes/Nginx-Proxy-Manager

# Without ZFS, use:
# NPM_DATA_VOLUME=./data
```

---

### 🧪 3. Run ZFS Preflight (Optional)

```bash
./preflight.sh
```

This script checks for required ZFS pool and dataset and creates it if needed.

---

### 🐳 4. Launch the Stack

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

---

## 🤖 Optional: Ansible Integration

You can use the included `env.j2` file to generate your `.env` dynamically using Ansible.

### Example:

```yaml
- name: Template .env for {{ stack.name }}
  template:
    src: "{{ compose_root }}/{{ stack.name }}/env.j2"
    dest: "{{ compose_root }}/{{ stack.name }}/.env"
```

Where `compose_root` is typically:

```
/tank/docker/compose
```

This enables clean injection of variables like `npm_data_volume`, `zfs_pool`, and `npm_dataset`.

---

## 📄 File Overview

| File                   | Description                                               |
|------------------------|-----------------------------------------------------------|
| `docker-compose.yml`   | Nginx Proxy Manager container definition                  |
| `env.example`          | Example environment file                                  |
| `env.j2`               | Ansible template for generating `.env`                    |
| `preflight.sh`         | Script to create a ZFS dataset if it doesn't exist        |
| `git_push.py`          | Helper to stage, commit, and push to all git remotes      |
| `summarize_codebase.sh`| Script to auto-generate `codebase_summary.txt`           |

---

## 📝 License

Licensed under the [MIT License](LICENSE).
