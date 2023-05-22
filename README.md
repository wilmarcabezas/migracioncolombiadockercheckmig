# Proceso para despliegue de aplicación Checkmig en Docker

## 1. Archivo Dockerfile

Un archivo Dockerfile es un archivo de texto que contiene instrucciones y comandos para construir una imagen de Docker. Es utilizado por Docker para automatizar el proceso de creación de imágenes y la configuración del entorno dentro de un contenedor. El Dockerfile especifica qué software y dependencias se deben incluir en la imagen, así como cómo se deben configurar y ejecutar cuando se inicie un contenedor basado en esa imagen. En resumen, un Dockerfile proporciona una forma reproducible de definir y construir entornos de contenedor.
[https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/)

```markdown


# Establece la imagen base para el contenedor Docker. En este caso, se utiliza la imagen ubi8/ubi de Red Hat.
FROM registry.access.redhat.com/ubi8/ubi:latest

# Ejecuta el comando dnf update en el contenedor, lo cual actualiza el sistema operativo dentro del contenedor.
RUN dnf -y update

# Instala los paquetes nginx, net-tools, nano, dotnet-sdk-7.0, openssh y openssh-clients utilizando el comando dnf install.
RUN dnf -y install nginx net-tools nano dotnet-sdk-7.0 openssh openssh-clients

# Copia el archivo startcheckmig-1.0.23086.23.sh al directorio /usr/share/nginx/html dentro del contenedor.
COPY startcheckmig-1.0.23086.23.sh /usr/share/nginx/html

# Cambia los permisos del archivo startcheckmig-1.0.23086.23.sh dentro del contenedor para que tenga permisos de lectura, escritura y ejecución para todos los usuarios.
RUN chmod 777 /usr/share/nginx/html/startcheckmig-1.0.23086.23.sh

# Crea los directorios /usr/share/nginx/html/checkmig y /usr/share/nginx/html/checkmig/1.0.23086.23 dentro del contenedor.
RUN mkdir /usr/share/nginx/html/checkmig
RUN mkdir /usr/share/nginx/html/checkmig/1.0.23086.23

# Copia el contenido del directorio 1.0.23086.23 al directorio /usr/share/nginx/html/1.0.23086.23 dentro del contenedor.
COPY 1.0.23086.23 /usr/share/nginx/html/1.0.23086.23

# Crea el directorio /etc/nginx/ssl dentro del contenedor y copia los archivos ser.key, ser.pem y checkmig.conf a los respectivos directorios dentro del contenedor.
RUN mkdir /etc/nginx/ssl
COPY ser.key /etc/nginx/ssl
COPY ser.pem /etc/nginx/ssl
COPY checkmig.conf /etc/nginx/conf.d

# Copia los archivos kestrel-checkmig-1.0.23086.23.service y deployCheckmig.sh a los directorios /etc/systemd/system/ y /usr/share/nginx/html/, respectivamente, dentro del contenedor
COPY kestrel-checkmig-1.0.23086.23.service /etc/systemd/system/
COPY deployCheckmig.sh /usr/share/nginx/html/

# Cambia los permisos del archivo deployCheckmig.sh dentro del contenedor para que tenga permisos de lectura, escritura y ejecución para todos los usuarios.
RUN chmod 777 /usr/share/nginx/html/deployCheckmig.sh

# Habilita el servicio kestrel-checkmig-1.0.23086.23 utilizando el comando systemctl dentro del contenedor.
RUN systemctl enable kestrel-checkmig-1.0.23086.23

# EInician el servicio kestrel-checkmig-1.0.23086.23 y reinician el servicio nginx dentro del contenedor utilizando el comando systemctl.
RUN systemctl start kestrel-checkmig-1.0.23086.23
RUN systemctl restart nginx

# Expone el puerto 9090
EXPOSE 9090

# Establece el comando que se ejecutará cuando se inicie el contenedor, en este caso, el comando /sbin/init.
CMD ["/sbin/init"]

```
