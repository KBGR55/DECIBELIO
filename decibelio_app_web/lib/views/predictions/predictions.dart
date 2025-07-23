import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/dashboard/components/noise_table.dart';
import 'package:decibelio_app_web/views/predictions/components/chart_predictions.dart';
import 'package:decibelio_app_web/views/predictions/components/day_predictions.dart';
import 'package:decibelio_app_web/views/predictions/components/week_predictions.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../dashboard/components/header.dart';

class Predictions extends StatelessWidget {
  const Predictions({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(title:  "Predicción de Ruido",),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const SoundDayPrediction(),
                      const SizedBox(height: 16),
                      const SoundChartPrediction(),
                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        const Column(
                          children: [
                            SoundWeekPrediction(),
                            SizedBox(height: 16),
                            NoiseTable(),
                            SizedBox(height: 16),
                          ],
                        ),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  const Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        SoundWeekPrediction(),
                        SizedBox(height: 16),
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
