#!/bin/bash

# Atualizar sistema
sudo dnf update -y
sudo dnf upgrade -y

# Instalar e Configurar EFS
sudo dnf install -y amazon-efs-utils
mkdir -p /mnt/efs
sudo mount -t efs -o tls "${EFS_ID}":/ /mnt/efs

# Instalar e configurar Docker 
sudo dnf install docker -y
sudo systemctl enable docker
sudo systemctl start docker

#Instalando Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Criar diretório para o WordPress
mkdir /home/ec2-user/wordpress
cd /home/ec2-user/wordpress

# Criar docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "${RDS_HOST}"
      WORDPRESS_DB_NAME: "${DB_NAME}"
      WORDPRESS_DB_USER: "${DB_USER}"
      WORDPRESS_DB_PASSWORD: "${DB_PASSWORD}"
    volumes:
    - /mnt/efs/wordpress:/var/www/html/
EOF

sudo docker-compose up -d