"""
modelos_prioridad2.py — constructores de los modelos de prioridad 2 (ART-003):
cápsulas, relojes, piezas del legado y mascotas.

Convención: X = ancho, Y = fondo (el FRENTE mira a -Y), Z = arriba; 1 unidad = 1 stud.
Tamaños: relojes y piezas ≈ 1,4 studs; mascotas ≈ 1,6; cápsulas ≈ 2 × 3.
"""

import math

import arte_comun as A

FRENTE = (math.pi / 2, 0, 0)  # gira discos para que su cara mire a -Y

# ---------------------------------------------------------------------------
# Cápsulas (Criadero, Premios, Robux)
# ---------------------------------------------------------------------------


def capsula(nombre, color, estrellas=False):
    piezas = [
        A.esfera("arriba", 1, (0, 0, 1.9), color, segmentos=12, anillos=6, escala=(1, 1, 1.15)),
        A.esfera("abajo", 1, (0, 0, 1.1), "blanco", segmentos=12, anillos=6),
        A.cilindro("anillo", 1.05, 0.25, (0, 0, 1.5), "dorado", lados=12),
        A.cilindro("pie", 0.7, 0.3, (0, 0, 0.15), "gris_oscuro", lados=12),
    ]
    if estrellas:
        for i in range(5):
            angulo = 2 * math.pi * i / 5
            piezas.append(A.cono("estrella", 0.18, 0, 0.35,
                                 (math.cos(angulo) * 0.95, math.sin(angulo) * 0.95, 2.1), "cian", lados=4))
        piezas.append(A.esfera("orbe", 0.25, (0, 0, 3.2), "cian", segmentos=6, anillos=3))
    return A.unir(nombre, piezas)


# ---------------------------------------------------------------------------
# Relojes (marcadores de las vitrinas del plot)
# ---------------------------------------------------------------------------


def _esfera_reloj(radio, z, caja, cara="blanco", lados=16):
    """Caja redonda con esfera y agujas, mirando a -Y."""
    return [
        A.cilindro("caja", radio, 0.25, (0, 0, z), caja, lados=lados, rot=FRENTE),
        A.cilindro("cara", radio * 0.82, 0.27, (0, -0.01, z), cara, lados=lados, rot=FRENTE),
        A.caja("aguja_h", (0.06, 0.05, radio * 0.45), (0, -0.16, z + radio * 0.2), "negro"),
        A.caja("aguja_m", (radio * 0.6, 0.05, 0.05), (radio * 0.28, -0.17, z), "negro"),
    ]


def reloj_bolsillo():
    piezas = _esfera_reloj(0.55, 0.65, "dorado")
    piezas += [
        A.cilindro("corona", 0.1, 0.15, (0, 0, 1.27), "dorado", lados=8),
        A.anillo("aro", 0.15, 0.04, (0, 0, 1.42), "dorado", lados=8, rot=FRENTE),
    ]
    return A.unir("mdl_reloj_bolsillo", piezas)


def reloj_pulsera():
    piezas = [
        A.caja("caja", (0.8, 0.25, 0.8), (0, 0, 0.7), "gris"),
        A.caja("cara", (0.62, 0.27, 0.62), (0, -0.01, 0.7), "blanco"),
        A.caja("aguja_h", (0.05, 0.05, 0.22), (0, -0.16, 0.78), "negro"),
        A.caja("aguja_m", (0.3, 0.05, 0.05), (0.13, -0.17, 0.7), "negro"),
        A.caja("correa_arriba", (0.5, 0.2, 0.55), (0, 0.02, 1.35), "madera_oscura"),
        A.caja("correa_abajo", (0.5, 0.2, 0.55), (0, 0.02, 0.05), "madera_oscura"),
    ]
    return A.unir("mdl_reloj_pulsera", piezas)


def reloj_cronografo():
    piezas = _esfera_reloj(0.6, 0.7, "gris_oscuro", cara="azul_oscuro")
    for dx, dz in ((-0.25, -0.1), (0.25, -0.1), (0, -0.33)):
        piezas.append(A.cilindro("subesfera", 0.13, 0.29, (dx, -0.02, 0.7 + dz), "blanco", lados=10, rot=FRENTE))
    for dx in (-0.35, 0.35):
        piezas.append(A.caja("pulsador", (0.1, 0.12, 0.15), (dx, 0, 1.33), "gris"))
    piezas.append(A.cilindro("corona", 0.1, 0.2, (0, 0, 1.38), "gris", lados=8))
    return A.unir("mdl_reloj_cronografo", piezas)


