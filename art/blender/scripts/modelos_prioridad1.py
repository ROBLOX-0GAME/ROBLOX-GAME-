"""
modelos_prioridad1.py — constructores de los modelos de prioridad 1 (ART-002).

Convención: X = ancho, Y = fondo (el FRENTE mira a -Y), Z = arriba; 1 unidad = 1 stud.
Las medidas coinciden con las piezas provisionales del código (ver Pipeline-de-Arte §7).
Cada función devuelve un único objeto (una malla) listo para exportar.
"""

import math

import arte_comun as A

# ---------------------------------------------------------------------------
# Plot (PlotService)
# ---------------------------------------------------------------------------


def plot_suelo():
    """Suelo del plot 34 × 40 con borde."""
    piezas = [A.caja("losa", (34, 40, 0.4), (0, 0, 0.2), "gris")]
    for x in (-16.75, 16.75):
        piezas.append(A.caja("borde_x", (0.5, 40, 0.6), (x, 0, 0.3), "gris_oscuro"))
    for y in (-19.75, 19.75):
        piezas.append(A.caja("borde_y", (34, 0.5, 0.6), (0, y, 0.3), "gris_oscuro"))
    # Camino central hacia el taller
    piezas.append(A.caja("camino", (4, 30, 0.45), (0, 2, 0.22), "blanco"))
    return A.unir("mdl_plot_suelo", piezas)


def taller():
    """Mesa de elaboración 14 × 4 (alto 3,5) con panel de herramientas."""
    piezas = [
        A.caja("tablero", (14, 4, 0.4), (0, 0, 3.3), "madera"),
        A.caja("panel", (14, 0.3, 3.5), (0, 1.85, 5.25), "madera_oscura"),
        A.caja("estante", (13, 0.8, 0.2), (0, 1.4, 5.8), "madera"),
        A.caja("tornillo_banco", (1.2, 1, 0.8), (-5.5, -1, 3.9), "gris_oscuro"),
        A.cilindro("lampara", 0.4, 0.6, (5.5, -0.5, 3.8), "dorado", lados=8),
    ]
    for x in (-6.5, 6.5):
        for y in (-1.6, 1.6):
            piezas.append(A.caja("pata", (0.4, 0.4, 3.1), (x, y, 1.55), "madera_oscura"))
    for i, x in enumerate((-3, -1, 1, 3)):
        piezas.append(A.cilindro("engranaje_decor", 0.45, 0.15, (x, 1.6, 4.6 + (i % 2) * 0.6), "bronce", lados=10,
                                 rot=(math.pi / 2, 0, 0)))
    return A.unir("mdl_taller", piezas)


def vitrina():
    """Vitrina 2 × 2 (alto 2,5): base y urna de cristal."""
    piezas = [
        A.caja("base", (2, 2, 1.6), (0, 0, 0.8), "blanco"),
        A.caja("moldura", (2.2, 2.2, 0.2), (0, 0, 1.7), "dorado"),
        A.caja("urna", (1.6, 1.6, 0.8), (0, 0, 2.2), "cian"),
        A.caja("tapa", (1.8, 1.8, 0.1), (0, 0, 2.65), "dorado"),
    ]
    return A.unir("mdl_vitrina", piezas)


def panel_plot():
    """Panel del plot 4 × 2 (alto 4): quiosco con pantalla."""
    piezas = [
        A.caja("pie", (1, 1, 2.4), (0, 0, 1.2), "gris_oscuro"),
        A.caja("cuerpo", (4, 1.4, 2.2), (0, 0, 3.3), "azul_oscuro"),
        A.caja("pantalla", (3.4, 0.1, 1.6), (0, -0.72, 3.3), "cian"),
    ]
    return A.unir("mdl_panel_plot", piezas)


# ---------------------------------------------------------------------------
# Estaciones del muro frontal (WorldService / BossService / PetService)
# ---------------------------------------------------------------------------


def _estacion_base(color_techo, color_cartel):
    """Mostrador 14 × 8 (alto 5) con techo y cartel, igual que la pieza provisional."""
    piezas = [
        A.caja("mostrador", (14, 8, 5), (0, 0, 2.5), "madera"),
        A.caja("encimera", (14.4, 8.4, 0.4), (0, 0, 5.2), "madera_oscura"),
        A.caja("techo", (18, 12, 1), (0, 0, 11), color_techo),
        A.caja("cartel", (10, 0.4, 2.5), (0, -6.2, 9), color_cartel),
    ]
    for x in (-8, 8):
        for y in (-5, 5):
            piezas.append(A.caja("columna", (1, 1, 10.5), (x, y, 5.25), "blanco"))
    return piezas


