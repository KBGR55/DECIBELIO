import 'package:flutter/material.dart';

class ChromaticNoise {

static Color getValueColor(double? v) {
  if (v == null) return Colors.grey;
  if (v <= 20) {
    return const Color(0xFF13E500); // Muy silencioso (0-20)
  } else if (v <= 30) {
    return const Color(0xFF64E900); // Silencioso (20-30)
  } else if (v <= 40) {
    return const Color(0xFF8FEC00); // Silencioso (30-40)
  } else if (v <= 50) {
    return const Color(0xFFBAEE00); // Poco ruidoso (40-50)
  } else if (v <= 60) {
    return const Color(0xFFE5F000); // Poco ruidoso (50-60)
  } else if (v <= 70) {
    return const Color(0xFFF3D300); // Ruidoso (60-70)
  } else if (v <= 80) {
    return const Color(0xFFF5AB00); // Muy ruidoso (70-80)
  } else if (v <= 90) {
    return const Color(0xFFF78100); // Muy ruidoso (80-90)
  } else if (v <= 100) {
    return const Color(0xFFFA5700); // Excesivamente ruidoso (90-100)
  } else if (v <= 110) {
    return const Color(0xFFFC2C00); // Excesivamente ruidoso (100-110)
  } else {
    return const Color(0xFFFF0000); // Más de 110
  }
}


 static String getTooltipMessage(double nivel) {
    // Descending thresholds where each entry maps to a message.
    const thresholds = <double>[100, 90, 70, 50, 30, 20];
    const messages = <String>[
      "Excesivamente ruidoso",  // nivel ≥ 100
      "Muy ruidoso",            //  90 ≤ nivel < 100
      "Ruidoso",                //  70 ≤ nivel <  90
      "Poco ruidoso",           //  50 ≤ nivel <  70
      "Silencioso",             //  30 ≤ nivel <  50
      "Muy silencioso",         //  20 ≤ nivel <  30
    ];

    for (var i = 0; i < thresholds.length; i++) {
      if (nivel >= thresholds[i]) {
        return messages[i];
      }
    }
    // Por debajo de 20 dB:
    return messages.last;
  }
}