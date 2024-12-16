import 'package:flutter/material.dart';

/**class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}*/
class MenuAppController extends ChangeNotifier {
  void controlMenu(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    if (!scaffoldState.isDrawerOpen) {
      scaffoldState.openDrawer();
    }
  }
}
