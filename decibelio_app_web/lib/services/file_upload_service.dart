import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:decibelio_app_web/models/RespuestaGenerica.dart';
import 'package:decibelio_app_web/services/conexion.dart';

class FileUploadService {
  final String URL_BASE = conexion.URL_BASE+"metrics/upload";

  // Método para subir un archivo al servidor
  Future<RespuestaGenerica> uploadFile(html.File file) async {
    try {
      // Crear un objeto FormData y añadir el archivo
      var formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      // Crear una solicitud HTTP
      var request = html.HttpRequest();
      request.open('POST', URL_BASE);

      // Crear un completer para manejar la respuesta asíncrona
      var completer = Completer<RespuestaGenerica>();

      // Escuchar el evento de carga completada
      request.onLoad.listen((event) {
        try {
          // Parsear la respuesta del servidor
          var jsonResponse = jsonDecode(request.responseText!);
          var respuesta = RespuestaGenerica.fromJson(jsonResponse);
          completer.complete(respuesta); // Completar con la respuesta
        } catch (e) {
          // Manejar errores de parseo
          completer.completeError(RespuestaGenerica(
              status: 'FAILURE',
              message: 'Error parsing server response: $e',
              type: 'ParseError'
          ));
        }
      });

      // Escuchar el evento de error
      request.onError.listen((event) {
        // Manejar errores de red
        completer.completeError(RespuestaGenerica(
            status: 'FAILURE',
            message: 'Error uploading file: Network error',
            type: 'NetworkError'
        ));
      });

      // Enviar la solicitud con el FormData
      request.send(formData);

      // Devolver el future que será completado con la respuesta
      return completer.future;
    } catch (e) {
      // Manejar excepciones durante el proceso de subida
      return Future.value(RespuestaGenerica(
          status: 'FAILURE',
          message: 'Exception during file upload: $e',
          type: 'UploadException'
      ));
    }
  }
}