def reloj_legado():
    piezas = _esfera_reloj(0.6, 0.7, "dorado", cara="blanco")
    piezas.append(A.anillo("bisel", 0.6, 0.06, (0, -0.1, 0.7), "cian", lados=16, rot=FRENTE))
    for i in range(4):
        angulo = math.pi / 2 * i
        piezas.append(A.esfera("gema", 0.08, (math.cos(angulo) * 0.45, -0.17, 0.7 + math.sin(angulo) * 0.45), "cian",
                               segmentos=6, anillos=3))
    piezas.append(A.cilindro("corona", 0.1, 0.2, (0, 0, 1.38), "dorado", lados=8))
    return A.unir("mdl_reloj_legado", piezas)


def reloj_real():
    piezas = _esfera_reloj(0.6, 0.7, "dorado", cara="madera_oscura")
    for i in range(12):
        angulo = 2 * math.pi * i / 12
        piezas.append(A.esfera("rubi", 0.06, (math.cos(angulo) * 0.55, -0.14, 0.7 + math.sin(angulo) * 0.55), "rojo",
                               segmentos=6, anillos=3))
    piezas.append(A.cono("corona_real", 0.18, 0.08, 0.2, (0, 0, 1.4), "dorado", lados=6))
    return A.unir("mdl_reloj_real", piezas)


def reloj_millonario():
    piezas = _esfera_reloj(0.65, 0.75, "dorado", cara="negro")
    for i in range(16):
        angulo = 2 * math.pi * i / 16
        piezas.append(A.cono("diamante", 0.06, 0, 0.12, (math.cos(angulo) * 0.6, -0.15, 0.75 + math.sin(angulo) * 0.6),
                             "blanco", lados=4, rot=FRENTE))
    piezas.append(A.caja("aguja_oro", (0.05, 0.05, 0.3), (0, -0.18, 0.88), "dorado"))
    piezas.append(A.cilindro("corona", 0.12, 0.2, (0, 0, 1.48), "dorado", lados=8))
    return A.unir("mdl_reloj_millonario", piezas)


# ---------------------------------------------------------------------------
# Piezas del legado (introducción): ficticias, sin marcas reales
# ---------------------------------------------------------------------------


def legado_espiral():
    """Espiral Celestial: espiral plana de segmentos y gema central."""
    piezas = [A.esfera("gema", 0.15, (0, 0, 0.7), "cian", segmentos=8, anillos=4)]
    pasos = 26
    for i in range(pasos):
        t = i / pasos * 3 * math.pi
        radio = 0.12 + t * 0.06
        piezas.append(A.caja("tramo", (0.08, 0.08, 0.08), (math.cos(t) * radio, 0, 0.7 + math.sin(t) * radio), "dorado"))
    piezas.append(A.anillo("marco", 0.7, 0.04, (0, 0, 0.7), "blanco", lados=16, rot=FRENTE))
    return A.unir("mdl_legado_espiral", piezas)


def legado_corona():
    """Corona de Zafiro Real: aro con puntas y zafiros."""
    piezas = [A.cilindro("aro", 0.55, 0.35, (0, 0, 0.35), "dorado", lados=12)]
    for i in range(6):
        angulo = 2 * math.pi * i / 6
        x, y = math.cos(angulo) * 0.5, math.sin(angulo) * 0.5
        piezas.append(A.cono("punta", 0.15, 0, 0.4, (x, y, 0.72), "dorado", lados=4))
        piezas.append(A.esfera("zafiro", 0.09, (x, y, 0.95), "azul", segmentos=6, anillos=3))
    piezas.append(A.esfera("zafiro_central", 0.18, (0, -0.55, 0.35), "azul", segmentos=8, anillos=4))
    return A.unir("mdl_legado_corona", piezas)