def estacion_tienda():
    piezas = _estacion_base("verde_oscuro", "verde")
    for i, x in enumerate((-4, -2.5, -1)):
        piezas.append(A.cilindro("monedas", 0.6, 0.4 + i * 0.4, (x, -1, 5.6 + i * 0.2), "dorado", lados=10))
    piezas.append(A.caja("caja", (2, 2, 1.6), (4, 0, 6.2), "madera_oscura"))
    return A.unir("mdl_estacion_tienda", piezas)


def estacion_robux():
    piezas = _estacion_base("verde_oscuro", "blanco")
    piezas.append(A.cilindro("emblema", 1.1, 0.3, (0, -6.5, 9), "verde", lados=6, rot=(math.pi / 2, 0, 0)))
    piezas.append(A.cilindro("emblema_centro", 0.5, 0.35, (0, -6.6, 9), "blanco", lados=6, rot=(math.pi / 2, 0, 0)))
    return A.unir("mdl_estacion_robux", piezas)


def estacion_criadero():
    piezas = _estacion_base("naranja", "dorado")
    for x, color in ((-4, "bronce"), (0, "gris"), (4, "dorado")):
        piezas.append(A.esfera("capsula", 0.7, (x, 0, 6.3), color, segmentos=10, anillos=5, escala=(1, 1, 1.3)))
        piezas.append(A.cilindro("aro", 0.75, 0.15, (x, 0, 6.1), "blanco", lados=10))
    return A.unir("mdl_estacion_criadero", piezas)


def estacion_cronometro():
    piezas = _estacion_base("morado", "morado")
    piezas.append(A.cilindro("esfera_reloj", 4.5, 0.6, (0, -6.6, 15.5), "blanco", lados=24, rot=(math.pi / 2, 0, 0)))
    piezas.append(A.anillo("bisel", 4.5, 0.3, (0, -6.6, 15.5), "dorado", lados=24, rot=(math.pi / 2, 0, 0)))
    for i in range(12):
        angulo = 2 * math.pi * i / 12
        piezas.append(A.caja("marca", (0.3, 0.2, 0.8), (math.sin(angulo) * 3.7, -6.95, 15.5 + math.cos(angulo) * 3.7), "negro"))
    return A.unir("mdl_estacion_cronometro", piezas)


def estacion_carga():
    piezas = _estacion_base("bronce", "naranja")
    piezas.append(A.caja("mochila", (2.4, 1.6, 3), (-3, 0, 6.9), "naranja"))
    piezas.append(A.caja("bolsillo", (1.8, 0.4, 1.2), (-3, -0.95, 6.4), "bronce"))
    for i in range(3):
        piezas.append(A.caja("caja_apilada", (1.6, 1.6, 1.2), (3, 0, 6 + i * 1.25), "madera_oscura"))
    return A.unir("mdl_estacion_carga", piezas)


# ---------------------------------------------------------------------------
# Muro frontal y salida (WorldService)
# ---------------------------------------------------------------------------


def muro_frontal():
    """Un tramo del muro: 116 × 2 (alto 18) con pilares y almenas."""
    piezas = [A.caja("muro", (116, 2, 18), (0, 0, 9), "bronce")]
    for x in range(-56, 57, 16):
        piezas.append(A.caja("pilar", (2.4, 2.8, 19), (x, 0, 9.5), "madera_oscura"))
    for x in range(-54, 55, 4):
        piezas.append(A.caja("almena", (2, 2.2, 1.2), (x, 0, 18.6), "bronce"))
    return A.unir("mdl_muro_frontal", piezas)


def cartel_salida():
    """Arco de la salida: 28 de luz, 16 de alto."""
    piezas = [
        A.caja("poste_izq", (1.5, 1.5, 16), (-14.5, 0, 8), "gris_oscuro"),
        A.caja("poste_der", (1.5, 1.5, 16), (14.5, 0, 8), "gris_oscuro"),
        A.caja("viga", (31, 1.6, 2.6), (0, 0, 16.3), "rojo"),
        A.caja("franja", (31, 1.7, 0.4), (0, 0, 15.1), "dorado"),
    ]
    return A.unir("mdl_cartel_salida", piezas)


def poste_puerta_velocidad():
    """Poste para los extremos de la puerta de velocidad (la barrera sigue siendo la pieza del código)."""
    piezas = [A.caja("poste", (2, 2, 40), (0, 0, 20), "gris_oscuro")]
    for z in range(4, 40, 6):
        piezas.append(A.caja("franja", (2.1, 2.1, 1), (0, 0, z), "cian"))
    piezas.append(A.esfera("foco", 1.2, (0, 0, 41), "cian", segmentos=8, anillos=4))
    return A.unir("mdl_puerta_velocidad_poste", piezas)


