#!/usr/bin/env python3
"""Genera los dibujos iniciales en assets/drawings/*.json

Cada dibujo es un cuadrado de 1000 x 1000 unidades hecho de:
  - "regiones": zonas que se pueden pintar. Se dibujan en orden, así que las
    últimas quedan encima de las primeras (como capas).
  - "detalles": puntos o líneas decorativas (ojos, sonrisas...) que no se pintan.

Uso:  python3 tools/generar_dibujos.py
"""
import json
import math
import os

K = 0.5522847498307936  # constante para dibujar círculos con curvas Bézier


class Forma:
    """Un trazo SVG que usa solo comandos absolutos: M, L, C y Z."""

    def __init__(self):
        self.partes = []

    def M(self, x, y):
        self.partes.append(("M", x, y))
        return self

    def L(self, x, y):
        self.partes.append(("L", x, y))
        return self

    def C(self, x1, y1, x2, y2, x, y):
        self.partes.append(("C", x1, y1, x2, y2, x, y))
        return self

    def Z(self):
        self.partes.append(("Z",))
        return self

    def d(self):
        return " ".join(
            " ".join([p[0]] + ["%.1f" % v for v in p[1:]]) for p in self.partes
        )


def elipse(cx, cy, rx, ry, rot=0.0):
    c, s = math.cos(rot), math.sin(rot)

    def T(x, y):
        return (cx + x * c - y * s, cy + x * s + y * c)

    f = Forma()
    f.M(*T(rx, 0))
    tramos = [
        ((rx, K * ry), (K * rx, ry), (0, ry)),
        ((-K * rx, ry), (-rx, K * ry), (-rx, 0)),
        ((-rx, -K * ry), (-K * rx, -ry), (0, -ry)),
        ((K * rx, -ry), (rx, -K * ry), (rx, 0)),
    ]
    for a, b, fin in tramos:
        f.C(*T(*a), *T(*b), *T(*fin))
    return f.Z()


def circulo(cx, cy, r):
    return elipse(cx, cy, r, r)


def rect(x, y, w, h, tl=0, tr=0, br=0, bl=0):
    """Rectángulo con esquinas redondeadas opcionales (arriba-izq, arriba-der, abajo-der, abajo-izq)."""
    f = Forma()
    f.M(x + tl, y)
    f.L(x + w - tr, y)
    if tr:
        f.C(x + w - tr + K * tr, y, x + w, y + tr - K * tr, x + w, y + tr)
    f.L(x + w, y + h - br)
    if br:
        f.C(x + w, y + h - br + K * br, x + w - br + K * br, y + h, x + w - br, y + h)
    f.L(x + bl, y + h)
    if bl:
        f.C(x + bl - K * bl, y + h, x, y + h - bl + K * bl, x, y + h - bl)
    f.L(x, y + tl)
    if tl:
        f.C(x, y + tl - K * tl, x + tl - K * tl, y, x + tl, y)
    return f.Z()


def poligono(puntos):
    f = Forma()
    for i, (x, y) in enumerate(puntos):
        f.M(x, y) if i == 0 else f.L(x, y)
    return f.Z()


def hoja(bx, by, px, py, ancho):
    """Hoja con punta en los dos extremos: de (bx,by) a (px,py)."""
    dx, dy = px - bx, py - by
    largo = math.hypot(dx, dy)
    nx, ny = -dy / largo, dx / largo
    f = Forma()
    f.M(bx, by)
    f.C(bx + dx * 0.30 + nx * ancho, by + dy * 0.30 + ny * ancho,
        bx + dx * 0.70 + nx * ancho, by + dy * 0.70 + ny * ancho, px, py)
    f.C(bx + dx * 0.70 - nx * ancho, by + dy * 0.70 - ny * ancho,
        bx + dx * 0.30 - nx * ancho, by + dy * 0.30 - ny * ancho, bx, by)
    return f.Z()


def curva(x0, y0, x1, y1, x2, y2, x3, y3):
    """Línea curva abierta (para sonrisas, branquias...)."""
    return Forma().M(x0, y0).C(x1, y1, x2, y2, x3, y3)


def punto(x, y, r):
    """Punto negro relleno (ojos, perillas)."""
    return {"path": circulo(x, y, r).d(), "relleno": "#000000"}


def linea(forma, grosor=10):
    return {"path": forma.d(), "grosor": grosor}


def fondo():
    return rect(10, 10, 980, 980, 60, 60, 60, 60)


# ---------------------------------------------------------------- dibujos