def legado_rotor():
    """Rotor de Diamantes Arcoíris: disco con gemas de colores en el borde."""
    piezas = [
        A.cilindro("rotor", 0.6, 0.12, (0, 0, 0.7), "gris", lados=16, rot=FRENTE),
        A.cilindro("eje", 0.12, 0.2, (0, 0, 0.7), "dorado", lados=8, rot=FRENTE),
    ]
    colores = ["rojo", "naranja", "dorado", "verde", "azul", "morado"]
    for i in range(12):
        angulo = 2 * math.pi * i / 12
        piezas.append(A.cono("gema", 0.08, 0, 0.14, (math.cos(angulo) * 0.48, -0.08, 0.7 + math.sin(angulo) * 0.48),
                             colores[i % len(colores)], lados=4, rot=FRENTE))
    return A.unir("mdl_legado_rotor", piezas)


# ---------------------------------------------------------------------------
# Mascotas (PetService): ≈ 1,6 studs, cabeza hacia -Y
# ---------------------------------------------------------------------------


def _ojos(y, z, separacion=0.18, color="negro", radio=0.07):
    return [A.esfera("ojo", radio, (x, y, z), color, segmentos=6, anillos=3) for x in (-separacion, separacion)]


def mascota_raton():
    piezas = [
        A.esfera("cuerpo", 0.5, (0, 0.1, 0.5), "gris", segmentos=10, anillos=6, escala=(0.9, 1.2, 0.85)),
        A.esfera("cabeza", 0.35, (0, -0.55, 0.65), "gris", segmentos=10, anillos=6),
        A.cilindro("oreja", 0.2, 0.06, (-0.25, -0.5, 1.0), "rojo", lados=10, rot=FRENTE),
        A.cilindro("oreja", 0.2, 0.06, (0.25, -0.5, 1.0), "rojo", lados=10, rot=FRENTE),
        A.esfera("nariz", 0.06, (0, -0.9, 0.6), "rojo", segmentos=6, anillos=3),
        A.cilindro("cola", 0.04, 0.8, (0, 0.85, 0.35), "gris_oscuro", lados=6, rot=(math.pi / 2.5, 0, 0)),
        A.caja("llave_eje", (0.08, 0.08, 0.35), (0, 0.15, 1.05), "dorado"),
        A.caja("llave_ala", (0.5, 0.08, 0.2), (0, 0.15, 1.25), "dorado"),
    ]
    piezas += _ojos(-0.82, 0.75, 0.13)
    return A.unir("mdl_mascota_raton", piezas)


def mascota_gato():
    piezas = [
        A.caja("cuerpo", (0.7, 1.0, 0.6), (0, 0.1, 0.5), "naranja"),
        A.caja("cabeza", (0.7, 0.6, 0.6), (0, -0.55, 0.95), "naranja"),
        A.cono("oreja", 0.15, 0, 0.3, (-0.22, -0.55, 1.38), "naranja", lados=4),
        A.cono("oreja", 0.15, 0, 0.3, (0.22, -0.55, 1.38), "naranja", lados=4),
        A.caja("cola", (0.12, 0.12, 0.7), (0, 0.65, 0.95), "naranja"),
        A.cilindro("engranaje", 0.3, 0.1, (0.4, 0.1, 0.55), "bronce", lados=8, rot=(0, math.pi / 2, 0)),
    ]
    for x in (-0.25, 0.25):
        for y in (-0.25, 0.45):
            piezas.append(A.caja("pata", (0.18, 0.18, 0.25), (x, y, 0.12), "naranja"))
    piezas += _ojos(-0.86, 1.0, 0.16, "verde_oscuro")
    return A.unir("mdl_mascota_gato", piezas)


def mascota_zorro():
    piezas = [
        A.caja("cuerpo", (0.65, 1.0, 0.6), (0, 0.1, 0.5), "naranja"),
        A.caja("pecho", (0.5, 0.2, 0.45), (0, -0.38, 0.45), "blanco"),
        A.caja("cabeza", (0.65, 0.55, 0.55), (0, -0.55, 0.95), "naranja"),
        A.cono("hocico", 0.18, 0.05, 0.35, (0, -0.95, 0.85), "blanco", lados=4, rot=FRENTE),
        A.cono("oreja", 0.16, 0, 0.35, (-0.2, -0.5, 1.4), "naranja", lados=4),
        A.cono("oreja", 0.16, 0, 0.35, (0.2, -0.5, 1.4), "naranja", lados=4),
        A.cono("cola", 0.3, 0.05, 0.9, (0, 0.85, 0.75), "naranja", lados=6, rot=(-math.pi / 3, 0, 0)),
        A.anillo("monoculo", 0.1, 0.02, (0.17, -0.84, 1.0), "dorado", lados=8, rot=FRENTE),
    ]
    piezas += _ojos(-0.83, 1.0, 0.17)
    return A.unir("mdl_mascota_zorro", piezas)


