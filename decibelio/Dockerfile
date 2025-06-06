#FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi
FROM open-liberty:kernel-slim-java17-openj9

# Argumento con valor por defecto
ARG ENV_DRIVER_JDBC_DIR=./target/lib/*.jar
# Add config, app and jdbc driver
COPY --chown=1001:0 /src/main/liberty/config /config
#Funcionando con docker-compose
COPY --chown=1001:0 ${ENV_DRIVER_JDBC_DIR} /config/
#COPY --chown=1001:0 ./target/lib/*.jar /config/
RUN features.sh

COPY --chown=1001:0 target/*.war /config/apps
RUN configure.sh