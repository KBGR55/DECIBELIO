class Prediction {
  final DateTime time;  // Tiempo ajustado (+5 minutos)
  final double value;   // Valor predicho

  Prediction({
    required this.time,
    required this.value,
  });

  /// Constructor desde JSON y ajusta el tiempo
  factory Prediction.fromJson(Map<String, dynamic> json) {
    final rawTime = DateTime.parse(json['fecha']).add(const Duration(minutes: 5));
    final val = (json['predict'] as num).toDouble();

    return Prediction(time: rawTime, value: val);
  }

  /// Conversión a mapa JSON (opcional)
  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'value': value,
  };

  /// Representación legible del objeto
  @override
  String toString() {
    return 'PredictionPoint(time: ${time.toIso8601String()}, value: ${value.toStringAsFixed(2)})';
  }
}