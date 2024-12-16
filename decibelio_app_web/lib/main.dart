import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/views/dashboard/dashboard_screen.dart';
import 'package:decibelio_app_web/views/main/main_screen.dart';
import 'package:decibelio_app_web/views/sensor_create/components/sensor_create.dart';
import 'package:decibelio_app_web/views/sensor_create/sensor_screen.dart';
import 'package:decibelio_app_web/views/upload_data/components/upload_data.dart';
import 'package:decibelio_app_web/views/upload_data/upload_screen.dart';
//import 'package:decibelio_app_web/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decibelio_app_web/views/navigation/navigation_bloc.dart';
import 'package:decibelio_app_web/views/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  final _routes = {
    '/dashboard': (context) =>
        MainScreen(
          title: "Dashboard",
          color: Colors.redAccent,
        ),
    '/upload_data': (context) =>
        UploadScreen(title: "upload", color: Colors.white70),
    '/create_sensor': (context) =>
        SensorScreen(
          title: "Create Sensor",
          color: Colors.greenAccent,
        )
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuAppController>(
          create: (context) => MenuAppController(),
        ),
      ],
      child: AdaptiveTheme(
        dark: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF2A2D3E),
          cardColor: Colors.white70,
          scaffoldBackgroundColor: Color(0xFF212332),
          textTheme: GoogleFonts.poppinsTextTheme(Theme
              .of(context)
              .textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: Color(0xFF1D1B20),
        ),
        light: ThemeData.light().copyWith(
          primaryColor: Color(0xB3D3D3D3),
          cardColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(Theme
              .of(context)
              .textTheme)
              .apply(bodyColor: Colors.black),
          canvasColor: Color(0xFF0C2342),
        ),
        initial: AdaptiveThemeMode.dark,
        builder: (theme, darkTheme) {
          return BlocProvider(
            create: (_) => NavigationBloc(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'DECIBELIO',
              theme: theme,
              darkTheme: darkTheme,
              home: MainScreen(
                title: "Dashboard",
                color: Colors.redAccent,
              ),
              // Pantalla inicial
              initialRoute: '/',
              routes: _routes,
              onGenerateRoute: _appRouter.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}

/***/
