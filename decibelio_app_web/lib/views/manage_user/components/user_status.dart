// lib/views/manage_user/components/user_chart.dart

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/models/user_dto.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserChart extends StatefulWidget {
  const UserChart({super.key});

  @override
  State<UserChart> createState() => _UserChartState();
}

class _UserChartState extends State<UserChart> {
  int touchedIndex = -1;
  int activeCount = 0;
  int inactiveCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserCounts();
  }

  /// Obtiene por separado la lista de usuarios activos e inactivos
  /// y actualiza los contadores.
  Future<void> _loadUserCounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final facade = Facade();
    try {
      // Listar usuarios activos
      final List<UserDTO> activos = await facade.listAllActiveUsers();
      // Listar usuarios inactivos
      final List<UserDTO> inactivos = await facade.listAllInactiveUsers();

      setState(() {
        activeCount = activos.length;
        inactiveCount = inactivos.length;
      });
    } catch (e) {
      debugPrint('Error al cargar usuarios para el chart: $e');
      setState(() {
        _errorMessage = 'No se pudo cargar datos de usuarios.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = activeCount + inactiveCount;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Estado de los usuarios",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Si hay error, muéstralo
          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],

          // Si está cargando, muestra un indicador
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            )
          else if (total == 0)
            // Si no hay usuarios en total
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No hay usuarios registrados.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
            )
          else
            // PieChart + texto central
            SizedBox(
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
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      startDegreeOffset: 270, // opcional: inicio arriba
                      sections: _buildPieSections(touchedIndex),
                    ),
                  ),
                  // Texto central que muestra el total
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        "Total:\n$total",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Leyenda debajo del gráfico
          if (!_isLoading && total > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.blue, "Activos $activeCount"),
                const SizedBox(width: 16),
                _buildLegend(Colors.red, "Inactivos $inactiveCount"),
              ],
            ),
        ],
      ),
    );
  }

  /// Construye las secciones del PieChart con los valores correspondientes.
  List<PieChartSectionData> _buildPieSections(int touchedIndex) {
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    // Si total == 0, devolvemos listas vacías (aunque el build evita esta llamada)
    if (activeCount + inactiveCount == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: activeCount.toDouble(),
        title: (touchedIndex == 0 && activeCount > 0) ? '$activeCount' : '',
        radius: (touchedIndex == 0) ? 30.0 : 20.0,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: inactiveCount.toDouble(),
        title: (touchedIndex == 1 && inactiveCount > 0) ? '$inactiveCount' : '',
        radius: (touchedIndex == 1) ? 30.0 : 20.0,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
    ];
  }

  /// Pequeña “leyenda” con un círculo de color y un texto.
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
