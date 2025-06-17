import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final String title;
  final Color color;

  const MainScreen({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final menuController = context.watch<MenuAppController>();
    final isMenuOpen = menuController.isMenuOpen; // Asegúrate de tener esto

    return Scaffold(
      key: menuController.scaffoldKey,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: isMenuOpen ? 325 : 70,
                child: const SideMenu(),
              ),
            const Expanded(
              flex: 5,
              child: Stack(
                children: [
                  DashboardScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: !isDesktop ? const SideMenu() : null,
    );
  }
}
