import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:decibelio_app_web/models/RespuestaGenerica.dart';
class conexion  {
  final String NAME = "conexion";
  final String URL_BASE = "http://localhost:9081/decibelio/api/";
  static String NO_TOKEN = "NO";

  Future<RespuestaGenerica> solicitudPost(String dir_recurso, Map<dynamic, dynamic> data,String token) async{
    log("${this.NAME}:Solicitud en Post");
    Map<String, String> _header = {'Content-Type':'application/json'};
    if(token != NO_TOKEN){
      _header = {'Content-Type':'applicaion/json', 'x-api-token': token};
    }
    final String url = URL_BASE+dir_recurso;
    final uri = Uri.parse(url);
    try{
      final response = await http.post(uri, headers: _header, body: jsonEncode(data));
      log(response.body);
      log(response.statusCode.toString());
      if(response.statusCode != 201){
        return _responseJson('FAILURE', response.body, "No data",'No data');
      }else{
        return _responseJson('SUCCESS', response.body, "Ok",'No data');
      }
    }catch(e){
      Map<dynamic, dynamic> mapa = {"payload": e.toString()};
      return _responseJson('FAILURE', jsonEncode(mapa), "Hubo un error",'No data');
    }
  }
  
  Future<RespuestaGenerica> solicitudGet(String dir_recurso, String token) async{
    Map<String, String> _header = {'Content-Type':'application/json'};
    if(token != NO_TOKEN){
      _header = {'Content-Type':'applicaion/json', 'x-api-token': token};
    }
    final String url = URL_BASE+dir_recurso;
    final uri = Uri.parse(url);
    log(url);
    try{
      final response = await http.get(uri, headers: _header);
      log(response.body);
    log(response.statusCode.toString());
      if(response.statusCode != 200){
        return _responseJson('FAILURE', response.body, "No data",'No data');
      }else{
         return _responseJson('SUCCESS', response.body, "Ok",'No data');
      }
    }catch(e){
      Map<dynamic, dynamic> mapa = {"payload": e.toString()};
      return _responseJson('FAILURE', jsonEncode(mapa), "Hubo un error",'No data');
    }
  }

  RespuestaGenerica _responseJson(String status, dynamic data, String msg, String type) {
    var respuesta = RespuestaGenerica();
    respuesta.status = status;
    respuesta.message = msg;
    respuesta.payload = data;
    respuesta.type = type;
    return respuesta;
  }
}

