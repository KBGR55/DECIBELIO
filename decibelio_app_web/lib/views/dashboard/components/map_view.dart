import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/views/dashboard/components/map.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class MapView extends StatelessWidget {

  MapView({
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
