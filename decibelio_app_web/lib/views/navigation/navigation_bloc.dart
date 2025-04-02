import 'package:bloc/bloc.dart';

// Define los eventos de navegación
abstract class NavigationEvent {}

class NavigateToMapPage extends NavigationEvent {}
class NavigateToUploadPage extends NavigationEvent {}
class NavigateToHomePage extends NavigationEvent {}
class NavigateToSensorCreatePage extends NavigationEvent {}

// Bloc que maneja el estado de navegación
class NavigationBloc extends Bloc<NavigationEvent, String> {
  NavigationBloc() : super('/map') {
    // Define el manejo de eventos
    on<NavigateToHomePage>((event, emit) => emit('/'));
    on<NavigateToMapPage>((event, emit) => emit('/map'));
    on<NavigateToUploadPage>((event, emit) => emit('/upload'));
    on<NavigateToSensorCreatePage>((event, emit) => emit('/manage_sensor'));
  }
}
