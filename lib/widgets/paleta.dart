import 'package:flutter/material.dart';

/// Los colores para elegir: círculos grandes, en dos filas de cinco.
class Paleta extends StatelessWidget {
  const Paleta({
    super.key,
    required this.colores,
    required this.seleccionado,
    required this.alElegir,
  });

  final List<Color> colores;
  final Color seleccionado;
  final ValueChanged<Color> alElegir;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        const espacio = 10.0;
        // Cinco círculos por fila, con un poquito de holgura.
        final tamano = ((restricciones.maxWidth - espacio * 4 - 2) / 5)
            .clamp(40.0, 76.0)
            .toDouble();
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: espacio,
          runSpacing: espacio,
          children: [
            for (final color in colores)
              _Gota(
                color: color,
                tamano: tamano,
                elegido: color == seleccionado,
                alTocar: () => alElegir(color),
              ),
          ],
        );
      },
    );
  }
}

class _Gota extends StatelessWidget {
  const _Gota({
    required this.color,
    required this.tamano,
    required this.elegido,
    required this.alTocar,
  });

  final Color color;
  final double tamano;
  final bool elegido;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final esClaro = color.computeLuminance() > 0.9;
    final colorBorde = elegido
        ? Colors.black87
        : (esClaro ? Colors.black26 : Colors.white);
    return GestureDetector(
      onTap: alTocar,
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: AnimatedScale(
          scale: elegido ? 1.18 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: colorBorde, width: elegido ? 5 : 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
