#!/usr/bin/env bash
set -e

USER_NAME="${SUDO_USER:-$USER}"
NVM_VERSION="v0.39.1"
NODE_VERSION="24"

echo "=== Mise à jour du système ==="
sudo apt update && sudo apt upgrade -y

echo "=== Outils de base ==="
sudo apt install -y \
  ca-certificates curl gnupg lsb-release \
  software-properties-common apt-transport-https snapd \
  build-essential git wget \
  htop tree fzf ripgrep jq

#######################################
# Git config
#######################################
echo "=== Config Git de base ==="
git config --global init.defaultBranch main
git config --global core.editor "nano"
# Mets ton nom & email ici :
git config --global user.name "Ton Nom"
git config --global user.email "ton.email@example.com"

#######################################
# Docker
#######################################
echo "=== Installation de Docker ==="
sudo apt remove -y docker docker-engine docker.io containerd runc || true

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

echo "=== Ajout de l'utilisateur ${USER_NAME} au groupe docker ==="
sudo usermod -aG docker "${USER_NAME}"

#######################################
# MySQL + Postgres + Redis
#######################################
echo "=== Installation MySQL / Postgres / Redis ==="
sudo apt install -y mysql-server postgresql postgresql-contrib redis-server
sudo systemctl enable --now mysql
sudo systemctl enable --now postgresql
sudo systemctl enable --now redis-server

#######################################
# PHP + Composer
#######################################
echo "=== Installation de PHP + extensions + Composer ==="

sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

sudo apt install -y \
  php8.3 \
  php8.3-cli \
  php8.3-fpm \
  php8.3-mysql \
  php8.3-pgsql \
  php8.3-curl \
  php8.3-mbstring \
  php8.3-xml \
  php8.3-zip \
  php8.3-bcmath \
  php8.3-intl \
  php8.3-redis \
  unzip

# Installer Composer (officiel)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

echo "=== PHP installé : ==="
php -v
composer -V

#######################################
# VS Code
#######################################
echo "=== Installation de Visual Studio Code ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm -f packages.microsoft.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code

# Extensions VSC (ajoute/retire ce que tu veux)
echo "=== Installation d'extensions VS Code ==="
code --install-extension esbenp.prettier-vscode || true
code --install-extension dbaeumer.vscode-eslint || true
code --install-extension ms-azuretools.vscode-docker || true

#######################################
# Java / Android
#######################################
echo "=== Java & outils Android ==="
sudo apt install -y openjdk-17-jdk android-tools-adb android-tools-fastboot

echo "=== Installation Android Studio (snap) ==="
sudo snap install android-studio --classic

#######################################
# NVM + Node + Yarn
#######################################
echo "=== Installation de NVM (${NVM_VERSION}) ==="
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

echo "=== Installation de Node ${NODE_VERSION} via NVM ==="
nvm install "${NODE_VERSION}"
nvm alias default "${NODE_VERSION}"

echo "=== Installation de Yarn global ==="
npm install -g yarn

echo "=== Installation de tailscale ==="
curl -fsSL https://tailscale.com/install.sh | sh

echo "========================================"
echo " Installation terminée 🎉"
echo " Déconnecte/reconnecte ta session (ou reboot)"
echo " pour docker + NVM."
echo "========================================"