def mascota_halcon():
    piezas = [
        A.esfera("cuerpo", 0.45, (0, 0, 0.75), "azul", segmentos=10, anillos=6, escala=(0.9, 1.1, 1.1)),
        A.esfera("cabeza", 0.3, (0, -0.4, 1.25), "cian", segmentos=8, anillos=5),
        A.cono("pico", 0.1, 0, 0.25, (0, -0.72, 1.2), "dorado", lados=4, rot=FRENTE),
        A.caja("ala", (0.9, 0.5, 0.08), (-0.75, 0.05, 0.95), "cian"),
        A.caja("ala", (0.9, 0.5, 0.08), (0.75, 0.05, 0.95), "cian"),
        A.caja("cola", (0.4, 0.5, 0.06), (0, 0.6, 0.6), "azul_oscuro"),
    ]
    piezas += _ojos(-0.65, 1.32, 0.12)
    return A.unir("mdl_mascota_halcon", piezas)


def mascota_dragon():
    piezas = [
        A.esfera("cuerpo", 0.5, (0, 0.1, 0.7), "verde", segmentos=10, anillos=6, escala=(0.9, 1.3, 0.9)),
        A.esfera("cabeza", 0.35, (0, -0.6, 1.15), "verde", segmentos=10, anillos=6, escala=(1, 1.2, 0.9)),
        A.cono("cuerno", 0.08, 0, 0.3, (-0.18, -0.5, 1.5), "blanco", lados=4),
        A.cono("cuerno", 0.08, 0, 0.3, (0.18, -0.5, 1.5), "blanco", lados=4),
        A.caja("ala", (0.8, 0.6, 0.06), (-0.7, 0.1, 1.15), "verde_oscuro"),
        A.caja("ala", (0.8, 0.6, 0.06), (0.7, 0.1, 1.15), "verde_oscuro"),
        A.cono("cola", 0.2, 0.03, 0.9, (0, 0.95, 0.55), "verde", lados=6, rot=(-math.pi / 2.3, 0, 0)),
        A.cilindro("reloj_pecho", 0.15, 0.06, (0, -0.42, 0.75), "dorado", lados=10, rot=FRENTE),
    ]
    piezas += _ojos(-1.0, 1.2, 0.15, "dorado")
    return A.unir("mdl_mascota_dragon", piezas)


def mascota_fenix():
    piezas = [
        A.esfera("cuerpo", 0.45, (0, 0, 0.8), "rojo", segmentos=10, anillos=6, escala=(0.9, 1.1, 1.1)),
        A.esfera("cabeza", 0.3, (0, -0.4, 1.3), "naranja", segmentos=8, anillos=5),
        A.cono("pico", 0.1, 0, 0.25, (0, -0.72, 1.25), "dorado", lados=4, rot=FRENTE),
        A.cono("cresta", 0.12, 0, 0.35, (0, -0.35, 1.7), "dorado", lados=4),
        A.caja("ala", (1.0, 0.5, 0.08), (-0.8, 0.05, 1.05), "naranja"),
        A.caja("ala", (1.0, 0.5, 0.08), (0.8, 0.05, 1.05), "naranja"),
    ]
    for i, color in enumerate(("dorado", "naranja", "rojo")):
        piezas.append(A.cono("llama", 0.18, 0, 0.7, ((i - 1) * 0.2, 0.7, 0.55), color, lados=4, rot=(-math.pi / 2.5, 0, 0)))
    piezas += _ojos(-0.65, 1.37, 0.12)
    return A.unir("mdl_mascota_fenix", piezas)


