FROM tifayuki/java:7
MAINTAINER Feng Honglin <hfeng@tutum.co>

ENV http_proxy="http://web-proxy.ind.hp.com:8080/"
RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.55
ENV CATALINA_HOME /tomcat
ENV HTTP_PROXY "http://web-proxy.ind.hp.com:8080/"
ENV HTTPS_PROXY "https://web-proxy.ind.hp.com:8080/"
ENV FTP_PROXY "ftp://web-proxy.ind.hp.com:8080/"


# INSTALL TOMCAT
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh



#EXPOSE 8080

#CMD ["/run.sh"]
CMD ["/tomcat/bin/catalina.sh","run"]

