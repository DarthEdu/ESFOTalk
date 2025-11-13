# ESFOTalk - GitHub Copilot Instructions

## Architecture Overview

**ESFOTalk** es una aplicación Flutter tipo Twitter que usa **Appwrite** como backend (BaaS). La arquitectura sigue un patrón **feature-first** con separación clara entre capas:

- **Backend**: Appwrite (autenticación, base de datos, almacenamiento, realtime)
- **Estado**: Riverpod para gestión de estado reactivo
- **Error Handling**: FpDart (`Either<Failure, T>`) para manejo funcional de errores
- **Modelos**: Clases inmutables con `copyWith`, `toMap`, `fromMap`

### Estructura de directorios

```
lib/
├── apis/          # Capa de comunicación con Appwrite
├── common/        # Widgets compartidos (error_page, loading_page, rounded_small_button)
├── constants/     # Constantes de Appwrite, assets, UI
├── core/          # Tipos base (Failure, FutureEither), providers, enums, utils
├── features/      # Features organizados por dominio
│   ├── auth/
│   ├── roar/      # Posts/tweets (llamados "roars")
│   ├── explore/
│   ├── notifications/
│   ├── user_profile/
│   └── home/
├── models/        # Modelos de datos (UserModel, Roar, Notification)
└── theme/         # AppTheme y Pallete
```

## Patrones Clave

### 1. Feature Structure (Patrón repetido en cada feature)

Cada feature sigue esta estructura consistente:

```
features/<feature_name>/
├── controller/    # StateNotifier + Providers de Riverpod
├── view/         # Screens/Pages
└── widgets/      # Componentes UI específicos del feature
```

**Ejemplo** (`lib/features/auth/`):

- `controller/auth_controller.dart` - StateNotifier + providers
- `view/login_view.dart`, `view/signup_view.dart` - Pantallas
- `widgets/auth_field.dart` - Widget de input

### 2. API Layer Pattern

Todas las APIs siguen el mismo patrón abstracto + implementación:

```dart
// Interfaz abstracta con métodos
abstract class IAuthApi {
  FutureEither<User> signUp({required String email, required String password});
  Future<User?> currentUserAccount();
}

// Implementación concreta inyectada por Provider
class AuthAPI implements IAuthApi {
  final Account _account;
  final Realtime _realtime;

  AuthAPI({required Account account, required Realtime realtime})
    : _account = account, _realtime = realtime;

  // Implementación de métodos...
}

// Provider de Riverpod
final authAPIProvider = Provider((ref) {
  return AuthAPI(
    account: ref.watch(appwriteAccountProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});
```

**APIs existentes**: `auth_api.dart`, `roar_api.dart`, `user_api.dart`, `notification_api.dart`, `storage_api.dart`.

### 3. Controller Pattern con Riverpod

Los controladores extienden `StateNotifier<bool>` donde el estado es `isLoading`:

```dart
final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
    : _authAPI = authAPI, _userAPI = userAPI, super(false);

  void signUp({required String email, required String password, required BuildContext context}) async {
    state = true; // isLoading = true
    final res = await _authAPI.signUp(email: email, password: password);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => { /* success */ }
    );
  }
}
```

### 4. Error Handling con FpDart

**NUNCA** uses `try-catch` tradicional en la capa de negocio. Usa `Either<Failure, T>`:

```dart
// Type definitions en core/type_defs.dart
typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;

// En APIs
FutureEither<User> signUp(...) async {
  try {
    final user = await _account.create(...);
    return right(user); // Success
  } on AppwriteException catch (e, st) {
    return left(Failure(e.message ?? 'Error inesperado', st)); // Error
  }
}

// En Controllers
res.fold(
  (failure) => showSnackBar(context, failure.message), // left = error
  (success) => Navigator.push(...),                     // right = success
);
```

### 5. Providers Appwrite (core/providers.dart)

Todos los servicios Appwrite se exponen como providers:

```dart
final appwriteClientProvider = Provider((ref) => ...);
final appwriteAccountProvider = Provider((ref) => Account(client));
final appwriteDatabaseProvider = Provider((ref) => Databases(client));
final appwriteStorageProvider = Provider((ref) => Storage(client));
final appwriteRealtimeProvider = Provider((ref) => Realtime(client));
```

### 6. Modelo Inmutable Pattern

Todos los modelos son `@immutable` con:

```dart
@immutable
class UserModel {
  final String email;
  final String name;
  // ... otros campos

  const UserModel({required this.email, required this.name, ...});

  UserModel copyWith({String? email, String? name, ...}) { ... }

  Map<String, dynamic> toMap() { ... }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // IMPORTANTE: uid viene de '$id' en Appwrite
    return UserModel(uid: map['\$id'] ?? '', ...);
  }

  @override
  bool operator ==(Object other) { ... }

  @override
  int get hashCode { ... }
}
```

