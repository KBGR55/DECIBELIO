import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Prediction {
  final DateTime time;
  final double db;
  Prediction({required this.time, required this.db});
}

class SoundDayPrediction extends StatefulWidget {
  const SoundDayPrediction({super.key});
  @override
  State<SoundDayPrediction> createState() => _SoundDayPredictionState();
}

class _SoundDayPredictionState extends State<SoundDayPrediction> {
  // ───────── CONFIG API ─────────
  final String apiUrl = 'http://40.76.118.59:8000/predict/24h'; // ← ajusta host:puerto

  final ScrollController _scrollController = ScrollController();
  late List<Prediction> predictions;
  int closestIndex = 0;

  final double itemWidth = 80;
  final double itemMargin = 12;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    predictions = [];
    _fetch24h();
    // refresca cada 30 min
    _timer = Timer.periodic(const Duration(minutes: 30), (_) => _fetch24h());
  }

  int getClosestIndexToNow(List<DateTime> timestamps) {
    if (timestamps.isEmpty) return 0;

    final now = DateTime.now();

    // Calculate the Duration from midnight for the current time
    // This effectively extracts just the time-of-day component
    final nowTimeOfDay = Duration(hours: now.hour, minutes: now.minute, seconds: now.second, milliseconds: now.millisecond);

    int closestIndex = 0;
    // Initialize minDiff with a large value (e.g., 24 hours in minutes)
    Duration minDiff = const Duration(days: 1); // Represents a full day's difference

    for (int i = 0; i < timestamps.length; i++) {
      final currentTimestamp = timestamps[i];
      final timestampTimeOfDay = Duration(hours: currentTimestamp.hour, minutes: currentTimestamp.minute, seconds: currentTimestamp.second, milliseconds: currentTimestamp.millisecond);

      Duration diff = (timestampTimeOfDay - nowTimeOfDay).abs();
      if (diff.inMinutes > const Duration(hours: 12).inMinutes) {
        diff = const Duration(days: 1) - diff;
      }
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  void main() {
    final now = DateTime.now();

    // Example Timestamps:
    final List<DateTime> myTimestamps = [
      now.subtract(Duration(hours: 2, minutes: 59)), // Around 3 hours ago, but close to the hour boundary
      now.subtract(Duration(minutes: 5)),             // 5 minutes ago (this should be the closest)
      now.add(Duration(minutes: 10)),                // 10 minutes from now
      now.subtract(Duration(hours: 1, minutes: 30)), // 1 hour 30 minutes ago
      now.add(Duration(hours: 3)),                   // 3 hours from now
    ];

    for (var i = 0; i < myTimestamps.length; i++) {
    }

  }



  Future<void> _fetch24h() async {
    try {
      final r = await http.get(Uri.parse(apiUrl));
      if (r.statusCode != 200) {
        debugPrint('HTTP ${r.statusCode} al leer 24h');
        return;
      }

      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final ts = j['timestamps'] as List<dynamic>;
      final val = j['predictions'] as List<dynamic>;

      final List<Prediction> loaded = List.generate(ts.length, (i) {
        final dt = DateTime.parse(ts[i]).toLocal();
        return Prediction(time: dt, db: (val[i] as num).toDouble());
      });

      if (mounted && loaded.isNotEmpty) {
        final newClosestIndex = getClosestIndexToNow(loaded.map((e) => e.time).toList());
        setState(() {
          predictions = loaded;
          closestIndex = newClosestIndex;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToClosest());
      } else {
        debugPrint("No predictions disponibles en la respuesta");
      }
    } catch (e) {
      debugPrint('Error fetch 24h: $e');
    }
  }

  void _scrollToClosest() {
    if (predictions.isEmpty) return;
    final tot = itemWidth + itemMargin;
    final pos = tot * closestIndex -
        (MediaQuery.of(context).size.width / 2 - itemWidth / 2);

    _scrollController.animateTo(
      pos.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime dateToday = DateTime(now.year, now.month, now.day);

    return Listener(
      onPointerSignal: (ps) {
        if (ps is PointerScrollEvent) {
          _scrollController.jumpTo(_scrollController.offset + ps.scrollDelta.dy);
        }
      },
      child: Container(
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
            Text('Proyección de contaminación acústica a corto plazo para el día actual (${dateToday.toString().replaceAll("00:00:00.000", "")})',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            predictions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: true,
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: predictions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final pred = entry.value;
                      final color = ChromaticNoise.getValueColor(pred.db);
                      final isClosest = idx == closestIndex;

                      return Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(
                            right: idx == predictions.length - 1
                                ? 0
                                : itemMargin),
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(isClosest ? 0.3 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: color,
                            width: isClosest ? 2.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isClosest)
                              const Text(
                                'AHORA',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            SvgPicture.asset(
                              'assets/icons/sound-up.svg',
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                  color, BlendMode.srcIn),
                            ),
                            const SizedBox(height: 8),
                            Text('${pred.db.toStringAsFixed(1)} dB',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color)),
                            const SizedBox(height: 4),
                            Text(DateFormat.Hm().format(pred.time),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}