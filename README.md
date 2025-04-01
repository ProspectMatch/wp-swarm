# 🚀 WordPress Docker Swarm Template

Template for deploying WordPress in a **Docker Swarm** environment using:

- 🐳 Docker Swarm
- ⚙️ GitHub Actions (CI/CD)
- 🔐 Secrets-based image builds and secure SSH deployment
- 🌐 NGINX Proxy Manager
- 🛠 MariaDB (shared container or RDS)
- 🧩 Auto WordPress install + plugin setup
- ✅ Optional: Redis + Cloudflare DNS

---

## 📦 What This Template Includes

- `docker-compose.yml` for Swarm-based deployment
- `wordpress/Dockerfile` to extend `wordpress:php8.4-fpm` with:
  - SSH access
  - WP-CLI
  - Auto plugin install
- GitHub Actions workflow to:
  - Build Docker image
  - Push to Docker Hub
  - Deploy to your Swarm node via SSH
- `entrypoint.sh` to initialize WordPress and install core plugins

---

## 🧰 Requirements

- Docker Swarm with at least one node labeled `wp1`
- GitHub Secrets:
  - `DOCKERHUB_USERNAME`
  - `DOCKERHUB_TOKEN`
  - `SWARM_HOST`
  - `SWARM_USER`
  - `SSH_PRIVATE_KEY`
- Optional:
  - NGINX Proxy Manager running
  - Cloudflare credentials (for DNS automation)

---

## ⚙️ Usage

### 1. Click “Use this template”

Create a new **private repo** for your WordPress site using this template.

### 2. Update Environment Values

Edit:
- `docker-compose.yml`  
- `.github/workflows/docker-build.yml`

Change:
- Site/domain name
- DB credentials
- Image name (`yourdockerhub/wp_sitename`)

### 3. Push to GitHub

This triggers:
- Docker image build via GitHub Actions
- Image push to Docker Hub
- Deployment to your Docker Swarm

---

## 📦 Installed Plugins (by default)

- Elementor
- Rank Math SEO
- Code Snippets
- WP Mail SMTP
- UpdraftPlus
- WPForms Lite
- Cloudflare
- WP Optimize

---

## 🔒 License

This project is licensed under the [MIT License](LICENSE).

---

## 🧠 Notes

- This repo is meant to be a **clean base**. You can fork it or use it as a GitHub template.
- For each client/site, spin up a **new private repo** using this template.
- Secrets should be managed securely via GitHub Actions or a vault.

---

> Made with ❤️ by Mark Wood - Prospect Match LLC
