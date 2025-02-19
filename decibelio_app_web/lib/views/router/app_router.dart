import 'package:decibelio_app_web/views/main/main_screen.dart';
import 'package:decibelio_app_web/views/sensor_create/sensor_screen.dart';
import 'package:decibelio_app_web/views/upload_data/upload_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MainScreen(
            title: "Dashboard",
            color: Colors.redAccent,
          ),
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const MainScreen(
            title: "Dashboard",
            color: Colors.redAccent,
          ),
        );
      case '/upload_data':
        return MaterialPageRoute(
          builder: (_) => const UploadScreen(title: "upload", color: Colors.white70),
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