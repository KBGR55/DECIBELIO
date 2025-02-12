import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class Chart extends StatefulWidget {
  const Chart({super.key, required this.range, required this.value});

  final String range;
  final double value;

  @override
  State<StatefulWidget> createState() => ChartState();
}

class ChartState extends State<Chart> {

  int touchedIndex = -1;

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: 90,
              sections: showingSections(touchedIndex, widget.value),
            ),
            duration: const Duration(milliseconds: 200), // Optional
            curve: Curves.linear,
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  widget.value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).cardColor,
                    fontWeight: FontWeight.w600,
                    height: 0.5,
                  ),
                ),
                Text("dB")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> showingSections(int touchedIndex, double value) {
  value = value.roundToDouble();
  final numSections = (value / 10).truncate();
  const defRadio = 100 / 12;
  final lastSection = value - (numSections * 10);

  double calculateValue(int i) {
    if (i <= numSections - 1) {
      return defRadio;
    } else if (i == numSections) {
      return lastSection;
    } else {
      return 0.0;
    }
  }

  double calculateRest() {
    return 100 - ((value * 100) / 120);
  }

  const List<Color> sectionColors = [
    Color(0xFF13E500), // Muy silencioso (0-20)
    Color(0xFF13E500),
    Color(0xFF64E900), // Silencioso (20-30)
    Color(0xFF8FEC00), // Silencioso (30-40)
    Color(0xFFBAEE00), // Poco ruidoso (40-50)
    Color(0xFFE5F000), // Poco ruidoso (50-60)
    Color(0xFFF3D300), // Ruidoso (60-70)
    Color(0xFFF5AB00), // Muy ruidoso (70-80)
    Color(0xFFF78100), // Muy ruidoso (80-90)
    Color(0xFFFA5700), // Excesivamente ruidoso (90-100)
    Color(0xFFFC2C00), // Excesivamente ruidoso (100-110)
    Color(0xFFFF0000), // Excesivamente ruidoso (110-120)
  ];

  const List<String> sectionTitles = [
    "Muy silencioso\n< 10dB",
    "Muy silencioso\n< 20dB",
    "Silencioso\n< 30dB",
    "Silencioso\n< 40dB",
    "Poco ruidoso\n< 50dB",
    "Poco ruidoso\n< 60dB",
    "Ruidoso\n< 70dB",
    "Muy ruidoso\n< 80dB",
    "Muy ruidoso\n< 90dB",
    "Excesivamente ruidoso\n< 100dB",
    "Excesivamente ruidoso\n< 110dB",
    "Excesivamente ruidoso\n< 120dB",
  ];

  const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

  return List.generate(13, (i) {
    final isTouched = i == touchedIndex;
    final radius = isTouched ? 25.0 : 13.0;
    if (i == 12) {
      // Última sección de "resto"
      return PieChartSectionData(
        color: Colors.grey.withOpacity(0.1),
        value: calculateRest(),
        showTitle: false,
        radius: 13,
      );
    }

    return PieChartSectionData(
      color: sectionColors[i],
      value: calculateValue(i),
      title: sectionTitles[i],
      showTitle: isTouched,
      radius: radius,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: shadows,
      ),
    );
  });
}