import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  void controlMenu(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    if (!scaffoldState.isDrawerOpen) {
      scaffoldState.openDrawer();
    }
  }
}
