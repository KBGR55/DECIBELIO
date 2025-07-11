import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => context.read<MenuAppController>().controlMenu(context),
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Administrar Usuarios",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        const ProfileCard(),
        Align(
          alignment: Alignment.centerRight, // Alineación a la izquierda
          child: Switch(
              value:
              AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
              activeThumbImage:
              const AssetImage('assets/images/sun-svgrepo-com.png'),
              inactiveThumbImage: const AssetImage(
                  'assets/images/moon-stars-svgrepo-com.png'),
              activeColor: Colors.white,
              activeTrackColor: Colors.amber,
              inactiveThumbColor: Colors.black,
              inactiveTrackColor: Colors.white,
              onChanged: (bool value) {
                if (value) {
                  AdaptiveTheme.of(context).setLight();
                } else {
                  AdaptiveTheme.of(context).setDark();
                }
              }),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool esTemaOscuro = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Image.asset(
          esTemaOscuro
              ? 'assets/logos/favicon-oscuro.png'
              : 'assets/logos/favicon.png',
          height: 100,
        ),
        if (!Responsive.isMobile(context))
          Row(spacing: 10,
            children: [
              Image.asset(
                "assets/logos/logo_automotriz.png",
                height: 60,
              ),
              Image.asset(
                "assets/logos/LogoCarreraNombre.png",
                height: 60,
              ),
              Image.asset(
                "assets/logos/logoUNL-HD.png",
                height: 60,
              ),
            ],
          ),
      ],
    );
  }
}
