class QuantityDTO {
  final String? time;
  final double value;

  QuantityDTO({required this.time, required this.value});

  factory QuantityDTO.fromMap(Map<String, dynamic> map) {
    return QuantityDTO(
      time: map['time'] as String,
      value: (map['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'value': value,
    };
  }
}
