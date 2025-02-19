import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdaptiveTheme.of(context).theme.canvasColor,
      child: ListView(
        children: [
          DrawerHeader(
              child: Column(
            children: [
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
              )),
              const SizedBox(height: 8),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(color: Colors.white70, width: 1)),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding, vertical: 20)),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centra el contenido
                    children: [
                      SvgPicture.asset(
                        "assets/icons/google_color_svgrepo_com.svg", // Cambia la ruta al archivo correspondiente
                        height: 16, // Tamaño del ícono
                      ),
                      const SizedBox(width: 8),
                      const Text("Accede con Google")
                    ],
                  )),
            ],
          )),
        DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              //Navigator.pushNamed(context, '/dashboard');
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
            title: "Crear sensor",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.pushReplacementNamed(context, '/create_sensor');
            },
          ),  /*DrawerListTile(
            title: "Documents",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Store",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Notification",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),*/
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    // For selecting those three line once press "Command+D"
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
