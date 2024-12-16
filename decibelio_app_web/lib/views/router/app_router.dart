import 'package:decibelio_app_web/views/dashboard/dashboard_screen.dart';
import 'package:decibelio_app_web/views/main/main_screen.dart';
import 'package:decibelio_app_web/views/sensor_create/components/sensor_create.dart';
import 'package:decibelio_app_web/views/sensor_create/sensor_screen.dart';
import 'package:decibelio_app_web/views/upload_data/components/upload_data.dart';
import 'package:decibelio_app_web/views/upload_data/upload_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    final Object? key = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => MainScreen(
            title: "Dashboard",
            color: Colors.redAccent,
          ),
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => MainScreen(
            title: "Dashboard",
            color: Colors.redAccent,
          ),
        );
      case '/upload_data':
        return MaterialPageRoute(
          builder: (_) => UploadScreen(title: "upload", color: Colors.white70),
        );
      case '/create_sensor':
        return MaterialPageRoute(
          builder: (_) => const SensorScreen(
            title: "Create Sensor",
            color: Colors.greenAccent,
          ),
        );
      default:
        return null;
    }
  }
}