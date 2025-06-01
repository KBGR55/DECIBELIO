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
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthService.getUser(); // Map<String,dynamic> o null
    final token = await AuthService.getToken(); // String? o null

    setState(() {
      _user = user;
      _token = token;
    });

    // ————————————————
    // DEBUG: imprimimos la URL cruda y su versión "trim()"
    if (_user != null) {
      final raw = _user!['photo'] as String?;
      // 1) Quitamos espacios/saltos de línea en toda la cadena:
      final noWhites = raw?.replaceAll(RegExp(r'\s+'), '');
      print("DEBUG → noWhitespacePhoto = [$noWhites]");

      // 2) Transformamos “=s100” a “=s60” para evitar 429 en desarrollo:
      final small = noWhites?.replaceAllMapped(
        RegExp(r'=s\d+$'),
        (m) => '=s60',
      );
      print("DEBUG → using smallPhoto = $small");

      // 3) Guardamos la URL depurada en el mapa:
      _user!['photo'] = small;
    }
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
                  // Si no hay usuario, muestro avatar genérico + botón para iniciar Google login
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
                      // Llevamos al usuario al endpoint de Google para que Google devuelva ?code=…
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
                  // Si ya hay user, muestro su foto y nombre
                  ClipOval(
                    child: Image.network(
                      // Ya hemos hecho _user!['photo'] = trimmed, así que aquí no habrá saltos ni espacios.
                      _user!['photo']!,
                      height: 60, // <-- e igual alto fijo
                      fit: BoxFit.cover,
                      // Si por alguna razón falla la descarga (429, CORS o URL inválida), entra aquí:
                      errorBuilder: (context, error, stackTrace) {
                        return SvgPicture.string(
                          '''
        <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
          <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0"/>
          <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1"/>
        </svg>
        ''',
                          width: 60,
                          height: 60,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_user!['firstName']} ${_user!['lastName']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user!['email'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      // Cerrar sesión
                      await AuthService.logout();
                      setState(() {
                        _user = null;
                        _token = null;
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

          // == MENÚ == //
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          DrawerListTile(
            title: "Subir datos",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushReplacementNamed(context, '/upload_data');
            },
          ),
          DrawerListTile(
            title: "Administrar sensores",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.pushReplacementNamed(context, '/manage_sensor');
            },
          ),
          // … otros items …
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
