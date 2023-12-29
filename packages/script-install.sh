#!/bin/bash

# Node Version Manager: https://github.com/nvm-sh/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# PHP
PHP_VERSION=8.3
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php$PHP_VERSION libapache2-mod-php$PHP_VERSION
sudo systemctl restart apache2
sudo apt install php$PHP_VERSION-fpm libapache2-mod-fcgid
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php$PHP_VERSION-fpm
sudo systemctl restart apache2

# Composer
EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
rm composer-setup.php

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv ./squashfs-root /usr/local/share/
sudo ln -s /usr/local/share/squashfs-root/AppRun /usr/bin/nvim
rm ./nvim.appimage

# CUSTOM_NVIM_PATH=/usr/local/bin/nvim.appimage
# Set the above with the correct path, then run the rest of the commands:
# set -u
# sudo update-alternatives --install /usr/bin/ex ex "${CUSTOM_NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/vi vi "${CUSTOM_NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/view view "${CUSTOM_NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/vim vim "${CUSTOM_NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/vimdiff vimdiff "${CUSTOM_NVIM_PATH}" 110
