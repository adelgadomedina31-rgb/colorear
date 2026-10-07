# Colorear — app para colorear, sin anuncios

App Android hecha con Flutter para que una niña de 3 años pinte dibujos simples en blanco y negro.
No tiene anuncios, no usa internet y no pide cuentas.

## Cómo funciona

- Se elige un color abajo y se pasa el dedo sobre el dibujo: el pincel es muy grueso, así que cada pasada cubre un área parcialmente.
- El color queda siempre **dentro de la zona** donde empezó el dedo; aunque se salga de las líneas, no se sale la pintura.
- Botones grandes arriba: **inicio**, **anterior**, **siguiente** y **borrar lo pintado** (este pide confirmación).
- El menú principal muestra los dibujos con lo que ya se pintó. Se tocan y se abren.
- Viene con 4 dibujos: sol, flor, pez y casa.
- **Zona de papás**: mantener presionado el engranaje gris (arriba a la derecha del menú) para agregar dibujos nuevos.

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
5. Opcional: para que el nombre bajo el ícono sea "Colorear", cambia `android:label` en `android/app/src/main/AndroidManifest.xml`.

## Consejo para que ella no se salga de la app

En Android puedes **fijar la pantalla** (en Ajustes busca "Fijar app" o "Fijar pantalla", según el celular). Con la app fijada no se puede salir sin el gesto o el código de desbloqueo.

## Agregar dibujos nuevos

Cada dibujo es un texto (JSON). Para sumarlo al celular sin tocar el código:

1. Copia el texto del dibujo en el celular.
2. Abre la app y mantén presionado el engranaje del menú.
3. Toca **Pegar** y luego **Guardar**. El dibujo aparece al final del menú.

Los dibujos agregados quedan guardados en el celular y se pueden borrar desde la misma pantalla. Si guardas uno con el mismo `id` que otro que ya agregaste, lo reemplaza.

Para dejar un dibujo "de fábrica" dentro de la app: guarda el `.json` en `assets/drawings/`, agrega su nombre en `assets/drawings/indice.json` y vuelve a compilar.

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
| Grosor del pincel, grosor de los contornos, colores | `lib/config.dart` |
| Cómo se pinta con el dedo | `lib/widgets/lienzo.dart` |
| Pantalla de pintar (botones, posición de la paleta) | `lib/pantallas/pantalla_pintar.dart` |
| Menú de dibujos | `lib/pantallas/pantalla_inicio.dart` |
| Zona de papás | `lib/pantallas/pantalla_padres.dart` |
| Formato y lectura de dibujos | `lib/models/dibujo.dart` |
| Los 4 dibujos de fábrica | `assets/drawings/*.json` (se generan con `tools/generar_dibujos.py`) |

La carpeta `tools/` tiene dos scripts de Python opcionales: `generar_dibujos.py` crea los dibujos y `vista_previa.py` (necesita matplotlib) hace una imagen para revisar un dibujo antes de pasarlo al celular.

## Ideas para mejorar

- Guardar lo pintado aunque se cierre la app.
- Un sonido suave o una carita feliz al terminar un dibujo.
- Ícono propio de la app.
- Cargar dibujos desde un archivo en vez de pegar texto.
- Más dibujos, o categorías (animales, vehículos...).
