import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:flutter/material.dart';

import 'animated_container.dart';

class NoiseTable extends StatelessWidget {
  const NoiseTable({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController horizontalController = ScrollController();
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
            Scrollbar(
              controller: horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: const Radius.circular(4),
              child: 
                  SingleChildScrollView(
                    controller: horizontalController,
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
                        _buildDataRow("120", "Excesivamente ruidoso",
                            "Umbra de malestar"),
                        _buildDataRow(
                            "110", "Excesivamente ruidoso", "Aeropuerto"),
                        _buildDataRow(
                            "100", "Excesivamente ruidoso", "Moto, fábrica"),
                        _buildDataRow("90", "Muy ruidoso",
                            "Camión con motor diésel, cortadora de césped"),
                        _buildDataRow("80", "Muy ruidoso",
                            "Música a todo volumen, alarma de reloj, secador de cabello"),
                        _buildDataRow("70", "Ruidoso",
                            "Tráfico, aspiradora, restaurante"),
                        _buildDataRow("60", "Poco ruidoso", "Conversación"),
                        _buildDataRow("50", "Poco ruidoso",
                            "Oficina tranquila, lluvia moderada"),
                        _buildDataRow(
                            "40", "Silencioso", "Refrigerador, cantar de aves"),
                        _buildDataRow("30", "Silencioso",
                            "Biblioteca tranquila, susurros, área rural tranquila"),
                        _buildDataRow("20", "Muy silencioso",
                            "Estudio de grabación, crujir de hojas secas"),
                        _buildDataRow("10", "Muy silencioso",
                            "Cámara anecoica, respiración"),
                      ],
                    ),
                  ),
                  
            
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Función para construir cada fila con el color correspondiente en la primera columna
  DataRow _buildDataRow(String nivel, String apreciacion, String ejemplos) {
    // Obtener el color correspondiente a partir del nivel de ruido
    Color rowColor = ChromaticNoise.getValueColor(double.parse(nivel));

    return DataRow(cells: [
      DataCell(Container(
        padding: const EdgeInsets.all(8.0),
        color: rowColor, // Aplicar el color correspondiente
      child:  DefaultTextStyle(
          style: const TextStyle(color: Color(0xFF182B5C), fontWeight: FontWeight.bold),
          child: _buildCellWithTooltip(nivel),
        ),
      )),
      DataCell(_buildCellWithTooltip(apreciacion)),
      DataCell(_buildCellWithTooltip(ejemplos)),
    ]);
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
