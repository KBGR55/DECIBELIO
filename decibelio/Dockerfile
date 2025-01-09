#FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi
FROM open-liberty:kernel-slim-java17-openj9

# Add config, app and jdbc driver
COPY --chown=1001:0 /src/main/liberty/config /config
#Funcionando con docker-compose
COPY --chown=1001:0 target/liberty/wlp/usr/servers/defaultServer/lib/global/postgresql-42.4.2.jar /config/
RUN features.sh

COPY --chown=1001:0 target/*.war /config/apps
RUN configure.sh