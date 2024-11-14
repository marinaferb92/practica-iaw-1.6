# practica-iaw-1.6
#Instalación de WordPress en una instancia EC2 de AWS

##  1. Introducción
En esta practica explicaremos el proceso completo de instalación y configuración de WordPress en una instancia EC2 de Amazon Web Services (AWS). En primer lugar, se automatizará la configuración de una pila LAMP (Linux, Apache, MySQL y PHP) y después se realizará la instalación de WordPress en dos modalidades: en el directorio raíz y en un directorio específico.

## 2.Creacion de una instancia EC2 en AWS e instalacion de Pila LAMP
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.1 y utilizaremos el script ``` install_lamp.sh ```.

**Esta vez tenemos la siguiente IP elastica para nuestra maquina**

  ![XAFmFL0REO](https://github.com/user-attachments/assets/c18ab7e9-c095-429e-a1f3-16270a55b96e)


[Practica-iaw-1.1](https://github.com/marinaferb92/practica-iaw-1.1/tree/main)

[Script Install LAMP](https://github.com/marinaferb92/practica-iaw-1.1/blob/main/scripts/install_lamp.sh)

Una vez hecho esto nos aseguraremos de que la Pila LAMP esta funcionando correctamente.

- Verificaremos el estado de apache.

  ![FkCt84dc5s](https://github.com/user-attachments/assets/6b3e4e45-9466-4530-9131-aa5c2fee0261)


- Entramos en mysql desde la terminal para ver que esta corriendo.

  ![aRjemlGztT](https://github.com/user-attachments/assets/de538497-5c5e-4f2d-960f-310f02ba812c)


- Verificamos la instalacion de PHP

  ![N4lOIyct2Z](https://github.com/user-attachments/assets/9204b9ca-64de-4fdf-b96f-b4e47479f762)


## 3. Registrar un Nombre de Dominio

Usamos un proveedor gratuito de nombres de dominio como son Freenom o No-IP.
En nuestro caso lo hemos hecho a traves de No-IP, nos hemos registrado en la página web y hemos registrado un nombre de dominio con la IP pública del servidor.


   ![TwkcTIoiNE](https://github.com/user-attachments/assets/f66b4d80-4c6e-4251-a12c-26303bfdcc00)


## 4. Instalar Certbot y Configurar el Certificado SSL/TLS con Let’s Encrypt
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.5 y utilizaremos el script ``` setup_letsencrypt_certificate.sh ```.

[Practica-iaw-1.5](https://github.com/marinaferb92/practica-iaw-1.5)

[Script setup_letsencrypt_certificate.sh](scripts/setup_letsencrypt_certificate.sh)



# Instalación de WordPress en el directorio raíz de Apache
Tras los pasos anteriores y que se hayan ejecutado exitosamente los scripts ``` install_lamp.sh ``` y ``` setup_letsencrypt_certificate.sh ```, comenzaremos primero con el desarrollo del script para la instlación y configuración de Wordpress en el directorio raíz.

1. Cargamos el archivo de variables
   
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```


2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```


3. Descargamos el código fuente de WordPress.

Con el comando wget descargamos la última versión de WordPress en formato comprimido (.tar.gz) desde la URL oficial al directorio **/tmp.**

````

wget http://wordpress.org/latest.tar.gz -P /tmp

````


4. Borramos instalaciones previas de WordPress en el directorio de destino.

Eliminamos cualquier instalación previa de WordPress en el directorio /var/www/html, para que en caso de que ejecutemos el entorno este limpio y no haya conflictos.

````

rm -rf /var/www/html/*

````


5. Extraemos el archivo descargado.

Extraemos el archivo en el directorio /tmp. Con la opción f se specifica el nombre del archivo de entrada (/tmp/latest.tar.gz) y con la opción -C indicamos donde debe extrarse  el contenido **/tmp**.

````

tar -xzvf /tmp/latest.tar.gz -C /tmp

````


6. Movemos el contenido de WordPress al directorio de destino.

Movemos todos los archivos extraídos de **/tmp/wordpress** a **/var/www/html**, el directorio raíz de Apache. Con la opción -f (force) sobrescribimos cualquier archivo existente en el destino sin pedir confirmación.

````

mv -f /tmp/wordpress/* /var/www/html

````


7. Eliminamos los archivos temporales.

Eliminamos el archivo comprimido descargado y el directorio /tmp/wordpress después de haber movido los archivos, liberando espacio en el directorio /tmp.

````

rm -rf /tmp/latest.tar.gz /tmp/wordpress


````


8. Renombramos en archivo *wp-config-sample.php* como *wp-config.php*

Copiamos el archivo de configuración *wp-config-sample.php* y lo renombra a *wp-config.php*, ya que WordPress necesita un archivo llamado *wp-config.php* para funcionar. 

````

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

````


9. Creamos una base de datos.

**Configuramos la base de datos en MySQL usando comandos SQL enviados directamente a mysql. Cada línea tiene una función específica**:
-Eliminar la base de datos existente.
-Crear una nueva base de datos.
-Eliminar el usuario existente.
-Crear un nuevo usuario.
-Otorgar permisos al usuario.

Para esto deberemos configurar en el archivo ```` .env ```` las variables ```` WORDPRESS_DB_NAME, 
 WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD, IP_CLIENTE_MYSQL, WORDPRESS_DB_HOST````
````

mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

````


10. Configuramos el archivo de configuración de Wordpress

Usamos el editor de texto de lineas de comandos *sed* para buscar y reemplazar texto en el archivo wp-config.php. 

Cada comando sed reemplazará el texto que le indicamos con los valores que definiremos en .env:
-**Nombre de la base de datos**: Cambia *database_name_here* por el valor de *$WORDPRESS_DB_NAME*.
-**Nombre de usuario**: Cambia *username_here* por el valor de *$WORDPRESS_DB_USER*.
-**Contraseña**: Cambia *password_here* por el valor de *$WORDPRESS_DB_PASSWORD*.
-**Host de la base de datos**: Cambia *localhost* por el valor de *$WORDPRESS_DB_HOST*.

````

sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

````


11. Cambiar propietario y grupo del directorio.
    
Cambiamos el propietario y el grupo en el directorio /var/www/html a www-data, el usuario y grupo predeterminados para Apache, para que Apache tenga los permisos para acceder y manipular los archivos de WordPress.

````

chown -R www-data:www-data /var/www/html/

````

12. Habilitar el módulo mod_rewrite de Apache

HabilitaMOS el módulo *mod_rewrite* de Apache, para que WordPress maneje URL amigables

````
a2enmod rewrite
````

13. Reiniciar Apache para aplicar los cambios

````systemctl restart apache2````


14. Comprobaciones.

- Entramos con la IP o el nombre nuestro dominio desde un navegador a Wordpress, aqui Elegiremos el idioma en el que queremos que opere.

  ![mOgxWNK7gc](https://github.com/user-attachments/assets/7bb89909-9fcf-4c33-a1f0-a37ad214bf45)

- Después de esto estableceremos las credenciales de acceso

  ![G5MQKF7Fw5](https://github.com/user-attachments/assets/ccb7eeb9-c4f5-4767-8ef2-64c365839844)

- Tras esto ya podremos entrar desde el Login
  
  ![SOxzlFXYI2](https://github.com/user-attachments/assets/3d890bf9-40a4-475c-a650-512b140d65e3)

- Una vez dentro de Apache iremos a *Ajustes -> Enlaces permanentes*. Para que la URL sea más estética, para ello elegiremos la opción **Nombre de la entrada** 

  ![wf2ppX7aJA](https://github.com/user-attachments/assets/f09889ac-9f1a-4f86-88c1-2a05e4c8104d)

- Una vez hecho esto ya podriamos empezar a crear entradas.

  ![oT3kazv6d7](https://github.com/user-attachments/assets/d0a79338-d1fd-44b9-92d8-3e60f7faef37)



# Instalación de WordPress en un directorio propio
Al igual que con la *instalación de WordPress en el directorio raíz*, tras realizar los primeros pasos de ejecución de los scripts ``` install_lamp.sh ``` y ``` setup_letsencrypt_certificate.sh ```, comenzaremos con el desarrollo del script para la instalación y configuración de Wordpress, pero esta vez en un n un subdirectorio específico del servidor web.

Los pasos del 1 al 5 serán iguales que en el anterior script, por lo que podemos copiarlos.


1. Cargamos el archivo de variables
   
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```


2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```


3. Descargamos el código fuente de WordPress.

Con el comando wget descargamos la última versión de WordPress en formato comprimido (.tar.gz) desde la URL oficial al directorio **/tmp.**

````

wget http://wordpress.org/latest.tar.gz -P /tmp

````


4. Borramos instalaciones previas de WordPress en el directorio de destino.

Eliminamos cualquier instalación previa de WordPress en el directorio /var/www/html, para que en caso de que ejecutemos el entorno este limpio y no haya conflictos.

````

rm -rf /var/www/html/*

````


5. Extraemos el archivo descargado.

Extraemos el archivo en el directorio /tmp. Con la opción f se specifica el nombre del archivo de entrada (/tmp/latest.tar.gz) y con la opción -C indicamos donde debe extrarse  el contenido **/tmp**.

````

tar -xzvf /tmp/latest.tar.gz -C /tmp

````


6. Crear el directorio para la instalación de WordPress en el subdirectorio

Creamos un subdirectorio en /var/www/html para realizar la instalación de WordPress en una carpeta específica, usando el nombre que almacenaremos en el archivo ````.env```` en la variable *$WORDPRESS_DIRECTORY*. Este subdirectorio permite que WordPress se ejecute desde una URL en específico.


````

mkdir -p /var/www/html/$WORDPRESS_DIRECTORY

````


7. Mover el contenido de WordPress al directorio de destino

Movemos todos los archivos extraídos al subdirectorio de destino */var/www/html/$WORDPRESS_DIRECTORY*, asegurando que WordPress esté en el directorio que hemos definido.

````

mv -f /tmp/wordpress/* /var/www/html/$WORDPRESS_DIRECTORY

````


8. Copiar el archivo wp-config-sample.php y renombrarlo

Copiamos el archivo de configuración *wp-config-sample.php* y lo renombra a *wp-config.php*, ya que WordPress necesita un archivo llamado *wp-config.php* para funcionar. 

````

cp /var/www/html/$WORDPRESS_DIRECTORY/wp-config-sample.php /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

````


9. Crear la base de datos

**Configuramos la base de datos en MySQL usando comandos SQL enviados directamente a mysql. Cada línea tiene una función específica**:
-Eliminar la base de datos existente.
-Crear una nueva base de datos.
-Eliminar el usuario existente.
-Crear un nuevo usuario.
-Otorgar permisos al usuario.

Para esto deberemos configurar en el archivo ```` .env ```` las variables ```` WORDPRESS_DB_NAME, 
 WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD, IP_CLIENTE_MYSQL, WORDPRESS_DB_HOST````
````

mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

````


10. Configurar el archivo wp-config.php

Usamos el editor de texto de lineas de comandos *sed* para buscar y reemplazar texto en el archivo wp-config.php. 

Cada comando sed reemplazará el texto que le indicamos con los valores que definiremos en .env:
-**Nombre de la base de datos**: Cambia *database_name_here* por el valor de *$WORDPRESS_DB_NAME*.
-**Nombre de usuario**: Cambia *username_here* por el valor de *$WORDPRESS_DB_USER*.
-**Contraseña**: Cambia *password_here* por el valor de *$WORDPRESS_DB_PASSWORD*.
-**Host de la base de datos**: Cambia *localhost* por el valor de *$WORDPRESS_DB_HOST*.

````

sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

````


# Configurar WP_SITEURL y WP_HOME para el subdirectorio
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

# Copiar el archivo index.php al directorio principal
cp /var/www/html/$WORDPRESS_DIRECTORY/index.php /var/www/html

# Configurar el archivo index.php
sed -i "s#wp-blog-header.php#$WORDPRESS_DIRECTORY/wp-blog-header.php#" /var/www/html/index.php

# Configurar las claves de seguridad
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

# Configurar permisos
chown -R www-data:www-data /var/www/html/
chown -R www-data:www-data /var/www/html/$WORDPRESS_DIRECTORY/wp-content
chmod -R 755 /var/www/html/$WORDPRESS_DIRECTORY

# Habilitar el módulo mod_rewrite de Apache
a2enmod rewrite

# Reiniciar Apache
systemctl restart apache2












