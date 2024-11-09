# Usa una imagen base más ligera
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias, incluyendo git y xz-utils
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget unzip git xz-utils libstdc++6 libglu1-mesa fonts-droid-fallback python3 ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Variables de entorno de Flutter
ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Descargar y extraer Flutter SDK
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.0-stable.tar.xz && \
    tar -xf flutter_linux_3.7.0-stable.tar.xz -C /usr/local && \
    rm flutter_linux_3.7.0-stable.tar.xz

# Configurar Flutter como directorio seguro para git
RUN git config --global --add safe.directory /usr/local/flutter

# Ejecutar flutter doctor
RUN /usr/local/flutter/bin/flutter doctor

# Habilitar soporte para Flutter web
RUN /usr/local/flutter/bin/flutter channel master && \
    /usr/local/flutter/bin/flutter upgrade && \
    /usr/local/flutter/bin/flutter config --enable-web

# Copiar archivos y construir la aplicación
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Construir aplicación web
RUN /usr/local/flutter/bin/flutter build web

# Exponer el puerto
EXPOSE 9000

# Hacer el script ejecutable y lanzar el servidor
RUN ["chmod", "+x", "/app/server/server.sh"]

ENTRYPOINT ["/app/server/server.sh"]