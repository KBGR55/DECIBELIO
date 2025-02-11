import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/views/dashboard/components/animated_container.dart';
import 'package:flutter/material.dart';

class NoiseLevelTable extends StatelessWidget {
  const NoiseLevelTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ExpandableButton(
        titleExpanded: 'Mostrar menos', // Texto cuando está expandido
        titleCollapsed: 'Mostrar Niveles de Ruido Permitidos', // Texto cuando está colapsado
        expandedContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LKeq (dB) - Niveles de Ruido Permitidos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16.0,
                horizontalMargin: 8.0,
                columns: const [
                  DataColumn(
                    label: Text(
                      "Uso de suelo",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Periodo diurno\n07:01 a 21:00",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Periodo nocturno\n21:01 a 7:00",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  _buildDataRow("Residencial (R1)", "55", "45"),
                  _buildDataRow(
                      "Equipamiento de Servicios Sociales (EQ1)", "55", "45"),
                  _buildDataRow(
                      "Equipamiento de Servicios Públicos (EQ2)", "60", "50"),
                  _buildDataRow("Comercial (CM)", "60", "50"),
                  _buildDataRow("Agrícola Residencial (AR)", "65", "45"),
                  _buildDataRow("Industrial (ID1/ID2)", "65", "55"),
                  _buildDataRow("Industrial (ID3/ID4)", "70", "65"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String uso, String diurno, String nocturno) {
    return DataRow(cells: [
      DataCell(_buildCellWithTooltip(uso)),
      DataCell(_buildCellWithTooltip(diurno)),
      DataCell(_buildCellWithTooltip(nocturno)),
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