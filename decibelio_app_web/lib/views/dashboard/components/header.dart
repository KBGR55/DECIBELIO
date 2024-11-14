import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            color: Theme.of(context).scaffoldBackgroundColor,
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Monitoreo de Ruido",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileCard()
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
