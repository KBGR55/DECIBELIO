import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/dashboard/components/chart_intervals.dart';
import 'package:decibelio_app_web/views/dashboard/components/map_view.dart';
import 'package:decibelio_app_web/views/dashboard/components/noise_measurement_details.dart';
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
            const Header(title: "Monitoreo de Ruido",),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const MapView(),
                      const SizedBox(height: 16),
                      const NoiseLevelTable(),
                      const SizedBox(height: defaultPadding),
                      const SoundChartView(),
                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        const Column(children: [
                          NoiseTable(),
                          SizedBox(height: 16),
                          SensorDetails(),
                          SizedBox(height: 16),
                          NoiseMeasurementDetails(),
                        ])
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  const Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        NoiseTable(),
                        SizedBox(height: 16),
                        SensorDetails(),
                        SizedBox(height: 16),
                        NoiseMeasurementDetails(),
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
