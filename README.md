# ARVI — app para colorear, sin anuncios

App Android hecha con Flutter para que una niña de 3 años pinte dibujos simples en blanco y negro.
No tiene anuncios, no usa internet y no pide cuentas. En el celular se llama **ARVI** y el menú de
dibujos dice **COLOREA ARLETH**.

## Cómo funciona

- Se elige un color abajo y se pasa el dedo sobre el dibujo: el pincel es muy grueso, así que cada pasada cubre un área parcialmente.
- El color queda siempre **dentro de la zona** donde empezó el dedo; aunque se salga de las líneas, no se sale la pintura.
- Botones grandes arriba: **inicio**, **anterior**, **siguiente** y **borrar lo pintado** (este pide confirmación).
- El menú principal muestra los dibujos con lo que ya se pintó, de dos en dos. Se desliza hacia arriba y abajo con el dedo (la barra de la derecha muestra en qué parte de la lista va). Se toca un dibujo y se abre.
- Viene con **34 dibujos** (animales, frutas, vehículos, cosas del cielo y del jardín...).
- **Zona de papás**: mantener presionado el engranaje gris (arriba a la derecha del menú) para agregar dibujos nuevos.
- Lo pintado se conserva mientras la app siga abierta en el celular; si se cierra del todo, los dibujos vuelven a estar en blanco.

## Cómo sacar el APK

### Camino A — con GitHub (no instalas nada)

1. Crea una cuenta en github.com y un repositorio nuevo, privado (por ejemplo `colorear`).
2. Abre esta carpeta en VS Code, abre la Terminal y ejecuta (cambia `TU_USUARIO`):

   ```
   git init
   git add .
   git commit -m "Primera versión"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/colorear.git
   git push -u origin main
   ```

3. En GitHub entra a la pestaña **Actions**. El trabajo "Compilar APK" arranca solo y demora unos 5-10 minutos.
4. Cuando termine con el check verde, ábrelo y abajo, en **Artifacts**, descarga `colorear-apk`. Es un zip que contiene `app-release.apk`.
5. Pasa el APK al celular (cable, Drive, WhatsApp, correo) y ábrelo. Android te pedirá permitir instalar apps de fuentes desconocidas para la app desde la que lo abras.

Cada vez que cambies algo y hagas `git push`, se genera un APK nuevo. También puedes lanzarlo a mano desde Actions → Compilar APK → Run workflow.

**Instalar una versión nueva encima de la anterior:** la carpeta `signing/` contiene una firma fija
(`debug.keystore`). Gracias a ella, todos los APK que se compilen desde ahora tienen la misma firma y
se instalan **encima** del anterior, sin desinstalar. Mantén esa carpeta en el repositorio.
(Los APK compilados *antes* de existir esa carpeta tenían una firma al azar: la primera vez hay que
desinstalar la app vieja y luego instalar la nueva.)

### Camino B — en tu computadora

1. Instala Flutter (docs.flutter.dev/get-started/install), Android Studio (trae el SDK de Android) y la extensión *Flutter* de VS Code. Verifica con `flutter doctor`.
2. En esta carpeta, **solo la primera vez**, crea la parte Android (no toca tu código):

   ```
   flutter create --platforms=android --project-name colorear_ninos --org com.arvi .
   ```

3. Descarga las librerías y prueba en el celular (conectado por USB con depuración activada):

   ```
   flutter pub get
   flutter run
   ```

4. Para el APK: `flutter build apk --release`. Queda en `build/app/outputs/flutter-apk/app-release.apk`.
5. Para que el nombre bajo el ícono sea "ARVI", cambia `android:label` en `android/app/src/main/AndroidManifest.xml`.
   (En GitHub Actions esto se hace solo.)

## Consejo para que ella no se salga de la app

En Android puedes **fijar la pantalla** (en Ajustes busca "Fijar app" o "Fijar pantalla", según el celular). Con la app fijada no se puede salir sin el gesto o el código de desbloqueo.

## Agregar dibujos nuevos

Hay dos formas. Cada dibujo es un archivo de texto (JSON).

### Forma 1 — desde el celular (uno por uno, sin recompilar)

