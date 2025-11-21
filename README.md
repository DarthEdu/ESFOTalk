# ESFOTalk

![Logo ESFOTalk](assets/icon/splash_logo.png)

Red social tipo Twitter construida con Flutter + Appwrite.

---

## Tabla de Contenido

1. [Descripción](#descripción)
2. [Arquitectura y Tecnologías](#arquitectura-y-tecnologías)
3. [Estructura de Directorios](#estructura-de-directorios)
4. [Principales Features](#principales-features)
5. [Gestión de Estado y Errores](#gestión-de-estado-y-errores)
6. [Realtime y Actualizaciones](#realtime-y-actualizaciones)
7. [Configuración de Entorno](#configuración-de-entorno)
8. [Build y Firma (APK/AAB)](#build-y-firma-apkaab)
9. [Permisos Android](#permisos-android)
10. [Icono y Splash Screen](#icono-y-splash-screen)
11. [Descarga del APK](#descarga-del-apk)
12. [Contribución](#contribución)
13. [Licencia](#licencia)

---

## Descripción

**ESFOTalk** es una aplicación móvil inspirada en Twitter/X donde los usuarios pueden publicar *roars* (posts), responder, dar like, reenviar (reshare) y seguir a otros perfiles. Construida para aprendizaje y demostración de arquitectura limpia con Flutter + Appwrite como Backend-as-a-Service.

## Arquitectura y Tecnologías

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter (Dart) |
| Estado | Riverpod (StateNotifier, FutureProvider, StreamProvider) |
| Backend | Appwrite (Auth, DB, Storage, Realtime) |
| Manejo de errores | FpDart (`Either<Failure, T>`) |
| Persistencia imágenes | Appwrite Storage |
| Iconos SVG | `flutter_svg` |
| Compresión imágenes | `flutter_image_compress` |

Patrón **feature-first**: cada dominio (auth, roar, explore, notifications, user_profile, home) tiene `controller/`, `view/`, `widgets/`.

## Estructura de Directorios

```text
lib/
 ├── apis/            # Comunicación Appwrite (AuthAPI, RoarAPI, UserAPI, etc.)
 ├── common/          # Widgets reutilizables (Loader, ErrorText, etc.)
 ├── constants/       # Constantes (AppwriteConstants, assets)
 ├── core/            # Tipos base, providers globales, utils
 ├── features/        # Features organizados por dominio
 │   ├── auth/
 │   ├── roar/
 │   ├── explore/
 │   ├── notifications/
 │   ├── user_profile/
 │   └── home/
 ├── models/          # Modelos inmutables (UserModel, Roar, NotificationModel)
 └── theme/           # Paleta y tema
```

## Principales Features

- Registro e inicio de sesión (email/password)
- Publicar roars con texto e imágenes
- Responder roars (vista `RoarReplyScreen` optimizada para teclado)
- Likes, reshares y contador de comentarios
- Perfiles con bio, banner y foto
- Seguidores / Siguiendo + notificación al ser seguido
- Feed en tiempo real (actualización por eventos Appwrite Realtime)
- Búsqueda por hashtags y usuarios

## Gestión de Estado y Errores

Los controladores extienden `StateNotifier<bool>` (indicando `isLoading`). Se usan:

- `FutureProvider` para cargas puntuales
- `StreamProvider` para feeds y perfiles en tiempo real

Errores manejados con `Either<Failure, T>`:

```dart
typedef FutureEither<T> = Future<Either<Failure, T>>;
res.fold((failure) => showSnackBar(context, failure.message), (value) => ...);
```

## Realtime y Actualizaciones

Se suscribe a canales Appwrite:

```dart
_realtime.subscribe([
  'databases.{dbId}.collections.{collectionId}.documents'
]).stream;
```

Los providers de roars procesan eventos `create/update/delete`. Para perfil se invalida el provider tras edición para reflejar cambios inmediatos.

## Configuración de Entorno

Archivo `lib/constants/appwrite_constants.dart`:

```dart
class AppwriteConstants {
  static const String databaseId = '...';
  static const String projectId  = '...';
  static const String endPoint   = 'https://sfo.cloud.appwrite.io/v1';
  // Tablas y bucket
}
```

Cliente Appwrite (`core/providers.dart`):

```dart
Client()
  .setEndpoint(AppwriteConstants.endPoint)
  .setProject(AppwriteConstants.projectId); // sin setSelfSigned en Cloud
```

## Build y Firma (APK/AAB)

Pasos para generar un APK/AAB firmado:

- Crear keystore

```bash
keytool -genkeypair -v -keystore /c/keystores/esfotalk-keystore.jks -alias esfotalk_key -keyalg RSA -keysize 2048 -validity 3650
```

- Crear archivo `android/key.properties`

```properties
storePassword=********
keyPassword=********
keyAlias=esfotalk_key
storeFile=C:/keystores/esfotalk-keystore.jks
```

- Configurar `signingConfigs` en `android/app/build.gradle.kts` (release)

- Compilar APK

```bash
flutter build apk --release
```

- Generar App Bundle (Play Store)

```bash
flutter build appbundle --release
```

## Permisos Android

Incluidos en `AndroidManifest.xml`:

`INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE (<=12)`, `POST_NOTIFICATIONS (>=13)`, `VIBRATE`.

## Icono y Splash Screen

Configurados en `pubspec.yaml` usando:

- `flutter_launcher_icons`
- `flutter_native_splash`

Agregar imágenes en `assets/icon/`:

```text
app_icon.png
app_icon_foreground.png
splash_logo.png
```

Generar:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Descarga del APK

Versión estable (release) compilada:

| Plataforma | Archivo | Estado |
|------------|---------|--------|
| Android | `release/ESFOTalk-v1.0.0.apk` | ✅ Disponible (añadir tras commit) |

### Cómo anexar el APK al repositorio

- Copiar archivo generado:

```text
build/app/outputs/flutter-apk/app-release.apk
```

- Renombrar a `ESFOTalk-v1.0.0.apk`

- Mover a carpeta dedicada:

```bash
mkdir release
mv build/app/outputs/flutter-apk/app-release.apk release/ESFOTalk-v1.0.0.apk
```

- Commit y push:

```bash
git add release/ESFOTalk-v1.0.0.apk
git commit -m "chore: add ESFOTalk v1.0.0 APK"
git push origin main
```

- (Recomendado) Crear un **GitHub Release** y subir el APK como asset.

> Nota: Evita subir muchos APK pesados al historial para no inflar el repositorio. Usa Releases cuando sea posible.

## Contribución

1. Haz fork del repositorio
2. Crea rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit descriptivo: `feat: agregar contador de comentarios`
4. Push y Pull Request

## Licencia

Proyecto educativo. Si se formaliza, añadir una licencia (MIT / Apache-2.0) aquí.

---

¿Sugerencias o mejoras? Abre un issue o PR. ¡Ruge tus ideas! 🐲
