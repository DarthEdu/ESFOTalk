import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Tipos de severidad para el SnackBar.
enum SnackBarType { info, success, warning, error }

/// Muestra un [SnackBar] con estilos según la severidad y acción opcional.
/// Parámetros:
/// - [text]: mensaje principal.
/// - [type]: severidad (info por defecto).
/// - [actionLabel] y [onAction]: si ambos se proveen se añade un botón.
/// - [duration]: duración personalizada (por defecto 3s info/success, 4.5s warning/error).
void showSnackBar(
  BuildContext context,
  String text, {
  SnackBarType type = SnackBarType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  // Colores base según severidad (sin depender de theme para evitar crashes)
  late final Color background;
  late final IconData icon;
  switch (type) {
    case SnackBarType.info:
      background = const Color(0xFF424242); // gris oscuro
      icon = Icons.info_outline;
      break;
    case SnackBarType.success:
      background = const Color(0xFF43A047); // verde
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.warning:
      background = const Color(0xFFE65100); // naranja
      icon = Icons.warning_amber_outlined;
      break;
    case SnackBarType.error:
      background = const Color(0xFFD32F2F); // rojo
      icon = Icons.error_outline;
      break;
  }

  final snackBarDuration =
      duration ??
      (type == SnackBarType.warning || type == SnackBarType.error
          ? const Duration(milliseconds: 4500)
          : const Duration(milliseconds: 3000));

  final content = Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Colors.white),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ],
  );

  final actionProvided = actionLabel != null && onAction != null;
  messenger.showSnackBar(
    SnackBar(
      content: content,
      duration: snackBarDuration,
      backgroundColor: background,
      action: actionProvided
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

String getNameFromEmail(String email) => email.split('@')[0];

/// Convierte una lista de [XFile] a [File].
List<File> _xFilesToFiles(List<XFile> files) =>
    files.map((x) => File(x.path)).toList();

/// Seleccionar múltiples imágenes desde la galería.
Future<List<File>> pickImages({int? imageQuality}) async {
  final picker = ImagePicker();
  final xFiles = await picker.pickMultiImage(imageQuality: imageQuality);
  if (xFiles.isEmpty) return [];
  return _xFilesToFiles(xFiles);
}

/// Seleccionar una única imagen. Por defecto galería.
Future<File?> pickSingleImage({
  ImageSource source = ImageSource.gallery,
  int? imageQuality,
}) async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(
    source: source,
    imageQuality: imageQuality,
  );
  return xFile == null ? null : File(xFile.path);
}

/// Helper explícito cámara.
Future<File?> pickImageFromCamera({int? imageQuality}) =>
    pickSingleImage(source: ImageSource.camera, imageQuality: imageQuality);

/// Helper explícito galería.
Future<File?> pickImageFromGallery({int? imageQuality}) =>
    pickSingleImage(source: ImageSource.gallery, imageQuality: imageQuality);

/// Wrapper retrocompatible (deprecado) para el antiguo nombre pickImage().
@Deprecated(
  'Usa pickSingleImage(), pickImageFromGallery() o pickImageFromCamera()',
)
Future<File?> pickImage() => pickSingleImage();
