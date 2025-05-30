import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class Conexion {
  final String name = "conexion";
  //static final String urlBase = dotenv.env['URL_BASE'] ?? '';
  static final String urlBase = 'http://localhost:9080/decibelio/api/';
  static String noToken = "NO";

  Future<RespuestaGenerica> solicitudPost(
      String dirRecurso, Map<dynamic, dynamic> data, String token) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    if (token != noToken) {
      header = {'Content-Type': 'application/json'};
    }
    final String url = "$urlBase$dirRecurso";
    final uri = Uri.parse(url);
    try {
      final response =
          await http.post(uri, headers: header, body: jsonEncode(data));
     if (response.statusCode == 200 || response.statusCode == 201) {
        return _responseJson(
            'SUCCESS',
            response.body,
            jsonDecode(response.body)['message'] ?? "No data",
            jsonDecode(response.body)['type'] ?? "No data");
      } else {
        return _responseJson('FAILURE', response.body, "No data", 'No data');
      }
    } catch (e) {
      Map<dynamic, dynamic> mapa = {"payload": e.toString()};
      return _responseJson(
          'FAILURE', jsonEncode(mapa), "Hubo un error", 'No data');
    }
  }

  Future<RespuestaGenerica> solicitudPut(
      String dirRecurso, Map<dynamic, dynamic> data, String token) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    if (token != noToken) {
      header = {'Content-Type': 'application/json'};
    }
    final String url = "$urlBase$dirRecurso";
    final uri = Uri.parse(url);
    try {
      final response =
      await http.put(uri, headers: header, body: jsonEncode(data));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _responseJson(
            'SUCCESS',
            response.body,
            jsonDecode(response.body)['message'] ?? "No data",
            jsonDecode(response.body)['type'] ?? "No data");
      } else {
        return _responseJson('FAILURE', response.body, "No data", 'No data');
      }
    } catch (e) {
      Map<dynamic, dynamic> mapa = {"payload": e.toString()};
      return _responseJson(
          'FAILURE', jsonEncode(mapa), "Hubo un error", 'No data');
    }
  }

  Future<RespuestaGenerica> solicitudPatch(
      String dirRecurso, Map<dynamic, dynamic>? data, String token) async {
    Map<String, String> header = {'Content-Type': 'application/json', 'accept': '*/*'};
    if (token != noToken) {
      header = {'Content-Type': 'application/json', 'accept': '*/*'};
    }
    final String url = "$urlBase$dirRecurso";
    final uri = Uri.parse(url);
    try {
      final response =
      await http.patch(uri, headers: header, body: jsonEncode(data));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _responseJson(
            'SUCCESS',
            response.body,
            jsonDecode(response.body)['message'] ?? "No data",
            jsonDecode(response.body)['type'] ?? "No data");
      } else {
        return _responseJson('FAILURE', response.body, "No data", 'No data');
      }
    } catch (e) {
      Map<dynamic, dynamic> mapa = {"payload": e.toString()};
      return _responseJson(
          'FAILURE', jsonEncode(mapa), "Hubo un error", 'No data');
    }
  }

  Future<RespuestaGenerica> solicitudGet(
      String dirRecurso, String token) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    if (token != noToken) {
      header = {'Content-Type': 'application/json'};
    }
    final String url = "$urlBase$dirRecurso";
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri, headers: header);
      if (response.statusCode != 200) {
        return _responseJson(
            'FAILURE',
            response.body,
            jsonDecode(response.body)['message'] ?? "No data",
            jsonDecode(response.body)['type'] ?? "No data");
      } else {
        return _responseJson(
            'SUCCESS',
            response.body,
            jsonDecode(response.body)['message'] ?? "OK",
            jsonDecode(response.body)['type'] ?? "No data");
      }
    } catch (e) {
      Map<dynamic, dynamic> mapa = {"payload": e.toString()};
      return _responseJson(
          'FAILURE', jsonEncode(mapa), "Hubo un error", 'No data');
    }
  }

  RespuestaGenerica _responseJson(
      String status, dynamic data, String msg, String type) {
    var respuesta = RespuestaGenerica();
    respuesta.status = status;
    respuesta.message = msg;
    respuesta.payload = data;
    respuesta.type = type;
    return respuesta;
  }
}
