# Iconos de ESFOTalk

## Archivos necesarios

Coloca los siguientes archivos en esta carpeta (`assets/icon/`):

### 1. `app_icon.png`
- **Tamaño**: 1024x1024 px (mínimo 512x512)
- **Formato**: PNG con transparencia
- **Uso**: Icono principal de la app en launcher (iOS y Android legacy)
- **Contenido**: Logo completo de ESFOTalk con fondo transparente

### 2. `app_icon_foreground.png` 
- **Tamaño**: 1024x1024 px
- **Formato**: PNG con transparencia
- **Uso**: Capa frontal para Android Adaptive Icons
- **Contenido**: Solo el logo/símbolo sin fondo
- **Nota**: El sistema Android agregará el fondo vinotinto (#8B0000) automáticamente

### 3. `splash_logo.png`
- **Tamaño**: 1200x1200 px (recomendado para múltiples densidades)
- **Formato**: PNG con transparencia
- **Uso**: Logo que aparece en el splash screen al abrir la app
- **Contenido**: Logo ESFOTalk centrado, se mostrará sobre fondo negro

## Diseño recomendado

**Paleta de colores ESFOTalk:**
- Fondo dark: `#000000` (negro)
- Acento principal: `#8B0000` (vinotinto/dragonred)
- Texto/iconos claros: `#FFFFFF` (blanco)

**Sugerencias de diseño:**
- Logo simple y reconocible (evita texto pequeño que se vea borroso)
- Alto contraste para visibilidad
- Mantén el área de seguridad (safe zone) de 15% desde los bordes en adaptive icon
- Usa el logo del proyecto actual si ya tienes uno

## Generación automática

Una vez que coloques las imágenes aquí, ejecuta:

```bash
# Instalar dependencias
flutter pub get

# Generar iconos
dart run flutter_launcher_icons

# Generar splash screen
dart run flutter_native_splash:create

# Limpiar y compilar
flutter clean
flutter build apk --release
```

## Verificación

Después de generar, verifica:
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (iconos generados)
- `android/app/src/main/res/drawable/launch_background.xml` (splash)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (iconos iOS)

## Alternativa rápida (placeholder temporal)

Si no tienes diseño aún, puedes usar temporalmente:
- Logo genérico con iniciales "ET" (ESFOTalk)
- Fondo vinotinto con símbolo de "rugido" o megáfono
- Herramientas online: https://www.appicon.co/ o Canva

---

**Nota**: Los archivos de imagen NO están incluidos en el repositorio. Debes crearlos o solicitarlos al diseñador del proyecto.
