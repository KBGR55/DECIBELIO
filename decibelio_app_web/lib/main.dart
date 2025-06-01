import 'dart:convert';
import 'dart:html' as html;
import 'package:decibelio_app_web/views/manage_user/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:decibelio_app_web/services/auth_service.dart';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/controllers/menu_app_controller.dart';
import 'package:decibelio_app_web/views/main/main_screen.dart';
import 'package:decibelio_app_web/views/upload_data/upload_screen.dart';
import 'package:decibelio_app_web/views/sensor_create/sensor_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decibelio_app_web/views/navigation/navigation_bloc.dart';
import 'package:decibelio_app_web/views/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 1) Detectar si existe ?code=... en la URL
  final uri = Uri.parse(html.window.location.href);
  final code = uri.queryParameters['code'];

  if (code != null) {
    try {
      // 2) Llamar al backend para intercambiar code por token+user
      final RespuestaGenerica respuesta = await Conexion().solicitudGet(
        'auth/google/callback?code=$code',
        Conexion.noToken,
      );

      if (respuesta.status == 'SUCCESS') {
        // 3) Parsear el JSON recibido
        final Map<String, dynamic> decoded =
            jsonDecode(respuesta.payload as String);
        final Map<String, dynamic> payload =
            decoded['payload'] as Map<String, dynamic>;
        final Map<String, dynamic> userMap =
            payload['user'] as Map<String, dynamic>;
        final String token = payload['token'] as String;

        // 4) Guardar en SharedPreferences
        await AuthService.saveToken(token);
        await AuthService.saveUser(jsonEncode(userMap));
      }
    } catch (e) {
      // Si falla, podemos ignorarlo y seguir
    } finally {
      // 5) Limpiar la URL (quitar ?code=...)
      html.window.history.replaceState(null, 'Decibelio', '/');
    }
  }

  // 6) Finalmente arrancar la app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouter _appRouter = AppRouter();

  static final Map<String, WidgetBuilder> _routes = {
    '/dashboard': (context) => const MainScreen(
          title: "Dashboard",
          color: Colors.redAccent,
        ),
    '/upload_data': (context) =>
        const UploadScreen(title: "upload", color: Colors.white70),
    '/manage_sensor': (context) => const SensorScreen(
          title: "Create Sensor",
          color: Colors.greenAccent,
        ),
    '/manage_users': (context) => const UserScreen(
      title: "Manage User",
      color: Colors.cyan,
    ),
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
          primaryColor: const Color(0xFF2A2D3E),
          cardColor: Colors.white70,
          scaffoldBackgroundColor: const Color(0xFF212332),
          textTheme:
              GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                  .apply(bodyColor: Colors.white),
          canvasColor: const Color(0xFF1D1B20),
        ),
        light: ThemeData.light().copyWith(
          primaryColor: Colors.white,
          cardColor: Colors.black,
          scaffoldBackgroundColor: Colors.white70,
          textTheme:
              GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
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