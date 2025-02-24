import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/main/components/side_menu.dart';
import 'package:decibelio_app_web/views/upload_data/components/upload_data.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatelessWidget {
  final String title;
  final Color color;

  const UploadScreen({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (newContext) {
        return Scaffold(
          //key: newContext.read<MenuAppController>().scaffoldKey,
          drawer: const SideMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  const Expanded(
                    child: SideMenu(),
                  ),
                const Expanded(
                  flex: 5,
                  child: SubirDatoControllerPage(
                    title: "Upload Data",
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

