"""
modelos_prioridad3.py — ambiente de las zonas (ART-004) y formas de los iconos del HUD.

Convención: X = ancho, Y = fondo (el FRENTE mira a -Y), Z = arriba; 1 unidad = 1 stud.
Los iconos (ICONOS) se renderizan de frente con iconos.py; no se exportan como FBX.
"""

import math

import arte_comun as A

FRENTE = (math.pi / 2, 0, 0)

# ---------------------------------------------------------------------------
# Ambiente
# ---------------------------------------------------------------------------


def arbol():
    piezas = [A.cilindro("tronco", 0.6, 5, (0, 0, 2.5), "madera_oscura", lados=6)]
    for i, (radio, z) in enumerate(((3.2, 5.5), (2.5, 7.5), (1.7, 9.3))):
        piezas.append(A.cono("copa", radio, 0.2, 2.6, (0, 0, z), ("verde", "verde_oscuro", "verde")[i], lados=7))
    return A.unir("mdl_arbol", piezas)


def arbusto():
    piezas = [
        A.esfera("mata", 1.4, (0, 0, 1.0), "verde", segmentos=7, anillos=4, escala=(1.2, 1, 0.8)),
        A.esfera("mata", 1.0, (1.2, 0.3, 0.8), "verde_oscuro", segmentos=7, anillos=4),
        A.esfera("mata", 0.9, (-1.1, -0.2, 0.7), "verde_oscuro", segmentos=7, anillos=4),
    ]
    return A.unir("mdl_arbusto", piezas)


def farola():
    piezas = [
        A.cilindro("base", 0.6, 0.6, (0, 0, 0.3), "gris_oscuro", lados=8),
        A.cilindro("poste", 0.18, 9, (0, 0, 5), "gris_oscuro", lados=8),
        A.caja("brazo", (0.2, 1.6, 0.2), (0, -0.7, 9.3), "gris_oscuro"),
        A.caja("lampara", (0.8, 0.8, 0.9), (0, -1.4, 8.9), "dorado"),
        A.cono("sombrero", 0.7, 0.1, 0.5, (0, -1.4, 9.55), "gris_oscuro", lados=6),
    ]
    return A.unir("mdl_farola", piezas)


def banca():
    piezas = [
        A.caja("asiento", (5, 1.4, 0.3), (0, 0, 1.4), "madera"),
        A.caja("respaldo", (5, 0.3, 1.2), (0, 0.65, 2.3), "madera"),
    ]
    for x in (-2.1, 2.1):
        piezas.append(A.caja("pata", (0.3, 1.3, 1.3), (x, 0, 0.65), "gris_oscuro"))
        piezas.append(A.caja("apoyo", (0.3, 0.3, 1.4), (x, 0.65, 2.1), "gris_oscuro"))
    return A.unir("mdl_banca", piezas)


def valla():
    """Tramo de valla de 8 studs."""
    piezas = [
        A.caja("larguero", (8, 0.25, 0.35), (0, 0, 1.1), "blanco"),
        A.caja("larguero", (8, 0.25, 0.35), (0, 0, 2.2), "blanco"),
    ]
    for x in (-3.5, -1.75, 0, 1.75, 3.5):
        piezas.append(A.caja("tabla", (0.6, 0.3, 3), (x, 0, 1.5), "blanco"))
        piezas.append(A.cono("punta", 0.42, 0, 0.4, (x, 0, 3.2), "blanco", lados=4))
    return A.unir("mdl_valla", piezas)


def roca():
    piezas = [
        A.esfera("roca", 1.6, (0, 0, 0.9), "gris", segmentos=6, anillos=4, escala=(1.2, 1, 0.7)),
        A.esfera("roca", 0.9, (1.3, 0.4, 0.5), "gris_oscuro", segmentos=6, anillos=3),
    ]
    return A.unir("mdl_roca", piezas)


def cartel_zona():
    piezas = [
        A.caja("poste", (0.4, 0.4, 7), (0, 0, 3.5), "madera_oscura"),
        A.caja("tabla", (5, 0.3, 2.2), (0, -0.3, 6.2), "madera"),
        A.caja("marco", (5.3, 0.25, 0.25), (0, -0.3, 7.35), "madera_oscura"),
    ]
    return A.unir("mdl_cartel_zona", piezas)


def caja_madera():
    piezas = [A.caja("caja", (2, 2, 2), (0, 0, 1), "madera")]
    for z in (0.2, 1.8):
        piezas.append(A.caja("fleje", (2.05, 2.05, 0.2), (0, 0, z), "madera_oscura"))
    piezas.append(A.caja("diagonal", (0.25, 2.06, 2.6), (0, 0, 1), "madera_oscura"))
    piezas[-1].rotation_euler = (0, math.radians(45), 0)
    return A.unir("mdl_caja_madera", piezas)


MODELOS = {
    "mdl_arbol": arbol,
    "mdl_arbusto": arbusto,
    "mdl_farola": farola,
    "mdl_banca": banca,
    "mdl_valla": valla,
    "mdl_roca": roca,
    "mdl_cartel_zona": cartel_zona,
    "mdl_caja_madera": caja_madera,
}

