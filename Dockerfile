FROM registry.access.redhat.com/ubi8/ubi:latest
RUN dnf -y update
RUN dnf -y install nginx net-tools nano dotnet-sdk-7.0 openssh openssh-clients

#checkmig
#COPY startcheckmig-1.0.23086.23.sh /var/www
COPY startcheckmig-1.0.23086.23.sh /usr/share/nginx/html
RUN chmod 777 /usr/share/nginx/html/startcheckmig-1.0.23086.23.sh
RUN mkdir /usr/share/nginx/html/checkmig
RUN mkdir /usr/share/nginx/html/checkmig/1.0.23086.23
COPY 1.0.23086.23 /usr/share/nginx/html/1.0.23086.23

#Configuracion nginx
RUN mkdir /etc/nginx/ssl
COPY ser.key /etc/nginx/ssl
COPY ser.pem /etc/nginx/ssl
COPY checkmig.conf /etc/nginx/conf.d

#systemd
COPY kestrel-checkmig-1.0.23086.23.service /etc/systemd/system/
COPY deployCheckmig.sh /usr/share/nginx/html/
RUN chmod 777 /usr/share/nginx/html/deployCheckmig.sh
RUN systemctl enable kestrel-checkmig-1.0.23086.23

RUN systemctl start kestrel-checkmig-1.0.23086.23
RUN systemctl restart nginx
expose 9090

## for apt to be noninteractive
#ENV DEBIAN_FRONTEND noninteractive
#ENV DEBCONF_NONINTERACTIVE_SEEN true
#STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]
