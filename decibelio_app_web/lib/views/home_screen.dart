import 'package:decibelio_app_web/views/dashboard/components/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decibelio_app_web/views/navigation/navigation_bloc.dart';
import 'package:decibelio_app_web/views/subir_dato.dart';
import 'package:decibelio_app_web/views/sensor_create.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensores')),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: const Text('Mapa'),
              onTap: () {
                BlocProvider.of<NavigationBloc>(context).add(NavigateToMapPage());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Subir Datos'),
              onTap: () {
                BlocProvider.of<NavigationBloc>(context).add(NavigateToUploadPage());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Crear Sensor'),
              onTap: () {
                BlocProvider.of<NavigationBloc>(context).add(NavigateToSensorCreatePage());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<NavigationBloc, String>(
        builder: (context, state) {
          switch (state) {
            case '/upload':
              return SubirDatoControllerPage(title: "Second Screen",
                color: Colors.redAccent);
            case '/map':
              return AnimatedMapControllerPage();
            case '/sensor_create':
              return SensorCreateControllerPage(title: "Thirst Screen",
                color: Colors.greenAccent);
            default:
              return AnimatedMapControllerPage();
          }
        },
      ),
    );
  }
}