1. Copia el texto del dibujo en el celular.
2. Abre la app y mantén presionado el engranaje del menú.
3. Toca **Pegar** y luego **Guardar**. El dibujo aparece al final del menú.

Los dibujos agregados quedan guardados en el celular y se pueden borrar desde la misma pantalla. Si guardas uno con el mismo `id` que otro que ya agregaste, lo reemplaza.

### Forma 2 — dentro de la app, "de fábrica" (muchos de una vez)

1. Copia el archivo `.json` del dibujo a la carpeta `assets/drawings/`.
2. Abre `assets/drawings/indice.json` y agrega el nombre del archivo en la lista, **entre comillas y separado por comas**. El orden de la lista es el orden del menú.
3. Guarda y sube los cambios (`git add .`, `git commit -m "Más dibujos"`, `git push`). GitHub compila un APK nuevo con los dibujos incluidos.

El nombre dentro de `indice.json` debe ser exactamente el del archivo, y cada dibujo debe tener un `id` distinto.

### Formato de un dibujo

```json
{
  "id": "sol",
  "nombre": "Sol",
  "lado": 1000,
  "regiones": [
    {"id": "cielo", "path": "M 10 70 L 990 70 ... Z"},
    {"id": "cara",  "path": "M 690 500 C ... Z"}
  ],
  "detalles": [
    {"path": "M ... Z", "relleno": "#000000"},
    {"path": "M 415 545 C 455 625 545 625 585 545", "grosor": 12}
  ]
}
```

- El dibujo es un cuadrado de `lado` x `lado` (1000 por defecto). Las medidas de los trazos van en esas unidades.
- `regiones` son las zonas que se pintan. Se dibujan en orden: las últimas quedan **encima** de las primeras (así se hacen capas, por ejemplo el cielo primero y la casa después). Cada región es un trazo SVG cerrado.
- `detalles` son adornos que no se pintan: `relleno` (color `#RRGGBB`) para puntos como los ojos, `grosor` para líneas como las sonrisas. Es opcional.
- Conviene que cada región mida más de unas 110 unidades de ancho y de alto: el pincel mide 100.

## Dónde cambiar cosas

| Quiero cambiar… | Archivo |
|---|---|
| Nombre de la app bajo el ícono | `.github/workflows/compilar-apk.yml` (busca `android:label`) |
| Título del menú ("COLOREA ARLETH") y su cuadrícula | `lib/pantallas/pantalla_inicio.dart` |
| Grosor del pincel, grosor de los contornos, colores | `lib/config.dart` |
| Cómo se pinta con el dedo | `lib/widgets/lienzo.dart` |
| Pantalla de pintar (botones, posición de la paleta) | `lib/pantallas/pantalla_pintar.dart` |
| Zona de papás | `lib/pantallas/pantalla_padres.dart` |
| Formato y lectura de dibujos | `lib/models/dibujo.dart` |
| De dónde se cargan los dibujos | `lib/data/repositorio.dart` |
| Los 34 dibujos de fábrica | `assets/drawings/*.json` (se generan con `tools/generar_dibujos.py`) |
| Firma del APK | `signing/debug.keystore` |

La carpeta `tools/` tiene scripts de Python opcionales:

- `generar_dibujos.py` crea los 34 dibujos y el `indice.json`. Los dibujos están definidos en `dibujos_base.py`, `dibujos_animales.py` y `dibujos_cosas.py`; las herramientas para armarlos (círculos, óvalos, polígonos, curvas...) están en `formas.py`. Para correrlo: `python3 tools/generar_dibujos.py` (ojo: borra y vuelve a crear todos los `.json` de `assets/drawings/`).
- `vista_previa.py` (necesita `pip install matplotlib`) hace imágenes para revisar los dibujos antes de pasarlos al celular: `python3 tools/vista_previa.py vista.png` crea `vista_1.png`, `vista_2.png`... con 6 dibujos cada una.

## Ideas para mejorar

- Guardar lo pintado aunque se cierre la app.
- Un sonido suave o una carita feliz al terminar un dibujo.
- Ícono propio de la app.
- Cargar dibujos desde un archivo en vez de pegar texto.
- Categorías en el menú (animales, vehículos, comida...).
