FROM open-liberty:kernel-slim-java17-openj9

RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

COPY --chown=1001:0 /src/main /usr/src/app
COPY --chown=1001:0 /src/main/liberty/config /config

WORKDIR /usr/src/app
RUN mvn clean package -DskipTests

RUN curl -o /config/postgresql-42.4.2.jar \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.4.2/postgresql-42.4.2.jar

COPY --chown=1001:0 target/*.war /config/apps

RUN features.sh
RUN configure.sh