def sol():
    cx, cy = 500, 500
    regiones = [("cielo", fondo())]
    for i in range(8):
        a = math.radians(i * 45)
        da = math.radians(17)
        punta = (cx + 420 * math.cos(a), cy + 420 * math.sin(a))
        b1 = (cx + 228 * math.cos(a - da), cy + 228 * math.sin(a - da))
        b2 = (cx + 228 * math.cos(a + da), cy + 228 * math.sin(a + da))
        regiones.append(("rayo%d" % (i + 1), poligono([b1, punta, b2])))
    regiones.append(("cara", circulo(cx, cy, 190)))
    detalles = [
        punto(440, 470, 20),
        punto(560, 470, 20),
        linea(curva(415, 545, 455, 625, 545, 625, 585, 545), 12),
    ]
    return "sol", "Sol", regiones, detalles


def flor():
    cx, cy = 500, 320
    regiones = [
        ("cielo", fondo()),
        ("tallo", rect(455, 320, 90, 540)),
        ("hoja_izq", hoja(455, 740, 262, 650, 70)),
        ("hoja_der", hoja(545, 740, 738, 650, 70)),
    ]
    for i, grados in enumerate([30, 90, 150, 210, 270, 330]):
        a = math.radians(grados)
        px, py = cx + 165 * math.cos(a), cy + 165 * math.sin(a)
        regiones.append(("petalo%d" % (i + 1), elipse(px, py, 105, 82, a)))
    regiones.append(("centro", circulo(cx, cy, 85)))
    regiones.append(("pasto", rect(10, 800, 980, 190, 0, 0, 60, 60)))
    detalles = [
        punto(470, 305, 10),
        punto(530, 305, 10),
        linea(curva(465, 345, 480, 372, 520, 372, 535, 345), 9),
    ]
    return "flor", "Flor", regiones, detalles


def pez():
    regiones = [
        ("agua", fondo()),
        ("burbuja1", circulo(110, 230, 62)),
        ("burbuja2", circulo(225, 108, 55)),
        ("cola", Forma().M(640, 500).L(900, 320).C(855, 430, 855, 570, 900, 680).Z()),
        ("aleta_arriba", Forma().M(300, 360).C(300, 190, 450, 110, 560, 360).Z()),
        ("aleta_abajo", Forma().M(360, 640).C(340, 800, 480, 840, 560, 640).Z()),
        ("cuerpo", elipse(430, 500, 270, 170)),
    ]
    detalles = [
        punto(270, 450, 26),
        linea(curva(190, 535, 215, 565, 245, 565, 265, 540), 10),
        linea(curva(345, 395, 310, 460, 310, 540, 345, 605), 10),
    ]
    return "pez", "Pez", regiones, detalles


def casa():
    regiones = [
        ("cielo", fondo()),
        ("sol", circulo(170, 170, 85)),
        ("pasto", rect(10, 780, 980, 210, 0, 0, 60, 60)),
        ("pared", rect(250, 430, 500, 390)),
        ("chimenea", rect(610, 230, 110, 190)),
        ("techo", poligono([(200, 450), (500, 200), (800, 450)])),
        ("puerta", rect(430, 590, 140, 230, 70, 70, 0, 0)),
        ("ventana_izq", rect(285, 500, 110, 110)),
        ("ventana_der", rect(605, 500, 110, 110)),
    ]
    rayos = Forma()
    for i in range(8):
        a = math.radians(i * 45)
        rayos.M(170 + 108 * math.cos(a), 170 + 108 * math.sin(a))
        rayos.L(170 + 142 * math.cos(a), 170 + 142 * math.sin(a))
    cruces = Forma()
    for x0 in (285, 605):
        cruces.M(x0 + 55, 500).L(x0 + 55, 610)
        cruces.M(x0, 555).L(x0 + 110, 555)
    detalles = [
        linea(rayos, 10),
        linea(cruces, 8),
        punto(535, 715, 13),
    ]
    return "casa", "Casa", regiones, detalles


def a_json(dibujo):
    id_, nombre, regiones, detalles = dibujo
    return {
        "id": id_,
        "nombre": nombre,
        "lado": 1000,
        "regiones": [{"id": rid, "path": f.d()} for rid, f in regiones],
        "detalles": detalles,
    }


def main():
    carpeta = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "drawings")
    carpeta = os.path.normpath(carpeta)
    os.makedirs(carpeta, exist_ok=True)
    archivos = []
    for fabrica in (sol, flor, pez, casa):
        datos = a_json(fabrica())
        nombre_archivo = datos["id"] + ".json"
        with open(os.path.join(carpeta, nombre_archivo), "w", encoding="utf-8") as f:
            json.dump(datos, f, ensure_ascii=False, indent=1)
            f.write("\n")
        archivos.append(nombre_archivo)
        print("listo:", nombre_archivo)
    with open(os.path.join(carpeta, "indice.json"), "w", encoding="utf-8") as f:
        json.dump(archivos, f, ensure_ascii=False, indent=1)
        f.write("\n")


if __name__ == "__main__":
    main()
