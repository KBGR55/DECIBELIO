import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/dashboard/components/chart_intervals.dart';
import 'package:decibelio_app_web/views/dashboard/components/map_view.dart';
import 'package:decibelio_app_web/views/dashboard/components/noise_table.dart';
import 'package:decibelio_app_web/views/dashboard/components/sensor_details.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';
import 'components/max_levels_table.dart';


class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const MapView(),
                      //LineChartSample12(sensorData: data),
                      const SizedBox(height: 16),
                      const NoiseLevelTable(),
                      const SizedBox(height: defaultPadding),
                      // Asegúrate de que RecentFiles esté habilitado para evitar problemas
                      //const NoiseLevelTable(),
                      const SoundChartView(),
                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        const Column(
                            children: [
                              //const NoiseLevelTable(),
                              //const SizedBox(height: 16),
                              SensorDetails(),
                              SizedBox(height: 16),
                              NoiseTable(),
                            ]
                        )
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        //const NoiseLevelTable(),
                        //const SizedBox(height: 16),
                        const SensorDetails(),
                        const SizedBox(height: 16),
                        NoiseTable(),
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
