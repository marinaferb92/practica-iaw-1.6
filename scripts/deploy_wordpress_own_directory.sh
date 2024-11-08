#!/bin/bash

# Para mostrar los comandos que se van ejecutando.
set -ex

# Descargar la URL de WordPress, después de comprobar su funcionamiento.
# Descargamos el código fuente de WordPress.
wget http://wordpress.org/latest.tar.gz -P /tmp

# Extraemos el archivo descargado.
tar -xzvf /tmp/latest.tar.gz -C /tmp

# Borramos instalaciones previas de WordPress en el directorio de destino.
rm -rf /var/www/html/*

#Creamos el directorio para la instalacion de Wordpress
mkdir -p /var/www/html/$WORDPRESS_DIRECTORY

# Movemos el contenido de WordPress al directorio de destino.
mv -f /tmp/wordpress/* /var/www/html

#Creamos una base de datos.
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

cp /var/www/html/$WORDPRESS_DIRECTORY/wp-config-sample.php /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

#Configuramos el archivo de configuración de Wordpress

sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

#Copiamos el archivo /var/www/html/wordpress/index.php a /var/www/html.
cp /var/www/html/$WORDPRESS_DIRECTORY/index.php /var/www/html

#configuramos el archivo index.php
sed -i "s#wp-blog-header.php#$WORDPRESS_DIRECTORY/wp-blog-header.php#" /var/www/html/index.php 

#Cambiar propietario y grupo del directorio.

chown -R www-data:www-data /var/www/html/

# Habilitar el módulo mod_rewrite de Apache
a2enmod rewrite

# Reiniciar Apache para aplicar los cambios
systemctl restart apache2