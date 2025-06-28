import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

/// Utilidad para mostrar diálogos de manera centralizada.
class DialogUtils {
  /// Muestra un diálogo de éxito con un ícono y título 'Éxito'.
  static void showSuccessDialog(BuildContext context, String message,
      {String title = "Éxito"}) {
    // Evita usar context si el widget ya está desmontado
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 30),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (context.mounted) Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: AdaptiveTheme.of(context)
                  .theme
                  .buttonTheme
                  .colorScheme
                  ?.primary,
              foregroundColor: AdaptiveTheme.of(context)
                  .theme
                  .buttonTheme
                  .colorScheme
                  ?.onPrimary,
            ),
            child: const Text(
              'OK',
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de error con un ícono y título 'Error'.
  static void showErrorDialog(BuildContext context, String message,
      {String title = "Error"}) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AdaptiveTheme.of(context)
                  .theme
                  .buttonTheme
                  .colorScheme
                  ?.primary,
              foregroundColor: AdaptiveTheme.of(context)
                  .theme
                  .buttonTheme
                  .colorScheme
                  ?.onPrimary,
            ),
            onPressed: () {
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de advertencia con un ícono y título 'Advertencia'.
  static void showWarningDialog(BuildContext context, String message) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Advertencia'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AdaptiveTheme.of(context)
                  .theme
                  .buttonTheme
                  .colorScheme
                  ?.primary,
              foregroundColor: AdaptiveTheme.of(context)
                  .theme
                  .buttonTheme
                  .colorScheme
                  ?.onPrimary,
            ),
            onPressed: () {
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
