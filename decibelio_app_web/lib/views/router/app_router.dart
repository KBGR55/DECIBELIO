import 'package:decibelio_app_web/views/dashboard/components/map.dart';
import 'package:decibelio_app_web/views/main/main_screen.dart';
import 'package:decibelio_app_web/views/sensor_create.dart';
import 'package:decibelio_app_web/views/subir_dato.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    final Object? key = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => MainScreen(),
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => SubirDatoControllerPage(
            title: "Upload Data",
            color: Colors.redAccent,
          ),
        );
      case '/third':
        return MaterialPageRoute(
          builder: (_) => const SensorCreateControllerPage(
            title: "Create Sensor",
            color: Colors.greenAccent,
          ),
        );
      default:
        return null;
    }
  }
}