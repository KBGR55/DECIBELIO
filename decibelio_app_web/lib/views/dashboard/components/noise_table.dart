import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import 'animated_container.dart';

class NoiseTable extends StatelessWidget {
  const NoiseTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: ExpandableButton(
        titleExpanded: 'Mostrar menos', 
        titleCollapsed: 'Cromática del Ruido',
        expandedContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16.0,
                horizontalMargin: 8.0,
                columns: const [
                  DataColumn(
                    label: Text(
                      "Nivel (dB)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Apreciación",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Ejemplos de Fuentes Sonoras",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  _buildDataRow("120", "Excesivamente ruidoso", "Umbra de malestar"),
                  _buildDataRow("110", "Excesivamente ruidoso", "Aeropuerto"),
                  _buildDataRow("100", "Excesivamente ruidoso", "Moto, fábrica"),
                  _buildDataRow("90", "Muy ruidoso", "Camión con motor diésel, cortadora de césped"),
                  _buildDataRow("80", "Muy ruidoso", "Música a todo volumen, alarma de reloj, secador de cabello"),
                  _buildDataRow("70", "Ruidoso", "Tráfico, aspiradora, restaurante"),
                  _buildDataRow("60", "Poco ruidoso", "Conversación"),
                  _buildDataRow("50", "Poco ruidoso", "Oficina tranquila, lluvia moderada"),
                  _buildDataRow("40", "Silencioso", "Refrigerador, cantar de aves"),
                  _buildDataRow("30", "Silencioso", "Biblioteca tranquila, susurros, área rural tranquila"),
                  _buildDataRow("20", "Muy silencioso", "Estudio de grabación, crujir de hojas secas"),
                  _buildDataRow("10", "Muy silencioso", "Cámara anecoica, respiración"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para construir cada fila con el color correspondiente en la primera columna
  DataRow _buildDataRow(String nivel, String apreciacion, String ejemplos) {
    // Obtener el color correspondiente a partir del nivel de ruido
    Color rowColor = _getColorForNivel(int.parse(nivel));

    return DataRow(cells: [
      DataCell(Container(
        padding: const EdgeInsets.all(8.0),
        color: rowColor, // Aplicar el color correspondiente
        child: _buildCellWithTooltip(nivel),
      )),
      DataCell(_buildCellWithTooltip(apreciacion)),
      DataCell(_buildCellWithTooltip(ejemplos)),
    ]);
  }

  // Función para asignar el color según el nivel de ruido
  Color _getColorForNivel(int nivel) {
    if (nivel >= 120) {
      return const Color(0xFFFF0000); // Excesivamente ruidoso (110-120)
    } else if (nivel >= 110) {
      return const Color(0xFFFC2C00); // Excesivamente ruidoso (100-110)
    } else if (nivel >= 100) {
      return const Color(0xFFFA5700); // Excesivamente ruidoso (90-100)
    } else if (nivel >= 90) {
      return const Color(0xFFF78100); // Muy ruidoso (80-90)
    } else if (nivel >= 80) {
      return const Color(0xFFF5AB00); // Muy ruidoso (70-80)
    } else if (nivel >= 70) {
      return const Color(0xFFF3D300); // Ruidoso (60-70)
    } else if (nivel >= 60) {
      return const Color(0xFFE5F000); // Poco ruidoso (50-60)
    } else if (nivel >= 50) {
      return const Color(0xFFBAEE00); // Poco ruidoso (40-50)
    } else if (nivel >= 40) {
      return const Color(0xFF8FEC00); // Silencioso (30-40)
    } else if (nivel >= 30) {
      return const Color(0xFF64E900); // Silencioso (20-30)
    } else if (nivel >= 20) {
      return const Color(0xFF13E500); // Muy silencioso (0-20)
    } else {
      return const Color(0xFF13E500); // Muy silencioso (0-20)
    }
  }

  Widget _buildCellWithTooltip(String text) {
    return Tooltip(
      message: text, // Texto completo al pasar el cursor
      child: Text(
        text,
        overflow: TextOverflow.ellipsis, // Recorta con "..."
        maxLines: 2, // Permite hasta dos líneas
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
