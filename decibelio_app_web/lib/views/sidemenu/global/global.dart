import 'package:decibelio_app_web/views/sidemenu/side_menu_display_mode.dart';
import 'package:decibelio_app_web/views/sidemenu/side_menu_style.dart';
import 'package:decibelio_app_web/views/sidemenu/side_menu_controller.dart';
import 'package:flutter/widgets.dart';

class Global {
  late SideMenuController controller;
  late SideMenuStyle style;
  DisplayModeNotifier displayModeState = DisplayModeNotifier(SideMenuDisplayMode.auto);
  bool showTrailing = true;
  List<Function> itemsUpdate = [];
  List items = [];
  List<bool> expansionStateList = [];
}

class DisplayModeNotifier extends ValueNotifier<SideMenuDisplayMode> {
  DisplayModeNotifier(SideMenuDisplayMode value) : super(value);

  void change(SideMenuDisplayMode mode) {
    if (value != mode) {
      value = mode;
      notifyListeners();
    }
  }
}
