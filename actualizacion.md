## <a name='actualizar'>Actualizar version</a>
      
  El proceso de actualizacion consiste basicamente en el reemplazo de los archivos resultado de la compilacion y en la ejecucion de unos cuantos comandos para poner a punto los servicios correspondiente.

  1. Copie la carpeta con la nueva version "<b>Fuente</b>" ubicada en el servidor <b>Host</b>.
     <br>Para copiar use el siguientecomando: <br>
     ``` docker cp FUENTE IDCONTENEDOR:/var/www/checkmig ```    
     <br>

  3. Para conocer el ID del contenedor ejecuta:<br>
     ``` docker ps -a ``` <br>
     <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/2.png'><br>

  5. Ingrese al contenedor y vaya a la carpeta de aplicacion: <br>
    ``` docker exec -ti IDCONTENEDOR/bin/bash ```<br>
    ``` cd /var/www/checkmig ``` <br>
    <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/3.png'><br>

  6. Detenga el kestrel y el nginx.<br>
     ``` systemctl stop kestrel-checkmig-1.0.23086.23 ```
     ``` systemctl stop nginx ```
     <br>

  7. Cambie el nombre de la carpeta de produccion. (Agrege al final la fecha de cambio)<br>
     La carpeta oficial de la aplicacion es: <b>1.0.23086.23</b><br>
     ``` mv 1.0.23086.23 1.0.23086.23-20230626 ```<br>
     <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/4.png'><br>

  8. Cambie el nombre de <b>Fuente</b> con el nombre <b>checkmig-1.0.23086.23</b><br>
     La carpeta oficial de la aplicacion es: <b>checkmig-1.0.23086.23</b><br>
     ``` mv fuente 1.0.23086.23 ```<br>

  9. Cambie el nombre de <b>Fuente</b> con el nombre <b>checkmig-1.0.23086.23</b><br>
     La carpeta oficial de la aplicacion es: <b>checkmig-1.0.23086.23</b><br>
     ``` mv fuente 1.0.23086.23 ```<br>
      <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/5.png'><br>
  10. Ingrese a la carpeta wwwroot/Rotativa y Copie los archivos <b>libwkhtmltox.so  wkhtmltopdf</b> ubicados en Rotativa/Linux a la carpeta Rotativa <br>
    ``` cp Linux/libwkhtmltox.so ```<br>
    ``` cp Linux/wkhtmltopdf ``` <br>
    <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/6.png'><br>

  11. Despues de copiar asigne permisos a los dos archivos copiados anteriormente.<br>
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
  12. Antes de iniciar la aplicacion, debe verificar el archivo  <b>nlog.config</b> para que guarde solo los LOGS necesarios "En nustro caso ERROR" .<br>
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
        </rules>  
        ``` 
        <br>
        <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/7.png'>
        
  13. Ahora ejecute los comandos para reiniciar la aplicacion:<br>
    
        ``` systemctl restart kestrel-checkmig-1.0.23086.23 ``` <br>
        ``` systemctl restart nginx ``` <br>

        ``` systemctl status kestrel-checkmig-1.0.23086.23 ``` <br>
        ``` systemctl status nginx ```
  
  14. Verifique el funcionamiento: https://apps.migracioncolombia.gov.co/pre-registro/ <br>
      <ul>
        <li>Acceso</li>
        <li>Datos de las listas</li>
        <li>Envio de email</li>
        <li>Envio del adjunto</li>
      </ul>
      <br>
      <img src='https://migraciondata.interactuemos.com/actualizacioncheckmig/8.png'>
