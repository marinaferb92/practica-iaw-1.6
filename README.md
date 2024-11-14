# practica-iaw-1.6
#Instalación de WordPress en una instancia EC2 de AWS

##  1. Introducción
En esta practica explicaremos el proceso completo de instalación y configuración de WordPress en una instancia EC2 de Amazon Web Services (AWS). En primer lugar, se automatizará la configuración de una pila LAMP (Linux, Apache, MySQL y PHP) y después se realizará la instalación de WordPress en dos modalidades: en el directorio raíz y en un directorio específico.

## 2.Creacion de una instancia EC2 en AWS e instalacion de Pila LAMP
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.1 y utilizaremos el script ``` install_lamp.sh ```.

**Esta vez tenemos la siguiente IP elastica para nuestra maquina**

  ![bNabA1Ww5l](https://github.com/user-attachments/assets/ec67113e-343c-4890-8086-6d0cb5e3d4e9)

[Practica-iaw-1.1](https://github.com/marinaferb92/practica-iaw-1.1/tree/main)

[Script Install LAMP](https://github.com/marinaferb92/practica-iaw-1.1/blob/main/scripts/install_lamp.sh)



Una vez hecho esto nos aseguraremos de que la Pila LAMP esta funcionando correctamente.

- Verificaremos el estado de apache.

  ![MMA4oyDdYV](https://github.com/user-attachments/assets/ef998254-f5f8-4bc1-b702-0e41621b0844)


- Entramos en mysql desde la terminal para ver que esta corriendo.

  ![jYkXAri0jN](https://github.com/user-attachments/assets/c919d2a4-aaa8-4241-838d-698ef3685a2e)



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

  ![FkVfxaQAfg](https://github.com/user-attachments/assets/cd3b2621-6995-43df-aa14-bc9a371c4417)


- Después de esto estableceremos las credenciales de acceso

  ![G5MQKF7Fw5](https://github.com/user-attachments/assets/ccb7eeb9-c4f5-4767-8ef2-64c365839844)

- Tras esto ya podremos entrar desde el Login
  
  ![SOxzlFXYI2](https://github.com/user-attachments/assets/3d890bf9-40a4-475c-a650-512b140d65e3)

- Una vez dentro de Apache iremos a *Ajustes -> Enlaces permanentes*. Para que la URL sea más estética, para ello elegiremos la opción **Nombre de la entrada** 

  ![wf2ppX7aJA](https://github.com/user-attachments/assets/f09889ac-9f1a-4f86-88c1-2a05e4c8104d)

- Una vez hecho esto ya podriamos empezar a crear entradas.

  ![9Ag1rgu607](https://github.com/user-attachments/assets/77c22e9a-6726-44f9-b35d-619ba23d3c33)



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


11. Configurar WP_SITEURL y WP_HOME para el subdirectorio

Utilizamos *sed* para insertar las constantes ````WP_SITEURL y WP_HOME```` en el archivo *wp-config.php*, con ello configuramos la URL principal para que WordPress funcione desde el subdirectorio específico que hemos definido. Para ello tendremos que configurar en el archivo ```` .env ```` las variables ```` WP_SITEURL y WP_HOME````
WordPress utilizará esta URL para generar enlaces y redirigir visitas


````

sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

````



12. Copiar el archivo index.php al directorio principal
Copiamos *index.php* al directorio raíz de Apache, haciendo que las solicitudes a la URL principal se redirijan correctamente a la instalación de WordPress en el subdirectorio.

````
cp /var/www/html/$WORDPRESS_DIRECTORY/index.php /var/www/html
````


13. Configurar el archivo index.php

Reemplazamos la ruta original de *wp-blog-header.php* por la ruta correcta que apunte al subdirectorio especificado en la variable $WORDPRESS_DIRECTORY.
- **s#wp-blog-header.php#$WORDPRESS_DIRECTORY/wp-blog-header.php#** busca la cadena *wp-blog-header.php* en el archivo index.php y la reemplaza por */$WORDPRESS_DIRECTORY/wp-blog-header.php*.

Para ellos utiliza la variable  ````$WORDPRESS_DIRECTORY```` guardada en el archivo ```.env```.
Con esto aseguramos que WordPress funcione correctamente incluso cuando está instalado en un subdirectorio.

````
sed -i "s#wp-blog-header.php#$WORDPRESS_DIRECTORY/wp-blog-header.php#" /var/www/html/index.php
````


14. Configurar las claves de seguridad

- Descargamos claves de seguridad generadas aleatoriamente desde la API de WordPress.
- Reemplazamos cualquier **/** en las claves con **_** para evitar problemas con el formato.
- Insertamos las claves en *wp-config.php*

````

SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

````


15. Configurar permisos
Establecemos el usuario www-data de Apache como propietario del directorio y aseguramos acceso de lectura y escritura en todos los archivos necesarios.

```

chown -R www-data:www-data /var/www/html/
chown -R www-data:www-data /var/www/html/$WORDPRESS_DIRECTORY/wp-content
chmod -R 755 /var/www/html/$WORDPRESS_DIRECTORY

```

16. Habilitar el módulo mod_rewrite de Apache

HabilitaMOS el módulo *mod_rewrite* de Apache, para que WordPress maneje URL amigables

````
a2enmod rewrite
````

17. Reiniciar Apache para aplicar los cambios

````systemctl restart apache2````


18. **COMPROBACIONES**

- Entramos en Wordpress utilizando la IP  de la maquina o el nombre de dominio. 

  ![NzCeDM4DFx](https://github.com/user-attachments/assets/eb8fe5ff-44c4-47a5-a875-8ef4b3fa6c95)


- Después de esto estableceremos las credenciales de acceso

  ![ZvhCm6eMfb](https://github.com/user-attachments/assets/55cc07d9-c4df-482c-9205-81d54e61ffff)


- Una vez dentro de Apache iremos a *Ajustes -> Enlaces permanentes*. Para que la URL sea más estética, para ello elegiremos la opción **Nombre de la entrada** 

  ![33X1xPQtDp](https://github.com/user-attachments/assets/9030a7e3-c80f-4f28-b82c-26373172a55d)


- Una vez hecho esto ya podriamos empezar a crear entradas. Como vemos la URL de la pagina incluye el directorio que habiamos definido (https://practicahttpsmfb.ddns.net/wordpress/entrada-de-prueba/)

  ![Up6ZLjrfvt](https://github.com/user-attachments/assets/e040fc46-3b69-4d7a-9ef2-899a04481a44)








