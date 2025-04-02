import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorChart extends StatefulWidget {

  const SensorChart({super.key});

  @override
  State<SensorChart> createState() => _SensorChartState();
}

class _SensorChartState extends State<SensorChart> {
  int touchedIndex = -1;
  List<SensorDTO> _sensors = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSensorList();
  }

  Future<void> loadSensorList() async {
    Facade facade = Facade();
    ListSensorDTO sensorData = await facade.listAllSensorsDTO();

    setState(() {
      _sensors = sensorData.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    int activeCount =
        _sensors.where((s) => s.sensorStatus == 'ACTIVE').length;
    int inactiveCount = _sensors.length - activeCount;

    return Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: AdaptiveTheme.of(context).theme.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).toInt()),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "Estado de los sensores",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      startDegreeOffset: 90,
                      sections: _showingSections(
                          touchedIndex, activeCount, inactiveCount),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "En total:\n${_sensors.length}",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.blue, "Activos $activeCount"),
                const SizedBox(width: 16),
                _buildLegend(Colors.red, "Desactivos $inactiveCount"),
              ],
            ),
          ],
        ));
  }

  List<PieChartSectionData> _showingSections(
      int touchedIndex, int active, int inactive) {
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: active.toDouble(),
        title: touchedIndex == 0 ? 'Activos $active' : '',
        radius: touchedIndex == 0 ? 25.0 : 13.0,
        titleStyle:
        const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: inactive.toDouble(),
        title: touchedIndex == 1 ? 'Desactivos $inactive' : '',
        radius: touchedIndex == 1 ? 25.0 : 13.0,
        titleStyle:
        const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
    ];
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
