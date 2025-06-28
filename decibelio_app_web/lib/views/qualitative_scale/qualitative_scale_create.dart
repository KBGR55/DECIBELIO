import 'package:flutter/material.dart';
import 'package:decibelio_app_web/services/conexion.dart';

class QualitativeScaleCreatePage extends StatefulWidget {
  final int sensorId;

  const QualitativeScaleCreatePage({super.key, required this.sensorId});

  @override
  QualitativeScaleCreatePageState createState() => QualitativeScaleCreatePageState();
}

class QualitativeScaleCreatePageState extends State<QualitativeScaleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Conexion _con = Conexion();

  Future<void> _addQualitativeScale() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "name": _nameController.text,
        "description": _descriptionController.text,
      };

      final response = await _con.solicitudPost(
          'sensors/${widget.sensorId}/qualitativeScales', data, Conexion.noToken);

      if (!mounted) return;

      if (response.status == "SUCCESS") {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Éxito'),
            content: const Text('Escala cualitativa agregada correctamente'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Cierra formulario y dialogo
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar: ${response.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Escala Cualitativa'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (value) => value == null || value.isEmpty ? 'Ingresa una descripción' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addQualitativeScale,
              child: const Text('Agregar'),
            )
          ],
        ),
      ),
    );
  }
}
