import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config.dart';
import '../models/dibujo.dart';
import '../models/pintura.dart';

/// Dibuja un dibujo junto con lo que se ha pintado. Se usa tanto en el
/// lienzo grande como en las miniaturas del menú.
class DibujoPainter extends CustomPainter {
  DibujoPainter({required this.dibujo, required this.pintura});

  final Dibujo dibujo;
  final List<List<Trazo>> pintura;

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / dibujo.lado;
    canvas.save();
    canvas.scale(escala, escala);

    final relleno = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final contorno = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = Ajustes.grosorContorno
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = Ajustes.grosorPincel
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Cada región: papel blanco, pintura recortada a su forma y contorno.
    // Las regiones de más abajo quedan tapadas por las de más arriba.
    for (var i = 0; i < dibujo.regiones.length; i++) {
      final region = dibujo.regiones[i];
      canvas.drawPath(region.path, relleno);
      final trazos = pintura[i];
      if (trazos.isNotEmpty) {
        canvas.save();
        canvas.clipPath(region.path);
        for (final trazo in trazos) {
          pincel.color = trazo.color;
          canvas.drawPath(trazo.camino, pincel);
        }
        canvas.restore();
      }
      canvas.drawPath(region.path, contorno);
    }

    // Adornos encima de todo (ojos, sonrisas...).
    final detalleRelleno = Paint()..style = PaintingStyle.fill;
    final detalleLinea = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    for (final detalle in dibujo.detalles) {
      final color = detalle.relleno;
      if (color != null) {
        detalleRelleno.color = color;
        canvas.drawPath(detalle.path, detalleRelleno);
      }
      if (detalle.grosor > 0) {
        detalleLinea.strokeWidth = detalle.grosor;
        canvas.drawPath(detalle.path, detalleLinea);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DibujoPainter oldDelegate) => true;
}

/// El lienzo donde se pinta con el dedo.
///
/// Cómo funciona: al tocar, la pasada de pincel queda "pegada" a la región
/// donde empezó el dedo (si empieza fuera de todo, se pega a la primera región
/// que toque). La pintura se recorta a la forma de esa región, así que aunque
/// el dedo se salga de las líneas el color no se sale.
class Lienzo extends StatefulWidget {
  const Lienzo({super.key, required this.dibujo, required this.color});

  final Dibujo dibujo;
  final Color color;

  @override
  State<Lienzo> createState() => _EstadoLienzo();
}

class _EstadoLienzo extends State<Lienzo> {
  int? _puntero; // el dedo que está pintando (se ignoran los demás)
  int? _region; // índice de la región donde se está pintando
  Trazo? _trazo;

  List<List<Trazo>> get _pintura => Pintura.de(widget.dibujo);

  int? _regionEn(Offset p) {
    final regiones = widget.dibujo.regiones;
    for (var i = regiones.length - 1; i >= 0; i--) {
      if (regiones[i].path.contains(p)) return i;
    }
    return null;
  }

  void _procesar(Offset local, double lado) {
    final p = local * (widget.dibujo.lado / lado);
    if (_region == null) {
      final i = _regionEn(p);
      if (i == null) return;
      final trazo = Trazo(widget.color, p);
      _region = i;
      _trazo = trazo;
      _pintura[i].add(trazo);
    } else {
      _trazo?.sumar(p);
    }
    setState(() {});
  }

  void _alBajar(PointerDownEvent e, double lado) {
    if (_puntero != null) return;
    _puntero = e.pointer;
    _region = null;
    _trazo = null;
    _procesar(e.localPosition, lado);
  }

  void _alMover(PointerMoveEvent e, double lado) {
    if (e.pointer != _puntero) return;
    _procesar(e.localPosition, lado);
  }

  void _alSoltar(PointerEvent e) {
    if (e.pointer != _puntero) return;
    _puntero = null;
    _region = null;
    _trazo = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final lado = math.min(restricciones.maxWidth, restricciones.maxHeight);
        return Center(
          child: SizedBox(
            width: lado,
            height: lado,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _alBajar(e, lado),
              onPointerMove: (e) => _alMover(e, lado),
              onPointerUp: _alSoltar,
              onPointerCancel: _alSoltar,
              child: CustomPaint(
                painter: DibujoPainter(
                  dibujo: widget.dibujo,
                  pintura: _pintura,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