# ---------------------------------------------------------------------------
# Casas por zona (HouseService): 26 × 24 (alto 12), puerta 8 × 9 en el frente (-Y)
# ---------------------------------------------------------------------------

ESTILOS_CASA = {
    1: dict(nombre="mdl_casa_z1", pared="madera", techo="madera_oscura", tipo="dos_aguas", detalle="ninguno"),
    2: dict(nombre="mdl_casa_z2", pared="rojo", techo="gris_oscuro", tipo="dos_aguas", detalle="chimenea"),
    3: dict(nombre="mdl_casa_z3", pared="blanco", techo="azul_oscuro", tipo="plano", detalle="ventanales"),
    4: dict(nombre="mdl_casa_z4", pared="blanco", techo="gris", tipo="plano", detalle="columnas"),
    5: dict(nombre="mdl_casa_z5", pared="dorado", techo="blanco", tipo="cupula", detalle="columnas"),
}


def casa(zona):
    estilo = ESTILOS_CASA[zona]
    ancho, fondo, alto, grosor = 26, 24, 12, 1
    puerta_ancho, puerta_alto = 8, 9
    pared = estilo["pared"]
    piezas = [
        A.caja("piso", (ancho, fondo, 0.4), (0, 0, 0.2), "madera"),
        A.caja("pared_fondo", (ancho, grosor, alto), (0, fondo / 2 - 0.5, alto / 2), pared),
        A.caja("pared_izq", (grosor, fondo, alto), (-ancho / 2 + 0.5, 0, alto / 2), pared),
        A.caja("pared_der", (grosor, fondo, alto), (ancho / 2 - 0.5, 0, alto / 2), pared),
    ]
    tramo = (ancho - puerta_ancho) / 2
    for lado in (-1, 1):
        piezas.append(A.caja("frente", (tramo, grosor, alto), (lado * (puerta_ancho / 2 + tramo / 2), -fondo / 2 + 0.5, alto / 2), pared))
    piezas.append(A.caja("dintel", (puerta_ancho, grosor, alto - puerta_alto), (0, -fondo / 2 + 0.5, puerta_alto + (alto - puerta_alto) / 2), pared))
    piezas.append(A.caja("marco_puerta", (puerta_ancho + 1, 0.4, 0.6), (0, -fondo / 2, puerta_alto + 0.3), "madera_oscura"))
    # Ventanas del frente
    for lado in (-1, 1):
        piezas.append(A.caja("ventana", (3, 0.3, 2.5), (lado * 8.5, -fondo / 2 - 0.05, 7), "cian"))
    techo = estilo["techo"]
    if estilo["tipo"] == "dos_aguas":
        piezas.append(A.prisma_triangular("tejado", ancho + 2, fondo + 2, 5, (0, 0, alto), techo))
    elif estilo["tipo"] == "cupula":
        piezas.append(A.caja("losa_techo", (ancho + 2, fondo + 2, 1), (0, 0, alto + 0.5), techo))
        piezas.append(A.esfera("cupula", 6, (0, 0, alto + 1), "dorado", segmentos=12, anillos=6, escala=(1, 1, 0.6)))
    else:
        piezas.append(A.caja("losa_techo", (ancho + 2, fondo + 2, 1), (0, 0, alto + 0.5), techo))
        piezas.append(A.caja("pretil", (ancho + 2, 0.6, 1), (0, -fondo / 2 - 0.7, alto + 1.5), techo))
    detalle = estilo["detalle"]
    if detalle == "chimenea":
        piezas.append(A.caja("chimenea", (2, 2, 4), (7, 4, alto + 4), "gris_oscuro"))
    elif detalle == "ventanales":
        piezas.append(A.caja("ventanal", (8, 0.3, 4), (0, fondo / 2 + 0.05, 6), "cian"))
    elif detalle == "columnas":
        for lado in (-1, 1):
            piezas.append(A.cilindro("columna", 0.7, alto, (lado * (puerta_ancho / 2 + 1.5), -fondo / 2 - 1.5, alto / 2), "blanco", lados=10))
        piezas.append(A.caja("porche", (puerta_ancho + 6, 3, 0.6), (0, -fondo / 2 - 1.5, alto - 0.3), techo))
    return A.unir(estilo["nombre"], piezas)


def pedestal():
    """Pedestal donde aparecen las piezas dentro de las casas: 2,4 × 2,4 (alto 2)."""
    piezas = [
        A.caja("cuerpo", (2.4, 2.4, 1.8), (0, 0, 0.9), "madera_oscura"),
        A.caja("tapa", (2.6, 2.6, 0.2), (0, 0, 1.9), "madera"),
        A.caja("cojin", (1.6, 1.6, 0.15), (0, 0, 2.07), "rojo"),
    ]
    return A.unir("mdl_pedestal", piezas)


