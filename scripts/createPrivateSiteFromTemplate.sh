#!/bin/bash

# --- CONFIG ---
TEMPLATE_REPO="https://github.com/ProspectMatch/wp-swarm"
GITHUB_USER="ProspectMatch"
STACK_ROOT="/docker/stacks"

# --- PROMPTS ---
read -p "Site name (e.g. demo): " SITENAME
read -p "Domain (e.g. demo.example.com): " DOMAIN
read -p "Swarm node name (e.g. wp1): " NODE_NAME
read -p "MariaDB container name: " DB_CONTAINER
read -p "Database name: " DB_NAME
read -p "Database user: " DB_USER
read -p "Database password: " DB_PASS
read -p "WordPress admin email: " ADMIN_EMAIL
read -p "WordPress admin username: " ADMIN_USER
read -p "WordPress admin password: " ADMIN_PASS

STACK_NAME="wp_${SITENAME}"
IMAGE_NAME="ghcr.io/$(echo ${GITHUB_USER,,})/${STACK_NAME}:latest"
REPO_NAME="${STACK_NAME}"
WORKDIR="${STACK_ROOT}/${STACK_NAME}"

# --- Clean up old dir if it exists ---
if [ -d "$WORKDIR" ]; then
  echo "⚠️  Directory $WORKDIR already exists. Deleting it..."
  rm -rf "$WORKDIR"
fi

# --- Clone the template repo ---
echo "📥 Cloning wp-swarm template..."
gh repo clone ${GITHUB_USER}/wp-swarm "${WORKDIR}" || { echo "❌ Failed to clone repo"; exit 1; }

cd "${WORKDIR}"

# --- Replace placeholders ---
echo "🔄 Updating template values..."
find . -type f -exec sed -i \
  -e "s|wp_template|${STACK_NAME}|g" \
  -e "s|template_db|${DB_NAME}|g" \
  -e "s|template_user|${DB_USER}|g" \
  -e "s|template_pass|${DB_PASS}|g" \
  -e "s|http://example.com|http://${DOMAIN}|g" \
  -e "s|admin@example.com|${ADMIN_EMAIL}|g" \
  -e "s|ghcr.io/ProspectMatch/wp_template|${IMAGE_NAME}|g" \
  -e "s|node.hostname == nodeHostname|node.hostname == ${NODE_NAME}|g" \
  -e "s|WP_ADMIN_USER=.*|WP_ADMIN_USER=${ADMIN_USER}|g" \
  -e "s|WP_ADMIN_PASS=.*|WP_ADMIN_PASS=${ADMIN_PASS}|g" \
  -e "s|WP_ADMIN_EMAIL=.*|WP_ADMIN_EMAIL=${ADMIN_EMAIL}|g" \
  {} +

# --- Init Git repo ---
rm -rf .git
git init
git config user.name "Swarm Automation"
git config user.email "deploy@prospectmatch.net"
git checkout -b main
git add .
git commit -m "Initial WordPress deployment for ${STACK_NAME}"

# --- Check if repo exists or create it ---
if gh repo view "${GITHUB_USER}/${REPO_NAME}" >/dev/null 2>&1; then
  echo "ℹ️ Repo ${GITHUB_USER}/${REPO_NAME} already exists. Skipping creation."
else
  echo "📦 Creating private GitHub repo: ${REPO_NAME}..."
  gh repo create "${GITHUB_USER}/${REPO_NAME}" --private --source=. --remote=origin --push
fi

# --- Push code ---
echo "🚀 Pushing code to GitHub..."
git push -u origin main

echo ""
echo "✅ WordPress site repo ready: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "🔄 GitHub Actions will now build, push to GHCR, and deploy to Docker Swarm."
