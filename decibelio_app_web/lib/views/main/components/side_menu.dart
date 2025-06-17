// lib/views/main/components/side_menu.dart

import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/auth_service.dart';
import 'dart:html' as html;

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthService.getUser();
    setState(() {
      _user = user;
    });
  }

  bool get isAdministrador {
    if (_user == null) return false;
    final roles = _user!['roles'];
    if (roles is List) {
      return roles.contains('ADMINISTRADOR');
    }
    return false;
  }
  String avatarSvg =  '''
        <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
          <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0"/>
          <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1"/>
        </svg>
        ''';

  @override
  Widget build(BuildContext context) {
    final isCollapsed = !context.watch<MenuAppController>().isMenuOpen;
    final isDesktop = Responsive.isDesktop(context);

    return Drawer(
      backgroundColor: AdaptiveTheme.of(context).theme.canvasColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  left: isCollapsed ? 8 : 16,
                  right: isCollapsed ? 8 : 16,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      IconButton(
                        icon: Icon(
                          isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          final controller = context.read<MenuAppController>();
                          controller.toggleMenu();
                        },
                        tooltip: isCollapsed ? 'Expandir menú' : 'Colapsar menú',
                      ),
                    const SizedBox(height: 8),
                    Center(
                      child: ClipOval(
                        child: _user != null
                            ? Image.network(
                          _user!['photo']!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                            : SvgPicture.string(avatarSvg, width: 60, height: 60),
                      ),
                    ),
                    if (_user == null && !isCollapsed) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(color: Colors.white70, width: 1),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding, vertical: 20),
                        ),
                        onPressed: () {
                          html.window.location.href =
                          '${Conexion.urlBase}auth/google/login';
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/google_color_svgrepo_com.svg",
                              height: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text("Accede con Google")
                          ],
                        ),
                      ),
                    ],
                    if (!isCollapsed && _user != null) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          '${_user!['firstName']} ${_user!['lastName']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          _user!['email'],
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await AuthService.logout();
                          setState(() => _user = null);
                        },
                        child: const Text(
                          "Cerrar sesión",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Menú
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            isCollapsed: isCollapsed,
          ),
          if (isAdministrador)
            DrawerListTile(
              title: "Administrar Sensores",
              svgSrc: "assets/icons/menu_task.svg",
              press: () =>
                  Navigator.pushReplacementNamed(context, '/manage_sensor'),
              isCollapsed: isCollapsed,
            ),
          if (isAdministrador)
            DrawerListTile(
              title: "Administrar Usuarios",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () =>
                  Navigator.pushReplacementNamed(context, '/manage_users'),
              isCollapsed: isCollapsed,
            ),

          const Divider(color: Colors.white54),
          if (!isCollapsed)
            const ListTile(
              title: Text(
                "Proyectos de Vinculación con la Sociedad:",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          if (!isCollapsed)
            const ListTile(
              title: Text(
                "Estrategias para la gestión sostenible del ruido vehicular en la ciudad de Loja: Un enfoque innovador para ciudades urbanas.",
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          if (!isCollapsed)
            ...[
              Image.asset('assets/logos/favicon-oscuro.png', height: 100),
              SizedBox(height: 10),
              Image.asset("assets/logos/logoUNL-HD.png", height: 75),
              SizedBox(height: 10),
              Image.asset("assets/logos/LogoCarreraNombre.png", height: 75),
              SizedBox(height: 10),
              Image.asset("assets/logos/logo_automotriz.png", height: 75),
            ],
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final String title, svgSrc;
  final VoidCallback press;
  final bool isCollapsed;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 18,
      ),
      title: isCollapsed
          ? null
          : Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

