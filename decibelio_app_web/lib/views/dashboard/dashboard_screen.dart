import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/dashboard/components/chart_intervals.dart';
import 'package:decibelio_app_web/views/dashboard/components/map_view.dart';
import 'package:decibelio_app_web/views/dashboard/components/sensor_details.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';
import 'components/max_levels_table.dart';

class DashboardScreen extends StatelessWidget {

  Map<String, dynamic> data = {
    "sensorExternalId": "ADC32BXF",
    "startDate": "2025-01-07T00:00:00.000", // Formato: "YYYY-MM-DDTHH:mm:ss"
    "endDate": "2025-01-09T00:00:00.000", // Formato: "YYYY-MM-DDTHH:mm:ss"
    "intervalMinutes": 30,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MapView(),
                      //LineChartSample12(sensorData: data),
                      const SizedBox(height: 16),
                      const NoiseLevelTable(),
                      SizedBox(height: defaultPadding),
                      // Asegúrate de que RecentFiles esté habilitado para evitar problemas
                      //const NoiseLevelTable(),
                      SoundChartView(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        Column(
                            children: [
                              //const NoiseLevelTable(),
                              //const SizedBox(height: 16),
                              SensorDetails(),
                            ]
                        )
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        //const NoiseLevelTable(),
                        //const SizedBox(height: 16),
                        SensorDetails(),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
