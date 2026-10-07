import 'dart:ui';

import 'dibujo.dart';

/// Una pasada de pincel: un color y el camino que siguió el dedo.
class Trazo {
  Trazo(this.color, Offset inicio)
      : camino = Path()
          ..moveTo(inicio.dx, inicio.dy)
          // Un segmento minúsculo para que un simple toque deje un punto redondo.
          ..lineTo(inicio.dx + 0.01, inicio.dy);

  final Color color;
  final Path camino;

  void sumar(Offset punto) {
    camino.lineTo(punto.dx, punto.dy);
  }
}

/// Guarda lo que se ha pintado de cada dibujo mientras la app está abierta.
/// Para cada dibujo hay una lista de trazos por región.
class Pintura {
  Pintura._();

  static final Map<String, List<List<Trazo>>> _guardado =
      <String, List<List<Trazo>>>{};

  static List<List<Trazo>> de(Dibujo dibujo) {
    final actual = _guardado[dibujo.id];
    if (actual != null && actual.length == dibujo.regiones.length) {
      return actual;
    }
    final nuevo = List<List<Trazo>>.generate(
      dibujo.regiones.length,
      (_) => <Trazo>[],
    );
    _guardado[dibujo.id] = nuevo;
    return nuevo;
  }

  static void borrar(Dibujo dibujo) {
    _guardado.remove(dibujo.id);
  }
}
