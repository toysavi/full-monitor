# Grafana Monitoring with NGINX Reverse Proxy

This repository contains the setup for running Grafana with NGINX as a reverse proxy using Docker Compose. The setup ensures secure communication via SSL, supports custom networking, and simplifies sensitive data management using environment variables.

---

## Repository URL
**GitHub**: [grafana-monitor](https://github.com/toysavi/gragana-monitor.git)

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)
- [Accessing Grafana](#accessing-grafana)
- [Project Structure](#project-structure)
- [License](#license)

---

## Features
- **Grafana Dashboard**: A leading open-source platform for monitoring and analytics.
- **NGINX Reverse Proxy**: Routes client requests to Grafana, enabling SSL termination for secure connections.
- **Environment Variables**: Sensitive information (like passwords) is stored outside the configuration files.
- **Custom Networking**: Segregated frontend and backend networks for enhanced security.
- **SSL Integration**: Optional support for HTTPS using self-signed or CA-provided certificates.

---

## Requirements
- Docker (20.10+)
- Docker Compose (1.27+)
- Git

---

## Setup Instructions
1. **Create direcitory Grafana**
    
    Create directory for Grafana!
    ```
    mkdir /Grafana
    chmod 755 /Grafana
    cd /Grafana
    ```
2. **Clone the Repository**:
   ```bash
   git clone https://github.com/toysavi/grafana-monitor.git .
   ```
3. **Create direcitory env_file**
    
    Create for password store of Grafana!
    ```
    mkdir -p env_file
    ```
4. **Make a password for Grafana Admin**
    ```
    echo "GF_SECURITY_ADMIN_PASSWORD=YourStrongP@ssword" > env_file/GF_SECURITY_ADMIN_PASSWORD
    ```
    Note: Replace "YourStrongP@ssword" to your own password

5. **Create direcitory ssl**
    
    Create directory for Certifcate store!
    ```
    mkdir ssl/
    ```
    Note: copy your private key ssl to ./ssh
    
    - Rename certificate file to "cert.crt"
    - Rename key file to "cert.key".

6. **Grant Permission to 775**
    ```
    chmod 755 -R /Grafana
    ```
7. **Start the Services**
    ```
    docker-compose up -d
    ```
8. **Verify containers status**
    ```
    docker ps
    ```
8. **Verify logs**
    ```
    docker-compose logs
    ```
9. **URL Access**
    ```
    https://view.sbilhank.com.kh:443
    ```