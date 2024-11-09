library easy_sidemenu;

export 'package:decibelio_app_web/views/sidemenu/side_menu_controller.dart';
export 'package:decibelio_app_web/views/sidemenu/side_menu.dart';
export 'package:decibelio_app_web/views/sidemenu/side_menu_display_mode.dart';
export 'package:decibelio_app_web/views/sidemenu/side_menu_item.dart';
export 'package:decibelio_app_web/views/sidemenu/side_menu_expansion_item.dart';
export 'package:decibelio_app_web/views/sidemenu/side_menu_style.dart';

import 'package:decibelio_app_web/views/map_page.dart';
import 'package:decibelio_app_web/views/sensor_create.dart';
import 'package:decibelio_app_web/views/sidemenu.dart';
import 'package:decibelio_app_web/views/subir_dato.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              // showTooltip: false,
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: Colors.blue[100],
              selectedHoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.all(Radius.circular(10)),
              // ),
              // backgroundColor: Colors.grey[200]
            ),
            title: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                    maxWidth: 150,
                  ),
                  child: ClipOval(
                 child: SvgPicture.string(
  '''
  <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
    <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0"/>
    <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1"/>
  </svg>
  ''',
  width: 60,
  height: 60,
)

                  ),
                ),
                const Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
            ),
            /**footer: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: Text(
                    'mohada',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                ),
              ),
            ),*/
            items: [
              SideMenuItem(
                title: 'Mapa',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.home),
                //badgeContent: const Text(
                  //'5',
                  //style: TextStyle(color: Colors.white),
                //),
                tooltipContent: "Mira los sensores dispersos en el mapa",
              ),
              SideMenuItem(
                title: 'Subir Datos',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.supervisor_account),
              ),
              /**SideMenuExpansionItem(
                title: "Expansion Item",
                icon: const Icon(Icons.kitchen),
                children: [
                  SideMenuItem(
                    title: 'Expansion Item 1',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                    icon: const Icon(Icons.home),
                    badgeContent: const Text(
                      '3',
                      style: TextStyle(color: Colors.white),
                    ),
                    tooltipContent: "Expansion Item 1",
                  ),
                  SideMenuItem(
                    title: 'Expansion Item 2',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                    icon: const Icon(Icons.supervisor_account),
                  )
                ],
              ),*/
              SideMenuItem(
                title: 'Crear Sensor',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.file_copy_rounded),
                /**trailing: Container(
                    decoration: const BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 3),
                      child: Text(
                        'New',
                        style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                      ),
                    )),*/
              ),
              /*SideMenuItem(
                title: 'Download',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.download),
              ),
              SideMenuItem(
                builder: (context, displayMode) {
                  return const Divider(
                    endIndent: 8,
                    indent: 8,
                  );
                },
              ),
              SideMenuItem(
                title: 'Settings',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.settings),
              ),*/
              // SideMenuItem(
              //   onTap:(index, _){
              //     sideMenu.changePage(index);
              //   },
              //   icon: const Icon(Icons.image_rounded),
              // ),
              // SideMenuItem(
              //   title: 'Only Title',
              //   onTap:(index, _){
              //     sideMenu.changePage(index);
              //   },
              // ),
              const SideMenuItem(
                title: 'Exit',
                icon: Icon(Icons.exit_to_app),
              ),
            ],
          ),
          const VerticalDivider(
            width: 0,
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: AnimatedMapControllerPage(title: "Map Screen",
                        color: Colors.blueAccent),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: SubirDatoControllerPage(title: "Second Screen",
                      color: Colors.redAccent)
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: SensorCreateControllerPage(title: "Thirst Screen",
                      color: Colors.greenAccent),
                  ),
                ),
                /**Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Expansion Item 2',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Files',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Download',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),

                // this is for SideMenuItem with builder (divider)
                const SizedBox.shrink(),

                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
