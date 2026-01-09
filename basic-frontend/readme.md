Got it 👍
Here is a **focused, script-only `README.md`** that explains **only this shell script** — what it does, why each part exists, and how it’s meant to be used. No extra architecture talk, no emojis.

---

# EC2 User Data Deployment Script (Docker + NGINX)

## Purpose

This shell script is designed to **fully automate application setup on a fresh Ubuntu EC2 instance**.

It is intended to be used as:

* **EC2 User Data**
* A one-time bootstrap script for new instances
* An automation layer for Auto Scaling environments

When executed, the script prepares the server and makes the application available on **port 80** without any manual intervention.

---

## What This Script Does

The script performs the following tasks in order:

1. Updates the operating system
2. Installs and configures Docker
3. Installs and configures NGINX
4. Runs a Dockerized application
5. Configures NGINX as a reverse proxy
6. Reloads NGINX with the new configuration

If the instance is recreated, the script can safely run again.

---

## Script Breakdown

### 1. Shell Safety and Variables

```bash
#!/bin/bash
set -e
```

* Ensures the script exits immediately if any command fails
* Prevents partial or broken deployments

```bash
DOCKER_IMAGE="gopal161/revueon-landing-page"
CONTAINER_PORT=80
APP_PORT=3000
```

* `DOCKER_IMAGE`: Docker image to deploy
* `CONTAINER_PORT`: Port exposed inside the container
* `APP_PORT`: Port used internally on the host for Docker

These values can be changed without modifying the rest of the script.

---

### 2. System Update

```bash
apt-get update -y
apt-get upgrade -y
```

* Updates package metadata
* Applies security and bug-fix updates
* Ensures compatibility with Docker and NGINX

---

### 3. Docker Installation and Setup

```bash
if ! command -v docker &> /dev/null; then
  apt-get install -y docker.io
  systemctl start docker
  systemctl enable docker
fi
```

* Installs Docker only if it is not already installed
* Starts Docker immediately
* Enables Docker on system boot

```bash
usermod -aG docker ubuntu
```

* Allows the `ubuntu` user to run Docker without `sudo`
* Important for automation and debugging

---

### 4. NGINX Installation

```bash
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
```

* Installs NGINX as the web server
* Starts it immediately
* Ensures it starts on reboot

NGINX will be responsible for handling HTTP traffic on port 80.

---

### 5. Remove Any Existing Container

```bash
docker rm -f landing-page || true
```

* Stops and removes an existing container with the same name
* Prevents conflicts during redeployments
* `|| true` ensures the script does not fail if the container does not exist

---

### 6. Run the Docker Container

```bash
docker run -d \
  --name landing-page \
  -p ${APP_PORT}:${CONTAINER_PORT} \
  ${DOCKER_IMAGE}
```

* Runs the application in detached mode
* Maps container port 80 to host port 3000
* Keeps the application isolated from port 80 on the host

---

### 7. Configure NGINX Reverse Proxy

```bash
cat <<EOF > /etc/nginx/sites-available/default
```

This section:

* Replaces the default NGINX configuration
* Forwards all HTTP traffic from port 80 to the Docker container

Key behavior:

* All paths (`/`, `/assets`, `/css`, `/js`, etc.) are proxied
* No static file handling by NGINX
* Prevents 404 errors for frontend assets

This is critical for frontend applications built with React, Vite, or similar tools.

---

### 8. Validate and Reload NGINX

```bash
nginx -t
systemctl reload nginx
```

* Validates the configuration syntax
* Reloads NGINX without downtime
* Ensures the new proxy rules are active

---

## End Result

After the script finishes:

* NGINX listens on **port 80**
* The Docker container runs internally on **port 3000**
* The application is accessible directly via:

  ```
  http://<server-ip>
  ```
* No port number is required in the browser

---

## Intended Usage

This script is best suited for:

* EC2 User Data
* Auto Scaling Group launch templates
* Automated server provisioning
* Stateless frontend deployments

It is **not intended** for manual, interactive server management.

---

## Summary

This script provides:

* Fully automated server setup
* Clean separation between web server and application
* Safe redeployment behavior
* Compatibility with load balancers and scaling

It is a simple, production-oriented bootstrap script focused on reliability and automation.

---

If you want, I can next:

* Simplify it further
* Add logging
* Make it configurable via environment variables
* Provide a version specifically tuned for ALB health checks
