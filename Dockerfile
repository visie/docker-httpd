FROM visie/debian
MAINTAINER Evandro Franco de Oliveira Rui <evandro@visie.com.br>
ENV APACHE_LOCK_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2/httpd.pid
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
RUN apt-get update && apt-get install -y apache2
RUN rm -rf /etc/apache2
RUN rm -rf /var/log/apache2 && mkdir -p /var/log/apache2
RUN rm -rf /var/run/apache2 && mkdir -p /var/run/apache2
RUN ln -sf /dev/stdout -T ${APACHE_LOG_DIR}/error.log
COPY apache2 /etc/apache2
COPY entrypoint.sh /
EXPOSE 3306
