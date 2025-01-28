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
1. **Create direcitory ``Grafana``**
    
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
4. **Modify file ``nginx-grafana.conf``**
    
    - Change "view.doamin.com" to your domain
        ```
        worker_processes 1;

        events {
            worker_connections 1024;
        }

        http {
            log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent" "$http_x_forwarded_for"';

            access_log /var/log/nginx/access.log main;
            error_log /var/log/nginx/error.log;

            sendfile on;
            tcp_nopush on;
            tcp_nodelay on;
            keepalive_timeout 65;
            types_hash_max_size 2048;

            include /etc/nginx/mime.types;
            default_type application/octet-stream;

            server {
                listen 80;
                server_name view.doamin.com;  # Change this to your domain

                location / {
                    return 301 https://$host$request_uri;
                }
            }

            server {
                listen 443 ssl;
                server_name view.doamin.com;  # Change this to your domain

                ssl_certificate /etc/nginx/ssl/cert.crt;  # Change to your SSL certificate path
                ssl_certificate_key /etc/nginx/ssl/cert.key;  # Change to your SSL private key path

                ssl_protocols TLSv1.2 TLSv1.3;
                ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';

                location / {
                    proxy_pass http://grafana:3000;  # Change to your Zabbix web container name and port
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                }

                location ~ /\.ht {
                    deny all;
                }

                error_page 404 /404.html;
                location = /40x.html {
                    root /usr/share/nginx/html;
                }

                error_page 500 502 503 504 /50x.html;
                location = /50x.html {
                    root /usr/share/nginx/html;
                }
            }
        }
        ```
5. **Make a password for ``Grafana Admin``**
    ```
    echo "GF_SECURITY_ADMIN_PASSWORD=YourStrongP@ssword" > env_file/GF_SECURITY_ADMIN_PASSWORD
    ```
    ``Note``: Replace "YourStrongP@ssword" to your own password

6. **Create direcitory `ssl`**
    
    Create directory for Certifcate store!
    ```
    mkdir ssl/
    ```
    ``Note``: copy your private key ssl to ./ssh
    
    - Rename certificate file to ``cert.crt``
    - Rename key file to ``cert.key``.

7. **Grant Permission to 775**
    ```
    chmod 755 -R /Grafana
    ```
8. **Start the Services**
    ```
    docker-compose up -d
    ```
9. **Verify containers status**
    ```
    docker ps
    ```
10. **Verify logs**
    ```
    docker-compose logs
    ```
11. **URL Access**
    ```
    https://view.domain:443
    ```

    - Username: ``admin``
    - Password: Your replaced password in ``env_file``
## Conclusion  

This repository provides a ready-to-use setup for running **Grafana** with an **NGINX reverse proxy**, leveraging Docker Compose for simplicity and scalability. By securely storing sensitive information in the **`env_file`** directory and enabling SSL support, this setup ensures a secure and efficient monitoring environment.  

Whether you're setting up for production or testing purposes, this project offers a flexible and secure foundation for your monitoring needs. Customize, deploy, and start visualizing your metrics with ease!  

Happy Monitoring! 🚀  
