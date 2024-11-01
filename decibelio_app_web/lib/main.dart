import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decibelio_app_web/views/navigation/navigation_bloc.dart';
import 'package:decibelio_app_web/views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: MaterialApp(
        title: 'Decibelio App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),  // Ahora HomeScreen es la pantalla inicial
      ),
    );
  }
}