def mascota_titan():
    piezas = [
        A.caja("torso", (0.9, 0.6, 0.8), (0, 0, 0.9), "morado"),
        A.caja("cabeza", (0.5, 0.45, 0.45), (0, -0.05, 1.55), "morado"),
        A.caja("brazo", (0.3, 0.35, 0.8), (-0.65, 0, 0.75), "morado"),
        A.caja("brazo", (0.3, 0.35, 0.8), (0.65, 0, 0.75), "morado"),
        A.caja("pierna", (0.3, 0.35, 0.5), (-0.22, 0, 0.25), "morado"),
        A.caja("pierna", (0.3, 0.35, 0.5), (0.22, 0, 0.25), "morado"),
        A.cono("cristal", 0.15, 0, 0.45, (-0.3, 0.1, 1.45), "cian", lados=4),
        A.cono("cristal", 0.12, 0, 0.35, (0.35, 0.05, 1.4), "cian", lados=4),
        A.caja("visor", (0.4, 0.05, 0.1), (0, -0.3, 1.58), "cian"),
    ]
    return A.unir("mdl_mascota_titan", piezas)


def mascota_senor_tiempo():
    piezas = [
        A.cono("tunica", 0.5, 0.2, 1.1, (0, 0, 0.75), "azul_oscuro", lados=8),
        A.esfera("cabeza", 0.25, (0, 0, 1.5), "blanco", segmentos=8, anillos=5),
        A.cono("capucha", 0.32, 0, 0.4, (0, 0.05, 1.75), "azul_oscuro", lados=8),
        A.anillo("halo_reloj", 0.55, 0.04, (0, 0.25, 1.5), "dorado", lados=16, rot=FRENTE),
        A.esfera("orbe", 0.12, (0.45, -0.3, 1.0), "cian", segmentos=6, anillos=3),
    ]
    for i in range(12):
        angulo = 2 * math.pi * i / 12
        piezas.append(A.caja("marca", (0.05, 0.05, 0.1), (math.cos(angulo) * 0.55, 0.22, 1.5 + math.sin(angulo) * 0.55), "blanco"))
    piezas += _ojos(-0.22, 1.52, 0.08, "cian", 0.05)
    return A.unir("mdl_mascota_senor_tiempo", piezas)


def mascota_suprema():
    piezas = [
        A.esfera("cuerpo", 0.5, (0, 0, 0.8), "dorado", segmentos=12, anillos=6),
        A.caja("ala", (0.7, 0.4, 0.06), (-0.65, 0.1, 0.95), "blanco"),
        A.caja("ala", (0.7, 0.4, 0.06), (0.65, 0.1, 0.95), "blanco"),
        A.cilindro("corona", 0.25, 0.2, (0, 0, 1.38), "dorado", lados=8),
    ]
    for i in range(5):
        angulo = 2 * math.pi * i / 5
        piezas.append(A.cono("punta", 0.07, 0, 0.2, (math.cos(angulo) * 0.22, math.sin(angulo) * 0.22, 1.58), "dorado", lados=4))
    piezas.append(A.esfera("gema", 0.08, (0, -0.25, 1.4), "rojo", segmentos=6, anillos=3))
    piezas += _ojos(-0.46, 0.88, 0.16)
    return A.unir("mdl_mascota_suprema", piezas)


MODELOS = {
    "mdl_capsula_plata": lambda: capsula("mdl_capsula_plata", "gris"),
    "mdl_capsula_oro": lambda: capsula("mdl_capsula_oro", "dorado"),
    "mdl_capsula_cosmica": lambda: capsula("mdl_capsula_cosmica", "morado", estrellas=True),
    "mdl_reloj_bolsillo": reloj_bolsillo,
    "mdl_reloj_pulsera": reloj_pulsera,
    "mdl_reloj_cronografo": reloj_cronografo,
    "mdl_reloj_legado": reloj_legado,
    "mdl_reloj_real": reloj_real,
    "mdl_reloj_millonario": reloj_millonario,
    "mdl_legado_espiral": legado_espiral,
    "mdl_legado_corona": legado_corona,
    "mdl_legado_rotor": legado_rotor,
    "mdl_mascota_raton": mascota_raton,
    "mdl_mascota_gato": mascota_gato,
    "mdl_mascota_zorro": mascota_zorro,
    "mdl_mascota_halcon": mascota_halcon,
    "mdl_mascota_dragon": mascota_dragon,
    "mdl_mascota_fenix": mascota_fenix,
    "mdl_mascota_titan": mascota_titan,
    "mdl_mascota_senor_tiempo": mascota_senor_tiempo,
    "mdl_mascota_suprema": mascota_suprema,
}
