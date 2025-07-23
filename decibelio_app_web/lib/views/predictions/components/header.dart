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
            onPressed: () =>
                context.read<MenuAppController>().controlMenu(context),
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Predicción de Ruido",
            style: Theme.of(context).textTheme.titleLarge,
          ),
            const Spacer(),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        const ProfileCard(),
        Align(
          alignment: Alignment.centerRight, // Alineación a la izquierda
          child: Switch(
              value: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
              activeThumbImage:
                  const AssetImage('assets/images/sun-svgrepo-com.png'),
              inactiveThumbImage:
                  const AssetImage('assets/images/moon-stars-svgrepo-com.png'),
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
    final double anchoPantalla = MediaQuery.of(context).size.width;
   
    const fullLogosThreshold  = 1400.0;  // arriba de 1400px → logos completos
    const shortLogosThreshold =  800.0;

    final bool mostrarFull  = anchoPantalla >= fullLogosThreshold;
    final bool mostrarShort = anchoPantalla >= shortLogosThreshold && anchoPantalla < fullLogosThreshold;

    // Alturas
    final double faviconH = mostrarFull ? 105 : 70;
    final double logoH    = mostrarFull ? 70: 55;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        // Favicon siempre
        Image.asset(
          esTemaOscuro
            ? 'assets/logos/favicon-oscuro.png'
            : 'assets/logos/favicon.png',
          height: faviconH, fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),

        if (mostrarFull) ...[
          Image.asset(
            esTemaOscuro
              ? 'assets/logos/logo_unl_claro.png'
              : 'assets/logos/logo_unl.png',
            height: logoH, fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Image.asset(
            esTemaOscuro
              ? 'assets/logos/cis_unl_claro.png'
              : 'assets/logos/LogoCarreraNombre.png',
            height: logoH, fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/logos/logo_automotriz.png',
            height: logoH, fit: BoxFit.contain,
          ),
        ] else if (mostrarShort) ...[
          Image.asset( esTemaOscuro
              ? 'assets/logos/logo_unl_short_claro.png'
              :  'assets/logos/logo_unl_short.png',
            height: logoH, fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Image.asset( 'assets/logos/cis_short.png',
            height: logoH, fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/logos/automotriz_short.png',
            height: logoH, fit: BoxFit.contain,
          ),
        ],
      ],
    );
  }
}