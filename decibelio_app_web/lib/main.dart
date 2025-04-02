import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/views/main/main_screen.dart';
import 'package:decibelio_app_web/views/sensor_create/sensor_screen.dart';
import 'package:decibelio_app_web/views/upload_data/upload_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decibelio_app_web/views/navigation/navigation_bloc.dart';
import 'package:decibelio_app_web/views/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  final _routes = {
    '/dashboard': (context) =>
        const MainScreen(
          title: "Dashboard",
          color: Colors.redAccent,
        ),
    '/upload_data': (context) =>
        const UploadScreen(title: "upload", color: Colors.white70),
    '/manage_sensor': (context) =>
        const SensorScreen(
          title: "Create Sensor",
          color: Colors.greenAccent,
        )
  };

  MyApp({super.key});

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
          primaryColor: const Color(0xFF2A2D3E),
          cardColor: Colors.white70,
          scaffoldBackgroundColor: const Color(0xFF212332),
          textTheme: GoogleFonts.poppinsTextTheme(Theme
              .of(context)
              .textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: const Color(0xFF1D1B20),
        ),
        light: ThemeData.light().copyWith(
          primaryColor: Colors.white,
          cardColor: Colors.black,
          scaffoldBackgroundColor: Colors.white70,
          textTheme: GoogleFonts.poppinsTextTheme(Theme
              .of(context)
              .textTheme)
              .apply(bodyColor: Colors.black),
          canvasColor: const Color(0xFF0C2342),
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
              home: const MainScreen(
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