# ---------------------------------------------------------------------------
# Piezas robables (HouseService): ≈ 1,4 studs
# ---------------------------------------------------------------------------


def pieza_engranaje():
    piezas = [A.cilindro("disco", 0.5, 0.25, (0, 0, 0.7), "gris", lados=12, rot=(math.pi / 2, 0, 0)),
              A.cilindro("eje", 0.15, 0.35, (0, 0, 0.7), "gris_oscuro", lados=8, rot=(math.pi / 2, 0, 0))]
    for i in range(8):
        angulo = 2 * math.pi * i / 8
        piezas.append(A.caja("diente", (0.2, 0.25, 0.25), (math.cos(angulo) * 0.6, 0, 0.7 + math.sin(angulo) * 0.6), "gris"))
    return A.unir("mdl_pieza_engranaje", piezas)


def pieza_resorte():
    piezas = [A.anillo("espira", 0.35, 0.07, (0, 0, 0.25 + i * 0.2), "gris", lados=10) for i in range(6)]
    return A.unir("mdl_pieza_resorte", piezas)


def pieza_tornillo():
    piezas = [
        A.cilindro("cuerpo", 0.12, 1, (0, 0, 0.5), "gris", lados=8),
        A.cilindro("cabeza", 0.3, 0.2, (0, 0, 1.1), "gris_oscuro", lados=8),
        A.caja("ranura", (0.45, 0.08, 0.05), (0, 0, 1.22), "negro"),
    ]
    for i in range(4):
        piezas.append(A.anillo("rosca", 0.13, 0.03, (0, 0, 0.15 + i * 0.2), "gris_oscuro", lados=8))
    return A.unir("mdl_pieza_tornillo", piezas)


def pieza_cristal():
    piezas = [A.esfera("cristal", 0.5, (0, 0, 0.7), "cian", segmentos=6, anillos=3, escala=(0.8, 0.8, 1.4))]
    return A.unir("mdl_pieza_cristal", piezas)


def pieza_correa():
    piezas = [
        A.anillo("correa", 0.5, 0.12, (0, 0, 0.6), "madera_oscura", lados=12, rot=(math.pi / 2, 0, 0)),
        A.caja("hebilla", (0.35, 0.3, 0.3), (0, 0, 0.1), "dorado"),
    ]
    return A.unir("mdl_pieza_correa", piezas)


def pieza_rubi():
    piezas = [
        A.cilindro("cuerpo", 0.5, 0.25, (0, 0, 0.55), "rojo", lados=6),
        A.cono("corona", 0.5, 0.25, 0.3, (0, 0, 0.82), "rojo", lados=6),
        A.cono("punta", 0.5, 0.0, 0.45, (0, 0, 0.2), "rojo", lados=6, rot=(math.pi, 0, 0)),
    ]
    return A.unir("mdl_pieza_rubi", piezas)


def pieza_diamante():
    piezas = [
        A.cono("pabellon", 0.6, 0.0, 0.7, (0, 0, 0.35), "blanco", lados=8, rot=(math.pi, 0, 0)),
        A.cono("corona", 0.6, 0.35, 0.3, (0, 0, 0.85), "cian", lados=8),
    ]
    return A.unir("mdl_pieza_diamante", piezas)


MODELOS = {
    "mdl_plot_suelo": plot_suelo,
    "mdl_taller": taller,
    "mdl_vitrina": vitrina,
    "mdl_panel_plot": panel_plot,
    "mdl_estacion_tienda": estacion_tienda,
    "mdl_estacion_robux": estacion_robux,
    "mdl_estacion_criadero": estacion_criadero,
    "mdl_estacion_cronometro": estacion_cronometro,
    "mdl_estacion_carga": estacion_carga,
    "mdl_muro_frontal": muro_frontal,
    "mdl_cartel_salida": cartel_salida,
    "mdl_puerta_velocidad_poste": poste_puerta_velocidad,
    "mdl_pedestal": pedestal,
    "mdl_pieza_engranaje": pieza_engranaje,
    "mdl_pieza_resorte": pieza_resorte,
    "mdl_pieza_tornillo": pieza_tornillo,
    "mdl_pieza_cristal": pieza_cristal,
    "mdl_pieza_correa": pieza_correa,
    "mdl_pieza_rubi": pieza_rubi,
    "mdl_pieza_diamante": pieza_diamante,
}
for _zona in ESTILOS_CASA:
    MODELOS[ESTILOS_CASA[_zona]["nombre"]] = (lambda z: (lambda: casa(z)))(_zona)
