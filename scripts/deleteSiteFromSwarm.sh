#!/bin/bash

# --- PROMPTS ---
read -p "Site name (e.g. demo): " SITENAME
read -p "Stack name (e.g. wp_mark): " STACK_NAME
read -p "GitHub org or user (e.g. ProspectMatch): " GITHUB_USER
IMAGE_NAME="ghcr.io/${GITHUB_USER}/${STACK_NAME}:latest"
REPO_NAME="${STACK_NAME}"

read -p "Domain (e.g. mark.example.com): " DOMAIN
read -p "MariaDB container name (e.g. npm_npm-mysql): " DB_CONTAINER
read -p "MariaDB root password: " DB_ROOT_PASS
read -p "MariaDB database name (e.g. mark_db): " DB_NAME
read -p "MariaDB user to drop (e.g. mark_user): " DB_USER

read -p "NPM Host (e.g. http://localhost:81): " NPM_HOST
read -p "NPM Email login: " NPM_USER
read -sp "NPM Password: " NPM_PASS
echo ""

read -p "Delete GitHub repo too? (y/N): " DELETE_REPO
if [[ "$DELETE_REPO" == "y" || "$DELETE_REPO" == "Y" ]]; then
  echo "🔐 Using GitHub CLI to delete repo and GHCR image..."
fi

echo ""
echo "⚠️ WARNING: This will delete all resources for '${STACK_NAME}'"
read -p "Continue? (y/N): " CONFIRM
[[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]] && echo "Cancelled." && exit 1

# --- REMOVE SWARM STACK ---
echo "🗑 Removing stack: $STACK_NAME"
docker stack rm "$STACK_NAME"
sleep 5

# --- REMOVE LOCAL DOCKER IMAGE ---
echo "🗑 Removing local Docker image: $IMAGE_NAME"
docker image rm "$IMAGE_NAME" --force || echo "Image not found or already removed."

# --- REMOVE MARIADB DATABASE + USER ---
echo "🗑 Dropping database and user..."
DB_CONTAINER_ID=$(docker ps --filter "name=${DB_CONTAINER}" --format "{{.ID}}" | head -n1)

if [ -n "$DB_CONTAINER_ID" ]; then
  docker exec -i "$DB_CONTAINER_ID" mariadb -uroot -p"${DB_ROOT_PASS}" <<EOF
DROP DATABASE IF EXISTS ${DB_NAME};
DROP USER IF EXISTS '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
else
  echo "❌ MariaDB container not found: $DB_CONTAINER"
fi

# --- REMOVE NPM PROXY HOST ---
echo "🔑 Logging into NPM to remove domain..."
JWT=$(curl -s -X POST "${NPM_HOST}/api/tokens" -H "Content-Type: application/json" \
  -d "{\"identity\":\"${NPM_USER}\",\"secret\":\"${NPM_PASS}\"}" | jq -r .token)

if [[ "$JWT" == "null" || -z "$JWT" ]]; then
  echo "❌ NPM login failed"
else
  HOST_ID=$(curl -s -H "Authorization: Bearer $JWT" "${NPM_HOST}/api/nginx/proxy-hosts" | jq ".[] | select(.domain_names[] | contains(\"$DOMAIN\")) | .id")

  if [[ -n "$HOST_ID" ]]; then
    echo "🧨 Deleting NPM proxy host ID: $HOST_ID for $DOMAIN"
    curl -s -X DELETE "${NPM_HOST}/api/nginx/proxy-hosts/${HOST_ID}" -H "Authorization: Bearer $JWT"
  else
    echo "⚠️ No matching NPM proxy host found for $DOMAIN"
  fi
fi

# --- DELETE FROM GHCR + GITHUB REPO (optional) ---
if [[ "$DELETE_REPO" == "y" || "$DELETE_REPO" == "Y" ]]; then
  echo "🗑 Deleting image from GHCR..."
  gh api --method DELETE /user/packages/container/${STACK_NAME}/versions --silent || echo "⚠️ Could not delete image. It may be retained or require manual cleanup."

  echo "🗑 Deleting GitHub repo: $GITHUB_USER/$REPO_NAME"
  gh repo delete "$GITHUB_USER/$REPO_NAME" --yes || echo "⚠️ Failed to delete repo (check auth/token)"
fi

echo ""
echo "✅ All done. '${STACK_NAME}' and related resources have been removed."
