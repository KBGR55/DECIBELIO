// lib/views/main/components/side_menu.dart

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdaptiveTheme.of(context).theme.canvasColor,
      child: ListView(
        children: [
          // == DRAWER HEADER == //
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_user == null) ...[
                  // Si no hay usuario, muestro avatar genérico + botón Google login
                  ClipOval(
                    child: SvgPicture.string(
                      '''
                      <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
                        <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0"/>
                        <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1"/>
                      </svg>
                      ''',
                      width: 60,
                      height: 60,
                    ),
                  ),
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
                ] else ...[
                  // Si hay usuario autenticado, muestro foto y datos
                  ClipOval(
                    child: Image.network(
                      _user!['photo']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SvgPicture.string(
                          '''
        <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
          <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0"/>
          <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1"/>
        </svg>
        ''',
                          width: 50,
                          height: 50,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_user!['firstName']} ${_user!['lastName']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _user!['email'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () async {
                      await AuthService.logout();
                      setState(() {
                        _user = null;
                      });
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

          // == MENÚ ==
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),

          // “Administrar Sensores” visible sólo para ADMINISTRADOR
          if (isAdministrador)
            DrawerListTile(
              title: "Administrar Sensores",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                Navigator.pushReplacementNamed(context, '/manage_sensor');
              },
            ),

          // “Administrar Usuarios” visible sólo para ADMINISTRADOR
          if (isAdministrador)
            DrawerListTile(
              title: "Administrar Usuarios",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                Navigator.pushReplacementNamed(context, '/manage_users');
              },
            ),
          // …otros ítems que sean globales o también condicionales…
          const Divider(color: Colors.white54),
          const ListTile(
            title: Text(
              "Proyectos de Vinculación con la Sociedad:",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          const ListTile(
            title: Text(
              "Estrategias para la gestión sostenible del ruido vehicular en la ciudad de Loja: Un enfoque innovador para ciudades urbanas.",
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Image.asset(
            'assets/logos/favicon-oscuro.png',
            height: 100,
          ),
          const SizedBox(height: 10),
          Image.asset(
            "assets/logos/logoUNL-HD.png",
            height: 75,
          ),
          const SizedBox(height: 10),
          Image.asset(
            "assets/logos/LogoCarreraNombre.png",
            height: 75,
          ),
          const SizedBox(height: 10),
          Image.asset(
            "assets/logos/logo_automotriz.png",
            height: 75,
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}