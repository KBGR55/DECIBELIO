class RespuestaGenerica{
  String status = '';
  String message = '';
  String type = '';
  dynamic payload = '';
  RespuestaGenerica({this.status='', this.message='', this.type='', this.payload});
  factory RespuestaGenerica.fromJson(Map<String, dynamic> json) {
    return RespuestaGenerica(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      payload: json['payload'],
    );
  }
}