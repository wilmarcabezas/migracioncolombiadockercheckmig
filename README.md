# Proceso para despliegue de aplicación Checkmig II en Docker.

## 📋 Tabla de Contenido.
- [Proceso para despliegue de aplicación Checkmig II en Docker.](#proceso-para-despliegue-de-aplicación-checkmig-ii-en-docker)
  - [📋 Tabla de Contenido](#-tabla-de-contenido)
  - [1. Archivo Dockerfile](#1-archivo-dockerfile)
  - [2. Dockerfile del proyecto](#2-dockerfile-del-proyecto)
  - [3. Subir imagen a Docker.hub](#3-subir-imagen-a-dockerhub)
  - [4. Creacion de Imagen](#4-creacion-de-imagen)
  - [5. Como crear la imagen a partir de una imagen existente en Docker.Hub](#5-como-crear-la-imagen-a-partir-de-una-imagen-existente-en-dockerhub)
  - [6. Configuracion de IPTABLES](#6-configuracion-de-iptables)
  - [7. Actualizar version](#7-actualizar-version)
  - [8. Agregar nuevo PCM](#8-agregar-nuevo-pcm)

## 1. <a name='dockerfile-del-proyecto'>Archivo Dockerfile</a>

Un archivo Dockerfile es un archivo de texto que contiene instrucciones y comandos para construir una imagen de Docker. Es utilizado por Docker para automatizar 
el proceso de creación de imágenes y la configuración del entorno dentro de un contenedor. El Dockerfile especifica qué software y dependencias se deben incluir 
en la imagen, así como cómo se deben configurar y ejecutar cuando se inicie un contenedor basado en esa imagen. En resumen, un Dockerfile proporciona una 
forma reproducible de definir y construir entornos de contenedor.
[https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/)

## 2. <a name='dockerfile-del-proyecto'>Dockerfile del proyecto</a>
```markdown


# Establece la imagen base para el contenedor Docker. En este caso, se utiliza la imagen ubi8/ubi de Red Hat.
FROM registry.access.redhat.com/ubi8/ubi:latest

# Ejecuta el comando dnf update en el contenedor, lo cual actualiza el sistema operativo 
# dentro del contenedor.
RUN dnf -y update

# Instala los paquetes nginx, net-tools, nano, dotnet-sdk-7.0, openssh y openssh-clients utilizando 
# el comando dnf install.
RUN dnf -y install nginx net-tools nano dotnet-sdk-7.0 openssh openssh-clients

# Copia el archivo startcheckmig-1.0.23086.23.sh al directorio /usr/share/nginx/html dentro del contenedor.
COPY startcheckmig-1.0.23086.23.sh /usr/share/nginx/html

# Cambia los permisos del archivo startcheckmig-1.0.23086.23.sh dentro del contenedor para 
# que tenga permisos de lectura, escritura y ejecución para todos los usuarios.
RUN chmod 777 /usr/share/nginx/html/startcheckmig-1.0.23086.23.sh

# Crea los directorios /usr/share/nginx/html/checkmig y /usr/share/nginx/html/checkmig/1.0.23086.23 dentro del contenedor.
RUN mkdir /usr/share/nginx/html/checkmig
RUN mkdir /usr/share/nginx/html/checkmig/1.0.23086.23

# Copia el contenido del directorio 1.0.23086.23 al directorio /usr/share/nginx/html/1.0.23086.23 dentro del contenedor.
COPY 1.0.23086.23 /usr/share/nginx/html/1.0.23086.23

# Crea el directorio /etc/nginx/ssl dentro del contenedor y copia los archivos ser.key, ser.pem y checkmig.conf 
# a los respectivos directorios dentro del contenedor.
RUN mkdir /etc/nginx/ssl
COPY ser.key /etc/nginx/ssl
COPY ser.pem /etc/nginx/ssl
COPY checkmig.conf /etc/nginx/conf.d

# Copia los archivos kestrel-checkmig-1.0.23086.23.service y deployCheckmig.sh a los directorios 
# /etc/systemd/system/ y /usr/share/nginx/html/, respectivamente, dentro del contenedor
COPY kestrel-checkmig-1.0.23086.23.service /etc/systemd/system/
COPY deployCheckmig.sh /usr/share/nginx/html/

# Cambia los permisos del archivo deployCheckmig.sh dentro del contenedor para que tenga permisos de lectura, 
escritura y ejecución para todos los usuarios.
RUN chmod 777 /usr/share/nginx/html/deployCheckmig.sh

# Habilita el servicio kestrel-checkmig-1.0.23086.23 utilizando el comando systemctl dentro del contenedor.
RUN systemctl enable kestrel-checkmig-1.0.23086.23

# EInician el servicio kestrel-checkmig-1.0.23086.23 y reinician el servicio nginx dentro del contenedor 
utilizando el comando systemctl.
RUN systemctl start kestrel-checkmig-1.0.23086.23
RUN systemctl restart nginx

# Expone el puerto 9090
EXPOSE 9090

# Establece el comando que se ejecutará cuando se inicie el contenedor, en este caso, el comando /sbin/init.
CMD ["/sbin/init"]

```

## 3. <a name='subir-imagen-a-docker-hub'>Subir imagen a Docker.hub</a>
Para subir una imagen a Docker Hub, puedes seguir los siguientes pasos:

  1. Primero, asegúrate de tener una cuenta en [Docker Hub](https://hub.docker.com/). 
     Si no tienes una, puedes crear una de forma gratuita.

  2. Construye la imagen de Docker que deseas subir en tu entorno local utilizando un archivo Dockerfile o cualquier otro método.

  3. Asegúrate de etiquetar la imagen con el nombre de usuario de Docker Hub y el nombre del repositorio al que deseas subir la imagen. 
     Por ejemplo, si tu nombre de usuario en Docker Hub es "ejemplo" y deseas 
     subir la imagen a un repositorio llamado "mi-aplicacion", debes etiquetar la imagen como `ejemplo/mi-aplicacion`.

  4. Inicia sesión en Docker Hub desde tu línea de comandos utilizando el siguiente comando: docker login
  5. Ingresa tus credenciales de Docker Hub cuando se te solicite.

5. Sube la imagen etiquetada a Docker Hub utilizando el siguiente comando: docker push ejemplo/mi-aplicacion

Esto enviará la imagen a tu repositorio en Docker Hub.

Recuerda que puedes consultar la [documentación oficial de Docker Hub](https://docs.docker.com/docker-hub/) para obtener 
más detalles sobre cómo subir una imagen a Docker Hub.


## 4. <a name='creación-de-imagen'>Creacion de Imagen</a>

   1. Descomprimimos el .zip checkmig.zip: 
     ``` unzip checkmig.zip  ```
     
   2. Entramos en la carpeta correspondiente:
      ``` cd netcore7build  ```
            
   3. Creamos la imagen: 
      ``` docker build -t checkmig . ```

   4. Iniciamos el contenedor (cambiar la imagen_id por el id de la iamgen): 
    ```  docker run -it -d -P --privileged=true image_id /sbin/init  ```

   5. Entramos en el contenedor (cambiar contenedor_id por el id de la contenedor) 
    ``` docker exec -ti contenedor_id /bin/bash ```

   6. Para reiniciar nginx:****
    ``` systemctl restart nginx ```
 
   7. Para iniciar o reiniciar kestrel-checkmig:
    ``` systemctl restart kestrel-checkmig-1.0.23086.23 ```

   8. Posible error: no se copia la carpeta 1.0.23086.23
      ``` cd /var/www/checkmig  ```
      ``` scp -r usuario@172.16.0.1:/netcore7/1.0.23086.23 .```


## 5. <a name='existente-en-dockerhub'>Como crear la imagen a partir de una imagen existente en Docker.Hub</a>

   Debido a la infraestructura de Migracion Colombia, no fue posible crear la imagen de docker a partir del Dockerfile.
   Ya que aunque finalmente permitio la descarga de paquetes, una vez se requiere descargar directamente desde el contenedor 
   se presenta un error, el cual se soluciona descargando y ejecutando la imagen previamente desplegada en [Docker Hub](https://hub.docker.com/).
      

   1. Utiliza el siguiente comando para descargar la imagen desde Docker Hub y ejecutar un contenedor basado en ella:  
     ``` docker run -it -d -P 9090:9090 --privileged=true username/nombreimagen:versioon /sbin/init ```
     
   2. Docker descargará automáticamente la imagen desde Docker Hub si no está presente en tu sistema local. Luego, iniciará un 
   3. contenedor basado en esa imagen.
      Si deseas obtener más información sobre cómo ejecutar imágenes en Docker, puedes consultar la 
      [documentación oficial de Docker](https://docs.docker.com/engine/reference/commandline/run/).


## 6. <a name='configuración-de-iptables'>Configuracion de IPTABLES</a>
     iptables -t nat -A PREROUTING -i eno3 -p tcp -d 172.20.3.172 --dport 9090 -j DNAT --to 172.17.0.5:9090 
    
  Este comando de iptables configura una regla de redirección de paquetes en la tabla "nat" (Network Address Translation) 
  del firewall de Linux.

   1. iptables: Es el comando para manipular las reglas del firewall en sistemas basados en Linux.
   2. -t nat: Especifica que se está trabajando con la tabla "nat" que maneja las reglas de traducción de direcciones de red.
   3. -A PREROUTING: Agrega una regla a la cadena PREROUTING. Esta cadena se aplica antes de que los paquetes sean ruteados.
   4. -i eno3: Especifica la interfaz de red de entrada por donde llegarán los paquetes.
   5. -p tcp: Especifica el protocolo TCP para los paquetes que coincidan con esta regla.
   6. -d 172.20.3.172: Establece la dirección de destino de los paquetes que coincidan con esta regla.
   7. --dport 9090: Especifica el puerto de destino al que deben llegar los paquetes.
   8. -j DNAT: Indica que los paquetes que coincidan con esta regla deben ser redireccionados.
   9. --to 172.17.0.5:9090: Especifica la dirección IP y el puerto al que se redirigirán los paquetes.

En resumen, este comando de iptables redirige los paquetes TCP que llegan a la interfaz de red "eno3" con dirección de destino 172.20.3.172 en el puerto 9090 hacia la dirección IP 172.17.0.5 en el puerto 9090.
  
## 7. <a name='actualizar'>Actualizar version</a>
      
  El proceso de actualizacion consiste basicamente en el reemplazo de los archivos resultado de la compilacion y en la ejecucion de unos cuantos comandos para poner a punto los servicios correspondiente.

  1. Copie la carpeta con la nueva version "<b>Fuente</b>" ubicada en el servidor <b>Host</b>.
     <br>Para copiar use el siguientecomando: <br>
     ``` docker cp FUENTE IDCONTENEDOR:/var/www/checkmig ```
  2. Para conocer el ID del contenedor ejecuta:<br>
     ``` docker ps -a ```
  3. Ingrese al contenedor y vaya a la carpeta de aplicacion: <br>
    ``` docker exec -ti IDCONTENEDOR/bin/bash ```<br>
    ``` cd /var/www/checkmig ```
  4. Detenga el kestrel y el nginx.<br>
     ``` systemctl stop kestrel-checkmig-1.0.23086.23 ```
     ``` systemctl stop nginx ```
  5. Cambie el nombre de la carpeta de produccion. (Agrege al final la fecha de cambio)<br>
     La carpeta oficial de la aplicacion es: <b>1.0.23086.23</b><br>
     ``` mv 1.0.23086.23 1.0.23086.23-20230626 ```
  6. Cambie el nombre de <b>Fuente</b> con el nombre <b>checkmig-1.0.23086.23</b><br>
     La carpeta oficial de la aplicacion es: <b>checkmig-1.0.23086.23</b><br>
     ``` mv fuente 1.0.23086.23 ```
  7. Cambie el nombre de <b>Fuente</b> con el nombre <b>checkmig-1.0.23086.23</b><br>
     La carpeta oficial de la aplicacion es: <b>checkmig-1.0.23086.23</b><br>
     ``` mv fuente 1.0.23086.23 ```
  8. Ingrese a la carpeta wwwroot/Rotativa y Copie los archivos <b>libwkhtmltox.so  wkhtmltopdf</b> ubicados en Rotativa/Linux a la carpeta Rotativa <br>
    ``` cp Linux/libwkhtmltox.so ```<br>
    ``` cp Linux/wkhtmltopdf ```
  9. Despues de copiar asigne permisos a los dos archivos copiados anteriormente.<br>
    ``` chmod 755 Linux/libwkhtmltox.so ```<br>
    ``` chmod 755 Linux/wkhtmltopdf ```
        10. Verifique que la seccion Config del archivo <b>appsettings.json</b> Tenga los datos correctos.<br>
        ```
        "Config": {
            "SmtpConfig": {
            "Host": "NOMBRE SERVIDOR",
            "Port": # PUERTO,
            "EnableSsl": TRUE OR FALSE,
            "Username": "NOMBRE DE LA CUENTA",
            "Password": "CLAVE SI APLICA"
            },
        ```
  10. Antes de iniciar la aplicacion, debe verificar el archivo  <b>nlog.config</b> para que guarde solo los LOGS necesarios "En nustro caso ERROR" .<br>
        ``` 
        <nlog xmlns="http://www.nlog-project.org/schemas/NLog.xsd"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            autoReload="true"
            internalLogLevel="Error"
            internalLogFile="${basedir}/logs/internal-nlog.txt">
        <rules>
            <logger name="*.ApplicationUser" minlevel="Error" writeTo="Redmine" />
            <logger name="*.ApplicationUser" minlevel="Error"  final="true" writeTo="passwordfile" />

            <!--All logs, including from Microsoft-->
            <logger name="*" minlevel="Error" writeTo="allfile" />

            <!--Skip non-critical Microsoft logs and so log only own logs-->
            <logger name="Microsoft.*" maxlevel="Error" final="true" /> <!-- BlackHole without writeTo -->

            <logger name="*" minlevel="Error" writeTo="ownFile-web" />
        </rules> ```
  11. Ahora ejecute los comandos para reiniciar la aplicacion:<br>
    
        ``` systemctl restart kestrel-checkmig-1.0.23086.23 ``` <br>
        ``` systemctl restart nginx ``` <br>

        ``` systemctl status kestrel-checkmig-1.0.23086.23 ``` <br>
        ``` systemctl status nginx ```
  
  12. Verifique el funcionamiento: https://apps.migracioncolombia.gov.co/pre-registro/ <br>
      <ul>
        <li>Acceso</li>
        <li>Datos de las listas</li>
        <li>Envio de email</li>
        <li>Envio del adjunto</li>
      </ul>

## 8. <a name='agregar-nuevo-pcm'>Agregar nuevo PCM</a>
     ```Environment=IdentificadoresPCM=1\x2c12\x2c13\x2c14\x2c15\x2c16\x2c18\x2c22\x2c50\x2c53\x2c57\x2c76\x2c77\x2c84\x2c94\x2c96```

      1. Dirijase al directorio /etc/systemd/system  
        ``` cd /etc/systemd/system ```
   2. Encuentre y abre el arcnivo: kestrel-checkmig-1.0.23086.23.service 
        ``` nano kestrel-checkmig-1.0.23086.23.service ```
   3. Encuentre la clave: Environment=IdentificadoresPCM y al final agregue el numero del PCM.
      Este debe ser agregado bajo el formato <b>x2c</b>numeroPCM
   4. Presione ctrl x y Enter para guardar.
   5. Ahora ejecute los comandos para reiniciar la aplicacion:<br>
    
        ``` systemctl restart kestrel-checkmig-1.0.23086.23 ``` <br>
        ``` systemctl restart nginx ``` <br>

        ``` systemctl status kestrel-checkmig-1.0.23086.23 ``` <br>
        ``` systemctl status nginx ```
