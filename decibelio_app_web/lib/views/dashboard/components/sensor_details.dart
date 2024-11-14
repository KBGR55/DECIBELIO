import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'chart.dart';

class SensorDetails extends StatelessWidget {
  const SensorDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detalle de sensores",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(),
          Chart(),
          Chart(),
          Chart(),
          Chart(),
        ],
      ),
    );
  }
}
