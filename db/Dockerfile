FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y wget software-properties-common apt-transport-https
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# Crear directorio para scripts
RUN mkdir -p /scripts
COPY *.sql /scripts/

# Script de inicialización
COPY entrypoint.sh /scripts/
RUN chmod +x /scripts/entrypoint.sh

CMD /bin/bash /scripts/entrypoint.sh
