import 'dart:async';
import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DayPrediction {
  final DateTime day;
  final double db;
  DayPrediction({required this.day, required this.db});
}

class SoundWeekPrediction extends StatefulWidget {
  const SoundWeekPrediction({super.key});

  @override
  State<SoundWeekPrediction> createState() => _SoundWeekPredictionState();
}

class _SoundWeekPredictionState extends State<SoundWeekPrediction> {
  final String apiUrl = 'http://40.76.118.59:8000/predict/week'; // ajusta host/puerto

  List<DayPrediction> predictions = [];
  int todayIndex = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchWeek();
    _timer = Timer.periodic(const Duration(hours: 6), (_) => _fetchWeek());
  }

  Future<void> _fetchWeek() async {
    try {
      final r = await http.get(Uri.parse(apiUrl));
      if (r.statusCode != 200) {
        debugPrint('HTTP ${r.statusCode} /week'); return;
      }
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final ts  = j['timestamps']  as List<dynamic>;
      final val = j['predictions'] as List<dynamic>;

      final List<DayPrediction> loaded = List.generate(ts.length, (i) =>
          DayPrediction(
            day: DateTime.parse(ts[i]).toLocal(),
            db : (val[i] as num).toDouble(),
          ));

      setState(() {
        predictions = loaded;
        _findTodayIndex();
      });
    } catch (e) {
      debugPrint('Error week: $e');
    }
  }

  void _findTodayIndex() {
    final t = DateTime.now();
    todayIndex = predictions.indexWhere((p) =>
    p.day.year  == t.year &&
        p.day.month == t.month &&
        p.day.day   == t.day);
    if (todayIndex == -1) todayIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Niveles de ruido promedio próximos 7 días',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),

          predictions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: predictions.asMap().entries.map((entry) {
              final idx = entry.key;
              final p   = entry.value;
              final col = ChromaticNoise.getValueColor(p.db);
              final isToday = idx == todayIndex;

              return Container(
                height: 80,
                margin: EdgeInsets.only(bottom: idx==predictions.length-1?0:12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: col.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: col,
                    width: isToday ? 2.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isToday)
                          const Text('HOY',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        Text('${p.db.toStringAsFixed(1)} dB',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      toBeginningOfSentenceCase(
                        DateFormat.EEEE('es').format(p.day),
                      )!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}