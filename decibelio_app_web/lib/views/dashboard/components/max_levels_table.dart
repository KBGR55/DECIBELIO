import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:flutter/material.dart';

class NoiseLevelTable extends StatelessWidget {
  const NoiseLevelTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "LKeq (dB) - Niveles de Ruido Permitidos",
            //style: TextStyle(color: AdaptiveTheme.of(context).theme.cardColor),
            //style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 16.0,
              columns: const [
                DataColumn(
                  label: Text("Uso de suelo"),
                ),
                DataColumn(
                  label: Text("Periodo diurno\n07:01 a 21:00"),
                ),
                DataColumn(
                  label: Text("Periodo nocturno\n21:01 a 7:00"),
                ),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text("Residencial (R1)")),
                  DataCell(Text("55")),
                  DataCell(Text("45")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Equipamiento de Servicios Sociales (EQ1)")),
                  DataCell(Text("55")),
                  DataCell(Text("45")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Equipamiento de Servicios Públicos (EQ2)")),
                  DataCell(Text("60")),
                  DataCell(Text("50")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Comercial (CM)")),
                  DataCell(Text("60")),
                  DataCell(Text("50")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Agrícola Residencial (AR)")),
                  DataCell(Text("65")),
                  DataCell(Text("45")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Industrial (ID1/ID2)")),
                  DataCell(Text("65")),
                  DataCell(Text("55")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Industrial (ID3/ID4)")),
                  DataCell(Text("70")),
                  DataCell(Text("65")),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}