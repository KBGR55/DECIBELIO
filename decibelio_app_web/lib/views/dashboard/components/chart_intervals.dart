import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SoundChartView extends StatefulWidget {
  const SoundChartView({super.key});

  @override
  _SoundChartView createState() => _SoundChartView();
}

class _SoundChartView extends State<SoundChartView> {

  String? selectedSensor;
  DateTime? startDate;
  DateTime? endDate;
  List<String> sensorNames = [];
  String? selectedText; // Texto seleccionado
  int? selectedNumericValue; // Valor numérico seleccionado

  final Map<String, int> valuesMins = {
    "60 minutos": 60,
    "50 minutos": 50,
    "40 minutos": 40,
    "30 minutos": 30,
    "20 minutos": 20,
    "10 minutos": 10,
  };

  @override
  void initState() {
    super.initState();
    loadSensorNames(); // Cargar los nombres de los sensores dinámicamente
  }

  Future<void> loadSensorNames() async {
    // Simulación de una llamada a un servicio o backend
    await Future.delayed(Duration(seconds: 1)); // Simular retardo de red
    setState(() {
      sensorNames = ["Sensor 1", "Sensor 2", "Sensor 3", "Sensor 4"]; // Aquí coloca los nombres reales
    });
  }

  void applyFilter() {
    // Lógica para aplicar los filtros seleccionados

    print("Sensor seleccionado: $selectedSensor");
    print("Fecha de inicio: $startDate");
    print("Fecha de fin: $endDate");
    print("selectedNumericValue: $selectedNumericValue");
    // Aquí puedes implementar la lógica de carga de datos para la gráfica
  }

  // Método para cargar datos (quemados por ahora)
  List<FlSpot> getData() {
    return [
      FlSpot(0, 0.1),
      FlSpot(1, 0.2),
      FlSpot(2, 0.3),
      FlSpot(3, 0.1),
      FlSpot(4, 0.0),
      FlSpot(5, -0.1),
      FlSpot(6, -0.2),
      //FlSpot(7, 0.1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gráficos Estadísticos', style: TextStyle(fontSize: 18)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dropdown para seleccionar el sensor
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Sensores",
                          prefixIcon: Icon(Icons.sensors),
                          border: OutlineInputBorder(),
                        ),
                        value: selectedSensor,
                        items: sensorNames.map((sensor) {
                          return DropdownMenuItem<String>(
                            value: sensor,
                            child: Text(sensor),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSensor = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    // Campo para seleccionar la fecha de inicio
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Fecha inicio",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: startDate != null
                              ? "${startDate!.day}/${startDate!.month}/${startDate!.year}"
                              : "",
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Campo para seleccionar la fecha de fin
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Fecha fin",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: endDate != null
                              ? "${endDate!.day}/${endDate!.month}/${endDate!.year}"
                              : "",
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Minutos",
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        value: selectedText,
                        items: valuesMins.keys.map((text) {
                          return DropdownMenuItem<String>(
                            value: text,
                            child: Text(text),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedText = value;
                            selectedNumericValue = valuesMins[value]; // Obtener el valor numérico asociado
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    // Botón para aplicar el filtro
                    ElevatedButton(
                      onPressed: applyFilter,
                      child: Text("Aplicar filtro"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          const Text(
            "Niveles de ruido dB (decibelio)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Frecuencia en horas / A partir del 03-Dic-2024 01:15:18.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final labels = [
                          "02:00",
                          "03:00",
                          "04:00",
                          "05:00",
                          "06:00",
                          "07:00",
                          "08:00",
                        ];
                        return Text(
                          labels[value.toInt()],
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: getData(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
              "Descripción: Cualquier cosa",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                // Lógica para exportar datos
                print("Exportando datos...");
              },
              icon: Icon(Icons.download),
              label: const Text("Exportar datos (.xls)"),
            ),
          ),
        ],
      ),
    );
  }
}
