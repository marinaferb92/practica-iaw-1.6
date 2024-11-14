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
