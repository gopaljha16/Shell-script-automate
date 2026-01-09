#!/bin/bash
set -e

# -----------------------------
# VARIABLES (EDIT IF NEEDED)
# -----------------------------
DOCKER_IMAGE="gopal161/revueon-landing-page"
CONTAINER_PORT=80
APP_PORT=3000

# -----------------------------
# SYSTEM UPDATE
# -----------------------------
apt-get update -y
apt-get upgrade -y

# -----------------------------
# INSTALL DOCKER
# -----------------------------
if ! command -v docker &> /dev/null; then
  apt-get install -y docker.io
  systemctl start docker
  systemctl enable docker
fi

# Allow ubuntu user to run docker
usermod -aG docker ubuntu

# -----------------------------
# INSTALL NGINX
# -----------------------------
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# -----------------------------
# STOP ANY OLD CONTAINER
# -----------------------------
docker rm -f landing-page || true

# -----------------------------
# RUN DOCKER CONTAINER
# -----------------------------
docker run -d \
  --name landing-page \
  -p ${APP_PORT}:${CONTAINER_PORT} \
  ${DOCKER_IMAGE}

# -----------------------------
# CONFIGURE NGINX REVERSE PROXY
# -----------------------------
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_redirect off;
    }
}
EOF

# -----------------------------
# RELOAD NGINX
# -----------------------------
nginx -t
systemctl reload nginx

echo "✅ Deployment completed successfully"
