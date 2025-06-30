import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/models/observation_entry.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:intl/intl.dart';

/// Widget que muestra un gráfico de líneas con series MAX, AVERAGE y MIN togglables.
class ChartRanges extends StatefulWidget {
  final List<ObservationEntry> entries;
  final SensorDTO sensor;
  final String timeFrame;

  const ChartRanges({
    super.key,
    required this.entries,
    required this.sensor,
    required this.timeFrame,
  });

  @override
  ChartRangesState createState() => ChartRangesState();
}

class ChartRangesState extends State<ChartRanges> {
  bool showMax = true;
  bool showAvg = true;
  bool showMin = true;
  late final TransformationController _transformationController;

  Widget _buildPeriodLabel(BuildContext context) {
    final isNight = widget.timeFrame == 'NOCTURNO';
    final icon = isNight ? Icons.nights_stay : Icons.wb_sunny;

    // Si el theme no define iconTheme.color, damos un fallback
    final color = AdaptiveTheme.of(context).theme.iconTheme.color ??
        Theme.of(context).iconTheme.color ??
        Colors.white;

    final label =
        '${isNight ? 'PERIODO NOCTURNO' : 'PERIODO DIURNO'} - ${widget.sensor.name.toUpperCase()}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    const leftReservedSize = 52.0;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPeriodLabel(context),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('No hay datos disponibles'),
          ],
        ),
      );
    }
    // Agrupar por fecha y calcular rango para eje Y
    final dates = entries.map((e) => e.date).toSet().toList()..sort();
    final datePositions = {
      for (var i = 0; i < dates.length; i++) dates[i]: i.toDouble()
    };
    final values = entries.map((e) => e.value);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // Filtrar por tipo de medición
    final maxEntries = showMax
        ? entries.where((e) => e.measurementType == 'MAX').toList()
        : [];
    final avgEntries = showAvg
        ? entries.where((e) => e.measurementType == 'AVERAGE').toList()
        : [];
    final minEntries = showMin
        ? entries.where((e) => e.measurementType == 'MIN').toList()
        : [];

    Color color(String t) => t == 'MAX'
        ? Colors.red
        : t == 'MIN'
            ? Colors.blue
            : Colors.green;

    final series = <LineChartBarData>[
      if (maxEntries.isNotEmpty)
        LineChartBarData(
          spots: maxEntries
              .where((e) => datePositions.containsKey(e.date))
              .map((e) => FlSpot(datePositions[e.date]!, e.value))
              .toList(),
          isCurved: false,
          barWidth: 2,
          dotData: const FlDotData(show: true),
          color: color('MAX'),
        ),
      if (avgEntries.isNotEmpty)
        LineChartBarData(
          spots: avgEntries
              .map((e) => FlSpot(datePositions[e.date]!, e.value))
              .toList(),
          isCurved: false,
          barWidth: 2,
          dotData: const FlDotData(show: true),
          color: color('AVERAGE'),
        ),
      if (minEntries.isNotEmpty)
        LineChartBarData(
          spots: minEntries
              .map((e) => FlSpot(datePositions[e.date]!, e.value))
              .toList(),
          isCurved: false,
          barWidth: 2,
          dotData: const FlDotData(show: true),
          color: color('MIN'),
        ),
    ];

    return Column(
      children: [
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodLabel(context),
                const Spacer(),
                _TransformationButtons(controller: _transformationController),
              ],
            ),
            // si de verdad lo quieres en la esquina:
            Positioned(
              top: 4,
              right: 4,
              child:
                  _TransformationButtons(controller: _transformationController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  // deja espacio a la derecha para los botones
                  padding: const EdgeInsets.only(right: 60),
                  child: LineChart(
                    transformationConfig: FlTransformationConfig(
                      scaleAxis: FlScaleAxis.horizontal,
                      minScale: 1.0,
                      maxScale: 25.0,
                      transformationController: _transformationController,
                    ),
                    LineChartData(
                      minY: minValue,
                      maxY: maxValue,
                      lineBarsData: series,
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          drawBelowEverything: true,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: leftReservedSize,
                            maxIncluded: false,
                            minIncluded: false,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()} dB',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: 1.0,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= dates.length) {
                                return const Text('');
                              }
                              final date = dates[value.toInt()];
                              return SideTitleWidget(
                                meta: meta,
                                space: 12, // separación horizontal desde el eje

                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0,
                                      left:
                                          8.0), // separación adicional (vertical y horizontal)
                                  child: Transform.rotate(
                                    angle: -0.785398, // -45 grados en radianes
                                    child: Text(
                                      DateFormat('yyyy/MM/dd')
                                          .format(DateTime.parse(date)),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (barSpot) => const Color(0xFF212332),
                          getTooltipItems: (spots) {
                            final List<ObservationEntry> maxEntries = showMax
                                ? entries
                                    .where((e) => e.measurementType == 'MAX')
                                    .toList()
                                : <ObservationEntry>[];

                            final List<ObservationEntry> avgEntries = showAvg
                                ? entries
                                    .where(
                                        (e) => e.measurementType == 'AVERAGE')
                                    .toList()
                                : <ObservationEntry>[];

                            final List<ObservationEntry> minEntries = showMin
                                ? entries
                                    .where((e) => e.measurementType == 'MIN')
                                    .toList()
                                : <ObservationEntry>[];

                            final List<List<ObservationEntry>> visibleEntries =
                                <List<ObservationEntry>>[
                              if (showMax) maxEntries,
                              if (showAvg) avgEntries,
                              if (showMin) minEntries,
                            ];

                            return spots
                                .map((spot) {
                                  final int dateIndex = spot.x.toInt();
                                  if (dateIndex >= dates.length) return null;

                                  final date = dates[dateIndex];
                                  final list = visibleEntries[spot.barIndex];

                                  final entry = list.firstWhere(
                                    (e) => e.date == date,
                                    orElse: () => ObservationEntry(
                                      date: date,
                                      time: 'N/A',
                                      value: spot.y,
                                      measurementType: 'DESCONOCIDO',
                                    ),
                                  );

                                  return LineTooltipItem(
                                    '',
                                    const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: '${entry.measurementType}\n',
                                        style: TextStyle(
                                          color: color(entry.measurementType),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${DateFormat('yyyy/MM/dd').format(DateTime.parse(date))} a las ${entry.time}\n',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${entry.value} dB\n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: ChromaticNoise.getValueColor(
                                              entry.value),
                                        ),
                                      ),
                                    ],
                                  );
                                })
                                .where((item) => item != null)
                                .toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['MAX', 'AVERAGE', 'MIN'].map((t) {
            final isActive = (t == 'MAX' && showMax) ||
                (t == 'AVERAGE' && showAvg) ||
                (t == 'MIN' && showMin);
            return GestureDetector(
              onTap: () => setState(() {
                if (t == 'MAX') showMax = !showMax;
                if (t == 'AVERAGE') showAvg = !showAvg;
                if (t == 'MIN') showMin = !showMin;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Tooltip(
                  message:
                      'Hacer clic para ${isActive ? 'ocultar' : 'mostrar'} los puntos de la gráfica de $t.',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: isActive ? color(t) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t,
                        style: TextStyle(
                          color: isActive ? Colors.blue : Colors.grey,
                          decoration: isActive
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class _TransformationButtons extends StatelessWidget {
  const _TransformationButtons({
    required this.controller,
  });

  final TransformationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Mover izquierda',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: _transformationMoveLeft,
          ),
        ),
        Tooltip(
          message: 'Reset zoom',
          child: IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: _transformationReset,
          ),
        ),
        Tooltip(
          message: 'Mover derecha',
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: _transformationMoveRight,
          ),
        ),
        Tooltip(
          message: 'Zoom in',
          child: IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: _transformationZoomIn,
          ),
        ),
        Tooltip(
          message: 'Zoom out',
          child: IconButton(
            icon: const Icon(Icons.minimize, size: 16),
            onPressed: _transformationZoomOut,
          ),
        ),
      ],
    );
  }

  void _transformationReset() {
    controller.value = Matrix4.identity();
  }

  void _transformationZoomIn() {
    controller.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  }

  void _transformationMoveLeft() {
    controller.value *= Matrix4.translationValues(20, 0, 0);
  }

  void _transformationMoveRight() {
    controller.value *= Matrix4.translationValues(-20, 0, 0);
  }

  void _transformationZoomOut() {
    controller.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
  }
}
