# Utilisation de PHP 8.1 avec Apache
FROM php:8.1-apache

# Mise à jour et installation des dépendances système
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales apt-utils git libicu-dev g++ libpng-dev libxml2-dev libzip-dev \
    libonig-dev libxslt-dev unzip wget \
    apt-transport-https lsb-release ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Configuration des locales (anglais + français)
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Installation des extensions PHP nécessaires
RUN docker-php-ext-configure intl && \
    docker-php-ext-install \
    pdo pdo_mysql opcache intl zip calendar dom mbstring gd xsl

# Installation de APCu pour le cache PHP
RUN pecl install apcu && docker-php-ext-enable apcu

# Activation du module Apache "rewrite"
RUN a2enmod rewrite

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    && mv composer.phar /usr/local/bin/composer

# Installation de Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin

# Définition du dossier de travail
WORKDIR /var/www/html

# Copie des fichiers du projet
COPY . /var/www/html

# Installation des dépendances PHP sans exécuter de scripts
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-scripts --no-autoloader

# Exposition du port Apache
EXPOSE 80

# Correction du dossier de base d’Apache (si besoin)
RUN sed -i 's!/var/www/html!/var/www/html/public!g' \
    /etc/apache2/sites-available/000-default.conf

# Démarrage du serveur Apache
CMD ["apache2-foreground"]