### 7. Realtime con Streams

Para datos en tiempo real usa `StreamProvider`:

```dart
final getRoarsProvider = StreamProvider.autoDispose((ref) async* {
  final roarAPI = ref.watch(roarAPIProvider);
  final documents = await roarAPI.getRoars();
  yield documents.map((doc) => Roar.fromMap(doc.data)).toList();

  await for (final event in roarAPI.getLatestRoars()) {
    // Escuchar eventos realtime de Appwrite
    // ...
  }
});
```

## Convenciones Importantes

### Nombres y Terminología

- **"Roar"** = Post/Tweet (el término específico de esta app)
- **"Dragonred"** = Cuenta verificada (equivalente a Twitter Blue)
- Controladores: `<Feature>Controller` (ej. `AuthController`, `RoarController`)
- APIs: `<Feature>API` (ej. `AuthAPI`, `RoarAPI`)
- Vistas: `<Name>View` (ej. `SignUpView`, `LoginView`)

### Imports y Exports

- Usa archivos barrel (`common.dart`, `core.dart`, `theme.dart`, `constants.dart`) para agrupar exports
- Importa desde el barrel: `import 'package:esfotalk_app/common/common.dart';`
- Las constantes de Appwrite están en `constants/appwrite_constants.dart`

### UI y UX

- **SnackBars**: Usa `showSnackBar(context, message, type: SnackBarType.error)` de `core/utils.dart`
  - Tipos: `info`, `success`, `warning`, `error`
- **Loading**: `const Loader()` o `const LoadingPage()` de `common/`
- **Navegación**: Usa `static route() => MaterialPageRoute(...)` en cada View

### Image Handling

```dart
// Múltiples imágenes
final images = await pickImages(imageQuality: 80);

// Una imagen de galería
final image = await pickImageFromGallery(imageQuality: 80);

// Una imagen de cámara
final image = await pickImageFromCamera(imageQuality: 80);

// URLs de imágenes (Appwrite)
final url = AppwriteConstants.imageUrl(imageId);
```

### Appwrite Specific

- Database ID, Project ID, endpoints están en `AppwriteConstants`
- IDs de colecciones: `usersTable`, `roarTable`, `notificationTable`
- Bucket: `imagesBucket`
- **IMPORTANTE**: El campo `uid` en modelos mapea a `$id` de Appwrite documents

## Flujos de Trabajo Comunes

### Crear un nuevo feature

1. Crear carpeta en `lib/features/<feature_name>/`
2. Estructura: `controller/`, `view/`, `widgets/`
3. Si necesita API, crear `lib/apis/<feature_name>_api.dart` con patrón Interface + Implementation
4. Definir providers en el controller
5. Si requiere modelo, crearlo en `lib/models/<feature_name>_model.dart`

### Agregar autenticación a una vista

```dart
class MyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider);

    return currentUser.when(
      data: (user) => user != null ? ActualContent() : LoginView(),
      error: (err, st) => ErrorPage(error: err.toString()),
      loading: () => const LoadingPage(),
    );
  }
}
```

### Manejar formularios

- Usa `TextEditingController` en `StatefulWidget`
- Valida en el método `_onSubmit()` local antes de llamar al controller
- Muestra errores con `showSnackBar(context, error, type: SnackBarType.error)`
- Observa `isLoading` con `ref.watch(controllerProvider)` para mostrar `Loader()`

### Flujo de Autenticación

**IMPORTANTE**: El registro NO inicia sesión automáticamente para evitar problemas de caché:

```dart
// En AuthController.signUp():
// 1. Crear cuenta en Appwrite
// 2. Guardar UserModel en la base de datos
// 3. Mostrar mensaje de éxito
// 4. Redirigir a LoginView (NO a HomeView)
// El usuario debe iniciar sesión manualmente después del registro
```

**NOTA**: No se requiere verificación de email. El sistema no incluye verificación de cuentas por email.

## Testing y Debug

- **Linting**: Sigue `package:flutter_lints/flutter.yaml`
- **Run**: `flutter run`
- **Build**: `flutter build apk` / `flutter build ios`

## Notas Específicas de Appwrite

- Usa `setSelfSigned(status: true)` en desarrollo local (ver `core/providers.dart`)
- Permisos de documentos: `Permission.read(Role.users())`, `Permission.write(Role.user(uid))`
- Queries: `Query.orderDesc(r'$createdAt')`, `Query.limit(100)`

## Idioma

- La app está en **español**: textos UI, mensajes de error, comentarios en español
- Nombres de variables y clases en inglés (estándar de programación)
