import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/main/components/side_menu.dart';
import 'package:decibelio_app_web/views/sensor_create/components/sensor_create.dart';
import 'package:flutter/material.dart';

class SensorScreen extends StatelessWidget {
  final String title;
  final Color color;

  const SensorScreen({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (newContext) {
        return Scaffold(
          //key: newContext.read<MenuAppController>().scaffoldKey,
          drawer: SideMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  Expanded(
                    child: SideMenu(),
                  ),
                const Expanded(
                  flex: 5,
                  child: SensorCreateControllerPage(
                    title: "Create Sensor",
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

