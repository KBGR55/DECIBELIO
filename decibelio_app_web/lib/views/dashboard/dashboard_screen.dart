import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/dashboard/components/map_view.dart';
import 'package:decibelio_app_web/views/dashboard/components/sensor_details.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';
import 'components/max_levels_table.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            /**Align(
              alignment: Alignment.centerRight, // Alineación a la izquierda
              child: Switch(
                  value:
                  AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
                  activeThumbImage:
                  new AssetImage('assets/images/sun-svgrepo-com.png'),
                  inactiveThumbImage: new AssetImage(
                      'assets/images/moon-stars-svgrepo-com.png'),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.amber,
                  inactiveThumbColor: Colors.black,
                  inactiveTrackColor: Colors.white,
                  onChanged: (bool value) {
                    if (value) {
                      AdaptiveTheme.of(context).setLight();
                    } else {
                      AdaptiveTheme.of(context).setDark();
                    }
                  }),
            ),*/
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MapView(),
                      SizedBox(height: defaultPadding),
                      // Asegúrate de que RecentFiles esté habilitado para evitar problemas
                      const NoiseLevelTable(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) SensorDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: SensorDetails(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
