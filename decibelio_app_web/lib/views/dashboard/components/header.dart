import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => context.read<MenuAppController>().controlMenu(context),
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Monitoreo de Ruido",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileCard(),
        Align(
          alignment: Alignment.centerRight, // Alineación a la izquierda
          child: Switch(
              value:
              AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
              activeThumbImage:
              new AssetImage('assets/images/sun-svgrepo-com.png'),
              inactiveThumbImage: new AssetImage(
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          "assets/logos/favicon.png",
          height: 85,
        ),
        if (!Responsive.isMobile(context))
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            child: Text("Carrera de Computación"),
          ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("",
          style: Theme.of(context).textTheme.titleLarge
      ),
    );
  }
}
