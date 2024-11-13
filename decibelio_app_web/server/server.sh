#!/bin/bash

# Definir el puerto
PORT=9000

# Comprobar si el puerto está en uso y liberarlo si es necesario
echo "Comprobando si el puerto $PORT está en uso..."
if [ "$(lsof -t -i :$PORT)" ]; then
  echo "El puerto $PORT está en uso. Deteniendo el proceso en ese puerto..."
  fuser -k -n tcp $PORT
fi

# Cambiar al directorio de construcción web
cd /app/build/web/

# Iniciar el servidor web con CORS habilitado
echo "Iniciando el servidor en el puerto $PORT con CORS habilitado..."

# Script Python personalizado para habilitar CORS
python3 -m http.server $PORT --bind 0.0.0.0 --directory /app/build/web/ &
PID=$!

# Habilitar CORS usando un servidor simple en Python
python3 -c "
import http.server
import socketserver
import json

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')  # Permite todos los orígenes
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')  # Métodos permitidos
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')  # Cabeceras permitidas
        super().end_headers()

# Crear el servidor
PORT = 9000
Handler = CORSHTTPRequestHandler
httpd = socketserver.TCPServer(("", PORT), Handler)

# Iniciar el servidor
print(f"Servidor iniciado en el puerto {PORT}")
httpd.serve_forever()
" &

wait $PID
