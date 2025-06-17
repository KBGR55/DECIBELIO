import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isMenuOpen = true;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  bool get isMenuOpen => _isMenuOpen;


  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }

  void openMenu() {
    _isMenuOpen = true;
    notifyListeners();
  }

  void closeMenu() {
    _isMenuOpen = false;
    notifyListeners();
  }

  void controlMenu(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    if (!scaffoldState.isDrawerOpen) {
      scaffoldState.openDrawer();
    }
  }
}
