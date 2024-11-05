#!/bin/bash

# Importamos el archivo de variables
source .env

# Configuramos para mostrar los comandos y errores
set -ex

# 1. Descargar la última versión de WordPress
wget http://wordpress.org/latest.tar.gz -P /tmp

# 2. Descomprimir el archivo .tar.gz
tar -xzvf /tmp/latest.tar.gz -C /tmp

# 3. Mover el contenido de la carpeta wordpress a /var/www/html/wordpress
mv -f /tmp/wordpress /var/www/html

# 4. Crear base de datos y usuario para WordPress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# 5. Crear archivo de configuración wp-config.php a partir de wp-config-sample.php
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# 6. Configurar las variables en wp-config.php
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wordpress/wp-config.php

# 7. Configurar WP_SITEURL y WP_HOME
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/wordpress');" /var/www/html/wordpress/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN');" /var/www/html/wordpress/wp-config.php

# 8. Copiar index.php a /var/www/html
cp /var/www/html/wordpress/index.php /var/www/html/

# 9. Reemplazar la línea que carga wp-blog-header.php
sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/index.php


# 11. Habilitar el módulo mod_rewrite de Apache
a2enmod rewrite

# 12. Configurar AllowOverride en Apache
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# 13. Reiniciar el servicio de Apache
systemctl restart apache2

# 14. Generar las security keys y agregarlas al archivo de configuración
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)

# Eliminar las claves por defecto
sed -i "/AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/SECURE_AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/NONCE_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/SECURE_AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/NONCE_SALT/d" /var/www/html/wordpress/wp-config.php

# Añadir las nuevas security keys al wp-config.php
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/wordpress/wp-config.php

# 15. Cambiar propietario y grupo del directorio de WordPress
chown -R www-data:www-data /var/www/html/wordpress/

echo "Instalación de WordPress completada correctamente en /var/www/html/wordpress."
