import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/views/dashboard/components/map.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class MapView extends StatefulWidget {
  const MapView({
    super.key,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool _isExpanded = true; 

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
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                const Text(
                  "Mapa",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpanded ? 'Ocultar Mapa' : 'Mostrar Mapa',
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: defaultPadding),
            SizedBox(
              width: 1025.0,
              height: 600.0,
              child: AnimatedMapControllerPage(),
            ),
          ],
        ],
      ),
    );
  }
}