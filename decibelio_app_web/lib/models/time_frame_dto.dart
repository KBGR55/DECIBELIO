class TimeFrameDTO {
  final int id;
  final String name;
  final String startTime;
  final String endTime;

  TimeFrameDTO({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory TimeFrameDTO.fromMap(Map<String, dynamic> map) {
    return TimeFrameDTO(
      id: map['id'] as int,
      name: map['name'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}