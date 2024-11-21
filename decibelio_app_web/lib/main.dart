import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/views/main/main_screen.dart';
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
    '/dashboard': (context) => MainScreen()
  };

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        dark: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF2A2D3E),
          cardColor: Colors.white70,
          scaffoldBackgroundColor: Color(0xFF212332),
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: Color(0xFF1D1B20),
        ),
        light: ThemeData.light().copyWith(
          primaryColor: Color(0xB3D3D3D3),
          //primaryColor: Color(0xFF0B243A),
          cardColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          //scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
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
              home: MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => MenuAppController(),
                  ),
                ],
                child: MainScreen(),
              ), // Ahora HomeScreen es la pantalla inicial
              //home:  MyHomePage(title: "Sensores"),
              //initialRoute: '/second',
              //routes: _routes,
              onGenerateRoute: _appRouter.onGenerateRoute,
            ),
          );
        });
  }
}

/***/
