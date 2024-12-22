FROM open-liberty:kernel-slim-java17-openj9

# Cambiar a usuario root para ejecutar comandos que requieren permisos elevados
USER root
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Cambiar de nuevo al usuario no raíz predeterminado si es necesario
USER 1001

# Copiar la aplicación al contenedor
COPY --chown=1001:0 /src/main /usr/src/app
WORKDIR /usr/src/app

# Construir la aplicación con Maven
RUN mvn package

# Configurar y desplegar la aplicación
COPY --chown=1001:0 /src/main/liberty/config /config
RUN features.sh

COPY --chown=1001:0 target/*.war /config/apps
RUN configure.sh
