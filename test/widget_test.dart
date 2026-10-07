import 'dart:ui';

import 'package:colorear_ninos/models/dibujo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const texto = '{"id":"cuadro","nombre":"Cuadro","regiones":['
      '{"id":"a","path":"M 100 100 L 500 100 L 500 500 L 100 500 Z"}]}';

  test('un dibujo se lee y sus regiones saben si les tocan un punto', () {
    final dibujo = Dibujo.desdeTexto(texto);
    expect(dibujo.nombre, 'Cuadro');
    expect(dibujo.regiones.length, 1);
    expect(dibujo.regiones.first.path.contains(const Offset(300, 300)), isTrue);
    expect(dibujo.regiones.first.path.contains(const Offset(700, 700)), isFalse);
  });

  test('un texto roto da un error entendible', () {
    expect(() => Dibujo.desdeTexto('hola'), throwsFormatException);
  });
}
