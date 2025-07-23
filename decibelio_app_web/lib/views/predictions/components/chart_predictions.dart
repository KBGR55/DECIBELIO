import 'dart:async';
import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Prediction {
  final DateTime time;
  final double value;
  Prediction({required this.time, required this.value});
}

class SoundChartPrediction extends StatefulWidget {
  const SoundChartPrediction({super.key});

  @override
  State<SoundChartPrediction> createState() => _SoundChartPredictionState();
}

class _SoundChartPredictionState extends State<SoundChartPrediction> {
  // ───────── CONFIG API ─────────
  final String apiBase = 'http://40.76.118.59:8000/predict';
  final String apiRecursive = 'http://40.76.118.59:8000';
  List<Prediction> pred30m = [];
  List<Prediction> pred1h  = [];
  List<Prediction> pred6h  = [];

  Timer? _pollingTimer;
  late TransformationController _transformationController;

  final List<String> _horizons = ['30 minutos', '1 hora', '6 horas'];
  String _selectedHorizon = '6 horas'; // valor por defecto
  List<Prediction> _predictions = [];
  bool _loading = false;

  // ───────── INIT ─────────
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _fetchPredictionForHorizon('6 horas');// primera carga
    /*_pollingTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) => _fetchPredictionForHorizon('6 horas'),
    );*/
  }

  int _getStepsForHorizon(String horizon) {
    switch (horizon) {
      case '30 minutos':
        return 48;
      case '1 hora':
        return 24;
      case '6 horas':
        return 4;
      default:
        throw Exception('Frecuencia no válida');
    }
  }

  Future<void> _fetchPredictionForHorizon(String horizon) async {
    setState(() => _loading = true);
    final steps = _getStepsForHorizon(horizon);
    if(horizon == '30 minutos'){
      horizon = '30m';
    } else if(horizon == '1 hora'){
      horizon = 'hour';
    } else {
      horizon = '6h';
    }
    final uri = Uri.parse('$apiRecursive/predict_recursive/$horizon?steps=$steps');
    debugPrint('➡️  GET $uri');

    final r = await http.get(uri);
    if (r.statusCode == 200) {
      final json = jsonDecode(r.body);
      final predictions = _mapResponse(json);
      setState(() {
        _predictions = predictions;
      });
    } else {
      debugPrint('❌ Error status ${r.statusCode}');
    }
    setState(() => _loading = false);
  }

  // ───────── PETICIONES ─────────
  /**Future<void> _fetchAllPredictions() async {
    Future<Map<String, dynamic>?> _call(String horizon) async {
      final int stepsPerDay = switch (horizon) {
        '30m' => 48,
        'hour' => 24,
        '6h' => 4,
        _ => throw Exception('Horizonte no soportado: $horizon'),
      };

      final uri = Uri.parse('$apiRecursive/predict_recursive/$horizon?steps=$stepsPerDay');
      debugPrint('➡️  GET $uri');

      final r = await http.get(uri);
      debugPrint('⬅️  [$horizon] status ${r.statusCode}');
      debugPrint('⬅️  [$horizon] body   ${r.body}');

      if (r.statusCode == 200) {
        return jsonDecode(r.body);
      } else {
        return null;
      }
    }

    try {
      final j30 = await _call('30m');
      final j1h = await _call('hour');
      final j6h = await _call('6h');

      debugPrint('📊 m30 json: $j30');
      debugPrint('📊 h1  json: $j1h');
      debugPrint('📊 h6  json: $j6h');

      if (j30 != null && j1h != null && j6h != null) {
        final p30 = _mapResponse(j30);
        final p1  = _mapResponse(j1h);
        final p6  = _mapResponse(j6h);

        debugPrint('✅ puntos 30m: ${p30.length}  '
            '1h: ${p1.length}  6h: ${p6.length}');

        setState(() {
          pred30m = p30;
          pred1h  = p1;
          pred6h  = p6;
        });
      } else {
        debugPrint('❌ Alguna de las respuestas no fue 200');
      }
    } catch (e) {
      debugPrint('❗ Excepción al obtener predicciones: $e');
    }
  }*/

  List<Prediction> _mapResponse(Map<String, dynamic> apiJson) {
    final times   = apiJson['timestamps']  as List<dynamic>;
    final values  = apiJson['predictions'] as List<dynamic>;
    return List.generate(times.length, (i) {
      final dt = DateTime.parse(times[i]).toLocal();
      return Prediction(time: dt, value: (values[i] as num).toDouble());
    });
  }

  bool get _ready => _predictions.isNotEmpty;

  // ───────── BUILD ─────────
  @override
  Widget build(BuildContext context) {
    // Mapear las predicciones: usar índices como x, y dB como y


    const leftReservedSize = 52.0;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Predicciones de contaminación acústica con intervalo de tiempo personalizado para el día actual', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Frecuencia Temporal",
            prefixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder(),
          ),
          value: _selectedHorizon,
          items: _horizons.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedHorizon = newValue;
              });
              _fetchPredictionForHorizon(newValue); // solo cuando se elige
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return _horizons.map((scale) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  scale,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList();
          },
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return width >= 380
                ? Row(
              children: [
                const SizedBox(width: leftReservedSize),
                const Spacer(),
                Center(
                  child: _TransformationButtons(
                    controller: _transformationController,
                  ),
                ),
              ],
            )
                : Column(
              children: [
                const SizedBox(height: 16),
                _TransformationButtons(
                  controller: _transformationController,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // -------------- Gráfica --------------
        !_ready
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
          height: 300,
          width: double.infinity,
          child: LineChart(
            _buildChart(),
            transformationConfig: FlTransformationConfig(
              scaleAxis: FlScaleAxis.horizontal,
              minScale: 1.0,
              maxScale: 25.0,
              transformationController: _transformationController,
            ),
          ),
        ),

        const SizedBox(height: 8),
        //_LegendRow(),                                           // leyenda colores
        const SizedBox(height: 8),

        const _DescripcionBox(),
      ]),
    );
  }

  // ───────── CHART DATA ─────────
  LineChartData _buildChart() {
    final List<FlSpot> spots = List.generate(
      _predictions.length,
          (index) => FlSpot(index.toDouble(), _predictions[index].value),
    );

// Extraer la lista de etiquetas de tiempo
    final List<DateTime> timestamps = _predictions.map((p) => p.time.toLocal()).toList();

    return LineChartData(
      lineBarsData: [
        LineChartBarData(spots: spots, isCurved: true, barWidth: 2,
          color: Colors.blue,
          shadow: const Shadow(
            color: Colors.blue,
            blurRadius: 2,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.blue.withOpacity(0.0)
              ],
              stops: const [0.5, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      titlesData: _titlesData(timestamps),
      lineTouchData: _touchData(),
      borderData: FlBorderData(show: true),
      gridData: const FlGridData(show: true),
    );
  }

  // Ejes y tooltips (reutiliza lo que ya tenías)
  FlTitlesData _titlesData(List<DateTime> timestamps) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1, // cada punto tiene su índice
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= timestamps.length) {
              return const SizedBox.shrink();
            }
            final time = timestamps[index];
            return SideTitleWidget(
              meta: meta,
              space: 6,
              child: Transform.rotate(
                angle: -45 * 3.14 / 180,
                child: Text(
                  DateFormat.Hm().format(time),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) =>
              Text('${value.toInt()} dB', style: const TextStyle(fontSize: 10)),
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _touchData() => LineTouchData(
    touchSpotThreshold: 5,
    getTouchLineStart: (_, __) => -double.infinity,
    getTouchLineEnd: (_, __) => double.infinity,
    getTouchedSpotIndicator: (bar, indexes) => indexes
        .map((i) => TouchedSpotIndicatorData(
      const FlLine(
          color: Color(0xFF182B5C),
          strokeWidth: 1.5,
          dashArray: [8, 2]),
      FlDotData(
        show: true,
        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
          radius: 6,
          color: const Color.fromARGB(255, 5, 37, 104),
          strokeWidth: 0,
          strokeColor: Colors.blue,
        ),
      ),
    ))
        .toList(),
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => const Color(0xFF212332),
      getTooltipItems: (spots) => spots.map((barSpot) {
        final value = barSpot.y;
        final time =
        DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt()).toLocal();
        return LineTooltipItem(
          '${value.toStringAsFixed(2)} dB\n${DateFormat.Hm().format(time)}',
          TextStyle(
            color: ChromaticNoise.getValueColor(value),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    ),
  );

  // ───────── CLEANUP ─────────
  @override
  void dispose() {
    _pollingTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }
}

/* ───────── Widgets auxiliares ───────── */

/**class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Row(children: [
    _LegendDot(color: Colors.blue,   label: '30 min'),
    SizedBox(width: 12),
    _LegendDot(color: Colors.green,  label: '1 h'),
    SizedBox(width: 12),
    _LegendDot(color: Colors.orangeAccent, label: '6 h'),
  ]);
}*/

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(Icons.circle, size: 10, color: color),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12))
  ]);
}

