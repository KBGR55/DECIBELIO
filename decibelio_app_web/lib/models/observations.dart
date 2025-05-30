class Observations {
  final String
      date; // Debería ser LocalDate en Java, pero se puede usar String aquí
  final String time;
  final int id; // Cambiar a int para que coincida con el modelo de Java
  final String? range;
  final double value; // Este es un float en Java

  Observations({
    required this.date,
    required this.id,
    this.range,
    required this.time,
    required this.value,
  });

  factory Observations.fromMap(Map<String, dynamic> map) {
    return Observations(
      date: map['date'],
      id: map['id'],
      range: map['range'],
      time: map['time'],
      value: map['value']
          .toDouble(), // Asegúrate de que esto se convierta a double
    );
  }

  @override
  String toString() {
    return 'Observation(id: $id, date: $date, time: $time, value: $value, range: $range)';
  }
}