# ---------------------------------------------------------------------------
# Formas de los iconos (se ven de frente, desde -Y)
# ---------------------------------------------------------------------------


def icono_monedas():
    return [A.cilindro("moneda", 1.1, 0.35, (x, 0, z), "dorado", lados=14, rot=FRENTE)
            for x, z in ((-0.7, -0.5), (0.7, -0.3), (0, 0.6))] + [
        A.cilindro("relieve", 0.7, 0.4, (0, -0.05, 0.6), "bronce", lados=14, rot=FRENTE)]


def icono_velocidad():
    # Rayo dibujado por su contorno
    rayo = [(0.45, 1.7), (-0.95, -0.05), (-0.1, -0.05), (-0.55, -1.7), (0.95, 0.3), (0.1, 0.3)]
    return [
        A.prisma_poligono("rayo", rayo, 0.4, (0, 0, 0), "dorado"),
        A.prisma_poligono("brillo", [(x * 0.55, z * 0.55) for x, z in rayo], 0.45, (0.05, -0.05, 0.05), "naranja"),
    ]


def icono_mochila():
    return [
        A.caja("cuerpo", (2, 1, 2.4), (0, 0, 0), "naranja"),
        A.caja("bolsillo", (1.4, 0.3, 0.9), (0, -0.6, -0.5), "bronce"),
        A.anillo("asa", 0.5, 0.12, (0, 0, 1.35), "madera_oscura", lados=10, rot=FRENTE),
    ]


def icono_premios():
    return [
        A.caja("caja", (2.2, 1, 1.7), (0, 0, -0.4), "rojo"),
        A.caja("tapa", (2.5, 1.1, 0.5), (0, 0, 0.65), "rojo"),
        A.caja("cinta_v", (0.4, 1.15, 2.3), (0, -0.02, -0.05), "dorado"),
        A.anillo("lazo", 0.35, 0.12, (-0.4, -0.1, 1.15), "dorado", lados=8, rot=FRENTE),
        A.anillo("lazo", 0.35, 0.12, (0.4, -0.1, 1.15), "dorado", lados=8, rot=FRENTE),
    ]


def icono_ruleta():
    colores = ["rojo", "dorado", "azul", "verde", "morado", "naranja"]
    piezas = [A.cilindro("borde", 1.65, 0.3, (0, 0.08, 0), "blanco", lados=24, rot=FRENTE)]
    for i in range(6):
        # Gajo: porción de tarta con 4 tramos de arco
        a1, a2 = 2 * math.pi * i / 6, 2 * math.pi * (i + 1) / 6
        contorno = [(0, 0)] + [(math.cos(a1 + (a2 - a1) * k / 4) * 1.45, math.sin(a1 + (a2 - a1) * k / 4) * 1.45) for k in range(5)]
        piezas.append(A.prisma_poligono("gajo", contorno, 0.3, (0, -0.05, 0), colores[i]))
    piezas.append(A.cilindro("centro", 0.3, 0.45, (0, -0.15, 0), "gris_oscuro", lados=10, rot=FRENTE))
    piezas.append(A.cono("puntero", 0.3, 0, 0.6, (0, -0.15, 1.85), "gris_oscuro", lados=3, rot=(math.pi, 0, 0)))
    return piezas


def icono_robux():
    return [
        A.cilindro("hexagono", 1.5, 0.3, (0, 0, 0), "verde", lados=6, rot=FRENTE),
        A.cilindro("hueco", 0.8, 0.35, (0, -0.02, 0), "blanco", lados=6, rot=FRENTE),
        A.cilindro("centro", 0.45, 0.4, (0, -0.04, 0), "verde_oscuro", lados=6, rot=FRENTE),
    ]


def icono_ajustes():
    piezas = [A.cilindro("disco", 1.1, 0.35, (0, 0, 0), "gris", lados=16, rot=FRENTE)]
    for i in range(8):
        angulo = 2 * math.pi * i / 8
        piezas.append(A.caja("diente", (0.45, 0.35, 0.45), (math.cos(angulo) * 1.25, 0, math.sin(angulo) * 1.25), "gris"))
    piezas.append(A.cilindro("hueco", 0.45, 0.4, (0, -0.03, 0), "gris_oscuro", lados=12, rot=FRENTE))
    return piezas


def icono_carga():
    return [
        A.caja("caja", (2, 1, 1.6), (0, 0, -0.3), "madera"),
        A.caja("fleje", (2.05, 1.05, 0.25), (0, 0, 0.2), "madera_oscura"),
        A.cono("flecha", 0.7, 0, 0.8, (0, -0.1, 1.15), "verde", lados=4),
        A.caja("flecha_cuerpo", (0.4, 0.3, 0.6), (0, -0.1, 0.6), "verde"),
    ]


ICONOS = {
    "ico_monedas": icono_monedas,
    "ico_velocidad": icono_velocidad,
    "ico_mochila": icono_mochila,
    "ico_premios": icono_premios,
    "ico_ruleta": icono_ruleta,
    "ico_robux": icono_robux,
    "ico_ajustes": icono_ajustes,
    "ico_carga": icono_carga,
}