class _DescripcionBox extends StatelessWidget {
  const _DescripcionBox();
  @override
  Widget build(BuildContext context) => const Text.rich(
    TextSpan(children: [
      TextSpan(
        text: 'Descripción: ',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
      TextSpan(
        text:
        "La gráfica presenta las predicciones del nivel de ruido para los próximos 30 minutos, 1 hora y 6 horas, superpuestas sobre los valores medidos reales (registrados cada 5 minutos). Es importante tener en cuenta que estas predicciones son estimaciones y pueden diferir de los valores reales.",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ]),
    textAlign: TextAlign.justify,
  );
}

class _TransformationButtons extends StatelessWidget {
  const _TransformationButtons({required this.controller});
  final TransformationController controller;

  @override
  Widget build(BuildContext context) => Row(children: [
    _btn(Icons.arrow_back_ios, _moveLeft,  'Mover izquierda'),
    _btn(Icons.refresh,        _reset,     'Reset zoom'),
    _btn(Icons.arrow_forward_ios, _moveRight, 'Mover derecha'),
    _btn(Icons.add,            _zoomIn,    'Zoom in'),
    _btn(Icons.minimize,       _zoomOut,   'Zoom out'),
  ]);

  IconButton _btn(IconData ic, VoidCallback f, String tip) =>
      IconButton(icon: Icon(ic, size: 16), tooltip: tip, onPressed: f);

  void _reset()      => controller.value = Matrix4.identity();
  void _zoomIn()     => controller.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  void _zoomOut()    => controller.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
  void _moveLeft()   => controller.value *= Matrix4.translationValues(20, 0, 0);
  void _moveRight()  => controller.value *= Matrix4.translationValues(-20, 0, 0);
}