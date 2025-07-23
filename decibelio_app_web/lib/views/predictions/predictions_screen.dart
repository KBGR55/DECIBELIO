import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/main/components/side_menu.dart';
import 'package:decibelio_app_web/views/predictions/predictions.dart';
import 'package:flutter/material.dart';

class PredictionsScreen extends StatelessWidget {
  final String title;
  final Color color;

  const PredictionsScreen({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (newContext) {
        return Scaffold(
          //key: newContext.read<MenuAppController>().scaffoldKey,
          drawer: const SideMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  const Expanded(
                    child: SideMenu(),
                  ),
                const Expanded(
                  flex: 5,
                  child: Predictions(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}