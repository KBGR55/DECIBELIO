# Usa una imagen base más ligera
FROM debian:bullseye-slim

# Configura el entorno no interactivo para evitar prompts durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza e instala las dependencias necesarias, incluyendo certificados
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget unzip git xz-utils libstdc++6 libglu1-mesa fonts-droid-fallback \
    python3 ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Configura las URLs de Flutter en caso de restricciones de red
ENV PUB_HOSTED_URL=https://pub.dev
ENV FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

# Descarga y extrae el SDK de Flutter
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.0-stable.tar.xz && \
    tar -xf flutter_linux_3.7.0-stable.tar.xz -C /usr/local && \
    rm flutter_linux_3.7.0-stable.tar.xz

# Configura Flutter como directorio seguro para git
RUN git config --global --add safe.directory /usr/local/flutter

# Ejecuta `flutter doctor` para validar la instalación
RUN /usr/local/flutter/bin/flutter doctor

# Habilita el soporte para Flutter Web
RUN /usr/local/flutter/bin/flutter channel stable && \
    /usr/local/flutter/bin/flutter upgrade && \
    /usr/local/flutter/bin/flutter config --enable-web

# Copia los archivos del proyecto y define el directorio de trabajo
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Ejecuta `flutter pub get` para descargar las dependencias del proyecto
RUN /usr/local/flutter/bin/flutter pub get

# Construye la aplicación web de Flutter
RUN /usr/local/flutter/bin/flutter build web

# Expone el puerto para la aplicación web
EXPOSE 9000

# Da permisos de ejecución al script del servidor y lo define como punto de entrada
RUN ["chmod", "+x", "/app/server/server.sh"]
ENTRYPOINT ["/app/server/server.sh"]