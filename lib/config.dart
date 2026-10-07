import 'package:flutter/material.dart';

/// Ajustes de la app. Cambia estos valores para afinar cómo se siente.
class Ajustes {
  Ajustes._();

  /// Los dibujos se definen en un cuadrado de 1000 x 1000 unidades y estos
  /// grosores usan esas mismas unidades (100 = un 10% del ancho del dibujo).
  ///
  /// Más grosor = se cubre más área con cada pasada del dedo.
  static const double grosorPincel = 100;

  /// Grosor de la línea negra de los contornos.
  static const double grosorContorno = 10;

  /// Color de fondo de las pantallas (el "papel" de los dibujos es blanco).
  static const Color fondoApp = Color(0xFFFFF4D6);

  /// Colores del menú de pintura. El último (blanco) sirve de borrador.
  /// Puedes agregar o quitar colores; conviene dejar una cantidad par.
  static const List<Color> paleta = <Color>[
    Color(0xFFE53935), // rojo
    Color(0xFFFB8C00), // naranja
    Color(0xFFFDD835), // amarillo
    Color(0xFF7CB342), // verde
    Color(0xFF00ACC1), // turquesa
    Color(0xFF1E88E5), // azul
    Color(0xFF8E24AA), // morado
    Color(0xFFEC407A), // rosado
    Color(0xFF8D6E63), // café
    Color(0xFFFFFFFF), // blanco (borrador)
  ];
}
