import 'dart:convert';
import 'dart:html' as html;
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/views/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:decibelio_app_web/services/file_upload_service.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class SubirDatoControllerPage extends StatefulWidget {
  const SubirDatoControllerPage(
      {super.key, required this.title, required this.color});

  final String title;
  final Color color;

  @override
  SubirDatoState createState() => SubirDatoState();
}

class SubirDatoState extends State<SubirDatoControllerPage> {
  GlobalKey<ScaffoldState> sensorDataScreenKey = GlobalKey<ScaffoldState>();
  String? _fileName;
  html.File? _file;
  late DropzoneViewController controller;
  bool _isUploading = false;
  String _uploadStatus = '';
  dynamic _payload; // Variable para almacenar el payload en caso de error

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const Header(),
              AlertDialog(
                title: const Text("Ingresar archivo con medidas de sensores"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            DropzoneView(
                              onCreated: (controller) =>
                                  this.controller = controller,
                              onDropFile: _handleFileDrop,
                            ),
                            if (_fileName == null)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_upload,
                                      size: 50, color: Colors.black38),
                                  const SizedBox(height: 10),
                                  const Text("Arrastra y suelta archivos aquí",
                                      style: TextStyle(color: Colors.black38)),
                                  const Text("o",
                                      style: TextStyle(color: Colors.black38)),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black54,
                                    ),
                                    onPressed: _pickFile,
                                    child: const Text("Subir archivo"),
                                  ),
                                ],
                              )
                            else
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.insert_drive_file,
                                      size: 50, color: Colors.blue),
                                  const SizedBox(height: 10),
                                  Text(_fileName!,
                                      style: const TextStyle(color: Colors.blue)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                        ),
                                        onPressed: _pickFile,
                                        child: const Text("Cambiar archivo"),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text("Limpiar"),
                                        onPressed: () {
                                          setState(() {
                                            _fileName = null;
                                            _file = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isUploading) const CircularProgressIndicator(),
                      if (_uploadStatus.isNotEmpty)
                        if (_payload != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('ERROR: Descargar información'),
                            onPressed: () => _downloadAdditionalInfo(_payload),
                          ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                        onPressed: _file != null && !_isUploading
                            ? () => _showConfirmationDialog(context)
                            : null,
                        child: const Text("Subir"),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                    ),
                    child: const Text("Cerrar"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              )
            ],
          )),
    );
  }

  /// Selecciona un archivo utilizando FilePicker.
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final bytes = result.files.single.bytes;
      final name = result.files.single.name;

      if (bytes != null) {
        setState(() {
          _fileName = name;
          _file = html.File(
              [bytes],
              name,
              {
                'type':
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
              });
        });
      } else {
        debugPrint('Error: No se pudieron obtener los bytes del archivo');
      }
    }
  }

  /// Maneja la caída de archivos en la zona de Dropzone.
  void _handleFileDrop(dynamic event) async {
    final name = await controller.getFilename(event);
    final mime = await controller.getFileMIME(event);
    final bytes = await controller.getFileData(event);

    setState(() {
      _fileName = name;
      _file = html.File([bytes], name, {'type': mime});
    });
  }

  /// Muestra un cuadro de diálogo de confirmación antes de subir el archivo.
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text("¿Estás seguro de que quieres subir este archivo?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
                _uploadFile();
              },
            ),
          ],
        );
      },
    );
  }

  /// Sube el archivo al servidor utilizando el servicio FileUploadService.
void _uploadFile() async {
  if (!mounted) return; 

  setState(() {
    _isUploading = true;
    _uploadStatus = 'Subiendo archivo...';
  });

  try {
    final fileUploadService = FileUploadService();
    RespuestaGenerica respuesta = await fileUploadService.uploadFile(_file!);

    if (!mounted) return; 
    setState(() {
      _uploadStatus = '${respuesta.status}: ${respuesta.message}';
      if (respuesta.status == 'SUCCESS') {
        _fileName = null;
        _file = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo cargado con éxito')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        debugPrint('Error details: ${respuesta.type}');
        _payload = respuesta.payload;
      }
    });
  } catch (e) {
    if (mounted) {
      setState(() {
        _uploadStatus = 'Error inesperado: $e';
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }
}

  /// Descarga información adicional como un archivo JSON.
  void _downloadAdditionalInfo(dynamic payload) {
    // Convertir el payload a una cadena JSON
    String jsonPayload = jsonEncode(payload);

    // Crear un Blob con el contenido JSON
    final bytes = utf8.encode(jsonPayload);
    final blob = html.Blob([bytes]);

    // Crear una URL para el Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Limpiar la URL del objeto
    html.Url.revokeObjectUrl(url);
  }
}
