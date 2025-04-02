import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/views/dashboard/components/map.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class MapView extends StatelessWidget {

  const MapView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mapa",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          //SizedBox(height: defaultPadding),
          SizedBox(
            width: 1025.0,
            height: 600.0,
            child: AnimatedMapControllerPage(),
          )
        ],
      ),
    );
  }
}
