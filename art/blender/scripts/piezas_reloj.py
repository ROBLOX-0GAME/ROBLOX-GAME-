"""
piezas_reloj.py — ART-018: las 4 piezas de cada reloj (caja, calibre, esfera y manecillas).

Fase 1 (esta versión): BOCETOS para que Jhonn valide el estilo antes de modelar los 18
relojes ([[PROMPT_PIEZAS_RELOJ_ZADIEL]] §9.2 y §11.4). Por cada reloj genera una lámina
`art/referencias/boceto_<reloj>.png` con:
  - las 4 piezas por separado y el reloj armado (materiales PBR ya existentes: DEC-018),
  - la fila de las 12 rarezas con su color de contorno (DEC-028, §3 del prompt),
  - el número de triángulos de cada pieza (presupuesto de §5: pieza ≤ 800, armado ≤ 3.000).

Diseños ORIGINALES por tipo de reloj: sin logos, textos, coronas ni nombres de marcas.
Convención: X = ancho, Y = fondo (el FRENTE mira a −Y), Z = arriba; 1 unidad = 1 stud.

    /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
        --python art/blender/scripts/piezas_reloj.py [-- lunamaster pocket]
"""

import math
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402
import relojes_detallados as R  # noqa: E402  (no se ejecuta al importarlo)

FRENTE = R.FRENTE
LADO = (0, math.pi / 2, 0)
REFERENCIAS = os.path.join(A.ART, "referencias")

# Colores de contorno de las 12 rarezas (GameData.Rarities / §3 del prompt)
RAREZAS = [
    ("Común", "B0B4BC"), ("Poco común", "4CAF6A"), ("Raro", "3D8BFD"), ("Épico", "9B59E6"),
    ("Legendario", "F2A032"), ("Mítico", "E03C3C"), ("Divino", "FFDD33"), ("Celestial", "5BD5E0"),
    ("Cósmico", "D65CE6"), ("Eterno", "FFFFFF"), ("Ancestral", "00A86B"), ("Atemporal", "ARCOIRIS"),
]


# ---------------------------------------------------------------------------
# Piezas genéricas (cada función devuelve una lista de (objeto, material))
# ---------------------------------------------------------------------------


def caja_redonda(radio, mat, bisel_mat=None, asas=True, pulsadores=False, correa=None, taquimetro=False):
    """CAJA: aro grueso con fondo, bisel, corona a las 3, asas y (opcional) correa corta."""
    p = [
        R.disco("caja", radio, 0.25, 0, 0, mat, 24),
        R.disco("fondo", radio * 0.9, 0.04, 0.14, 0, mat, 24),
        R.aro("bisel", radio * 0.93, 0.055, -0.12, 0, bisel_mat or mat, 24),
        (A.cilindro("corona", 0.075, 0.16, (radio + 0.06, 0, 0), "gris", lados=12, rot=LADO), mat),
    ]
    if taquimetro:  # marcas claras sobre el bisel oscuro (sin textos)
        for i in range(12):
            a = 2 * math.pi * i / 12
            p.append(R.barra("taqui", 0.018, 0.05, (math.sin(a) * radio * 0.93, -0.15, math.cos(a) * radio * 0.93),
                             -a, "esmalte_blanco", fondo=0.01))
    if pulsadores:
        for dz in (0.28, -0.28):
            p.append((A.cilindro("pulsador", 0.045, 0.13, (radio + 0.03, 0, dz), "gris", lados=10, rot=LADO), mat))
    if asas:
        for dx in (-0.3, 0.3):
            for dz in (radio + 0.08, -(radio + 0.08)):
                p.append((A.caja("asa", (0.1, 0.16, 0.2), (dx, 0, dz), "gris"), mat))
    if correa:
        for dz in (radio + 0.32, -(radio + 0.32)):
            p.append((R.biselar(A.caja("correa", (0.52, 0.12, 0.36), (0, 0.03, dz), "gris"), 0.03, 1), correa))
    return p


def calibre(radio, tipo, placa="metal_laton", rueda="metal_oro_cepillado"):
    """CALIBRE: disco más pequeño que la caja. Cuarzo (pila y circuito), mecánico (engranajes,
    volante y rubíes) o automático (mecánico + rotor en media luna)."""
    p = [R.disco("platina", radio, 0.08, 0, 0, placa, 28)]
    if tipo == "Cuarzo":
        p.append(R.disco("pila", radio * 0.42, 0.06, -0.06, radio * 0.15, "metal_plata", 20))
        p.append((A.caja("circuito", (radio * 1.1, 0.03, radio * 0.45), (0, -0.05, -radio * 0.45), "gris"), "esmalte_cosmico"))
        return p
    # Mecánico: 3 engranajes, volante con espiral y rubíes
    engranajes = ((-0.18, 0.12, 0.13), (0.12, 0.2, 0.09), (0.1, -0.05, 0.07))
    if tipo == "Automatico":  # el rotor tapa la mitad: 2 engranajes bastan (presupuesto §5)
        engranajes = engranajes[:2]
    for (x, z, r) in engranajes:
        p.append(R.aro("engranaje", r, 0.025, -0.06, z, rueda, 10))
        p[-1][0].location.x += x * radio / 0.45
        p.append(R.disco("eje_eng", 0.025, 0.04, -0.07, z, "gema_rubi", 8))
        p[-1][0].location.x += x * radio / 0.45
    p.append(R.aro("volante", radio * 0.3, 0.02, -0.06, -radio * 0.42, "metal_oro_pulido", 16))
    p.append(R.aro("espiral", radio * 0.16, 0.01, -0.065, -radio * 0.42, "metal_acero", 12))
    for (x, z) in ((-0.25, -0.2), (0.28, 0.0)):
        p += R.gema("rubi", 0.03, (x * radio / 0.45, -0.07, z * radio / 0.45), "gema_rubi")
    if tipo == "Automatico":
        # Rotor en media luna: semicírculo extruido delante de la platina (se ve desde el frente)
        contorno = [(math.cos(math.pi * k / 10) * radio * 0.92, math.sin(math.pi * k / 10) * radio * 0.92) for k in range(11)]
        contorno += [(math.cos(math.pi * k / 10) * radio * 0.3, math.sin(math.pi * k / 10) * radio * 0.3) for k in range(10, -1, -1)]
        p.append((A.prisma_poligono("rotor", contorno, 0.03, (0, -0.1, 0), "gris"), "metal_oro_pulido"))
    return p


def esfera(radio, mat, marcas, subesferas=0, romanos=False, sub_mat=None):
    """ESFERA: disco plano con 12 índices (o romanos) y subesferas en los relojes caros."""
    p = [R.disco("esfera", radio, 0.03, R.Y_ESFERA, 0, mat, 32)]
    r_marcas = radio * 0.8
    for h in range(12):
        a = 2 * math.pi * h / 12
        mx, mz = math.sin(a) * r_marcas, math.cos(a) * r_marcas
        if romanos:
            p += R.numeral(R.ROMANOS[h], mx, mz, -a, radio * 0.18, marcas)  # ya van en R.Y_INDICES
        else:
            largo = radio * (0.18 if h % 3 == 0 else 0.11)
            p.append(R.barra("indice", radio * 0.05, largo, (mx, R.Y_INDICES, mz), -a, marcas))
    posiciones = {3: ((-0.38, 0), (0.38, 0), (0, -0.4)), 2: ((-0.38, 0), (0.38, 0))}.get(subesferas, ())
    for (fx, fz) in posiciones:
        p.append(R.aro("subesfera", radio * 0.2, 0.012, R.Y_INDICES, fz * radio, sub_mat or marcas, 16))
        p[-1][0].location.x = fx * radio
        p.append(R.barra("aguja_sub", 0.012, radio * 0.15, (fx * radio, R.Y_INDICES - 0.004, fz * radio + radio * 0.06), 0.5, marcas))
    return p


def manecillas(radio, mat, segundero="gema_rubi"):
    """MANECILLAS: hora (corta y ancha), minutos (larga) y segundos (fina, de color), unidas al centro."""
    p = [R.disco("eje", 0.04, 0.05, R.Y_AGUJAS - 0.01, 0, mat, 10)]
    for nombre, largo, ancho, horas in (("hora", 0.5, 0.08, 10 + 10 / 60), ("minutos", 0.78, 0.055, 2)):
        a = 2 * math.pi * horas / 12
        largo *= radio
        p.append(R.barra(nombre, radio * ancho, largo, (math.sin(a) * largo * 0.4, R.Y_AGUJAS, math.cos(a) * largo * 0.4), -a,
                         mat, fondo=0.02))
    a = 2 * math.pi * 7 / 12
    largo = radio * 0.9
    p.append(R.barra("segundos", radio * 0.02, largo, (math.sin(a) * largo * 0.35, R.Y_AGUJAS - 0.005, math.cos(a) * largo * 0.35), -a,
                     segundero, fondo=0.012))
    return p


# ---------------------------------------------------------------------------
# Formas extra para los 18 relojes (todas genéricas, sin rasgos de marca)
# ---------------------------------------------------------------------------


def escalar(objeto, sx=1.0, sz=1.0):
    objeto.scale = (sx, 1.0, sz)
    bpy.ops.object.select_all(action="DESELECT")
    objeto.select_set(True)
    bpy.context.view_layer.objects.active = objeto
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return objeto


def caja_forma(forma, ancho, alto, mat, bisel_mat=None, correa=None, asas=True):
    """CAJA no redonda: 'cuadrada', 'rectangular', 'tonel', 'octogono' o 'cojin' (octógono con orejas)."""
    p = []
    if forma in ("cuadrada", "rectangular"):
        p.append((R.biselar(A.caja("caja", (ancho, 0.25, alto), (0, 0, 0), "gris"), 0.06, 2), mat))
        p.append((R.biselar(A.caja("bisel", (ancho * 0.92, 0.05, alto * 0.92), (0, -0.13, 0), "gris"), 0.02, 1),
                  bisel_mat or mat))
    elif forma == "tonel":
        p.append((escalar(A.cilindro("caja", 0.5, 0.28, (0, 0, 0), "gris", lados=20, rot=FRENTE), ancho, alto), mat))
        p.append((escalar(A.anillo("bisel", 0.46, 0.05, (0, -0.14, 0), "gris", lados=20, rot=FRENTE), ancho, alto),
                  bisel_mat or mat))
    else:  # octógono (con o sin orejas)
        giro = (math.pi / 2, math.pi / 8, 0)
        p.append((A.cilindro("caja", ancho / 2, 0.25, (0, 0, 0), "gris", lados=8, rot=giro), mat))
        p.append((A.anillo("bisel", ancho / 2 * 0.9, 0.06, (0, -0.13, 0), "gris", lados=8, rot=giro), bisel_mat or mat))
        if forma == "cojin":
            for sx in (-1, 1):
                p.append((R.biselar(A.caja("oreja", (0.14, 0.2, 0.32), (sx * (ancho / 2 + 0.04), 0, 0), "gris"), 0.04, 1),
                          mat))
    p.append((A.cilindro("corona", 0.07, 0.16, (ancho / 2 + 0.07, 0, 0), "gris", lados=10, rot=LADO), mat))
    if asas and forma in ("cuadrada", "rectangular", "tonel"):
        for dx in (-ancho * 0.3, ancho * 0.3):
            for dz in (alto / 2 + 0.07, -(alto / 2 + 0.07)):
                p.append((A.caja("asa", (0.1, 0.16, 0.16), (dx, 0, dz), "gris"), mat))
    if correa:
        for dz in (alto / 2 + 0.3, -(alto / 2 + 0.3)):
            p.append((R.biselar(A.caja("correa", (ancho * 0.75, 0.12, 0.36), (0, 0.03, dz), "gris"), 0.03, 1), correa))
    return p


def tornillos(n, radio, mat, lados=6, desfase=0.0, cuadrado=False):
    """Tornillos vistos sobre el bisel (hexagonales con lados=6)."""
    p = []
    for i in range(n):
        a = 2 * math.pi * i / n + desfase
        r = radio / max(abs(math.sin(a)), abs(math.cos(a))) if cuadrado else radio
        x, z = math.sin(a) * r, math.cos(a) * r
        p.append((A.cilindro("tornillo", 0.035, 0.04, (x, -0.17, z), "gris", lados=lados, rot=FRENTE), mat))
    return p


def acanalado(n, radio, mat, largo=0.07, ancho=0.03, y=-0.16):
    """Bisel o canto acanalado: n estrías radiales."""
    p = []
    for i in range(n):
        a = 2 * math.pi * i / n
        p.append(R.barra("estria", ancho, largo, (math.sin(a) * radio, y, math.cos(a) * radio), -a, mat, fondo=0.02))
    return p


def gemas_bisel(n, radio, mat, tam=0.045):
    p = []
    for i in range(n):
        a = 2 * math.pi * i / n
        p += R.gema("gema", tam, (math.sin(a) * radio, -0.17, math.cos(a) * radio), mat)
    return p


def eslabones(ancho, alto_caja, mat, mat_centro=None, filas=2):
    """Brazalete de 3 eslabones (tramo corto arriba y abajo)."""
    p = []
    for sz in (1, -1):
        for fila in range(filas):
            z = sz * (alto_caja / 2 + 0.16 + fila * 0.24)
            for col, x in enumerate((-ancho * 0.26, 0, ancho * 0.26)):
                m = (mat_centro or mat) if col == 1 else mat
                p.append((A.caja("eslabon", (ancho * 0.25, 0.12, 0.2), (x, 0.03, z), "gris"), m))  # sin bisel: presupuesto §5
    return p


def esfera_forma(ancho, alto, mat, marcas, patron="indices", subesferas=0, sub_mat=None, forma="redonda", extra=None):
    """ESFERA con patrón: 'indices', 'romanos', 'lineas', 'cuadros', 'guilloche', 'rayos' o 'calado'."""
    r = min(ancho, alto) / 2
    p = []
    if patron == "calado":  # deja ver el calibre: solo un aro con un puente en cruz
        p.append(R.aro("anillo", r * 0.9, 0.04, R.Y_ESFERA, 0, mat, 24))
        for ang in (0, math.pi / 2):
            p.append(R.barra("puente", 0.05, r * 1.7, (0, R.Y_ESFERA, 0), ang, mat, fondo=0.02))
    elif forma == "redonda":
        p.append(R.disco("esfera", r, 0.03, R.Y_ESFERA, 0, mat, 28))
    elif forma == "octogono":
        p.append((A.cilindro("esfera", r, 0.03, (0, R.Y_ESFERA, 0), "gris", lados=8, rot=(math.pi / 2, math.pi / 8, 0)), mat))
    else:
        p.append((A.caja("esfera", (ancho, 0.03, alto), (0, R.Y_ESFERA, 0), "gris"), mat))
    for h in range(12):
        a = 2 * math.pi * h / 12
        sx, sz = (ancho / 2 * 0.78, alto / 2 * 0.78)
        if forma in ("cuadrada", "rectangular"):
            k = 1 / max(abs(math.sin(a)) * (alto / ancho), abs(math.cos(a))) if ancho < alto else 1 / max(abs(math.sin(a)), abs(math.cos(a)))
            mx, mz = math.sin(a) * min(sx, sz) * k, math.cos(a) * min(sx, sz) * k
            mx, mz = max(-sx, min(sx, mx)), max(-sz, min(sz, mz))
        else:
            mx, mz = math.sin(a) * r * 0.78, math.cos(a) * r * 0.78
        if patron == "romanos":
            p += R.numeral(R.ROMANOS[h], mx, mz, -a, r * 0.17, marcas)
        else:
            largo = r * (0.17 if h % 3 == 0 else 0.1)
            p.append(R.barra("indice", r * 0.05, largo, (mx, R.Y_INDICES, mz), -a, marcas))
    if patron == "lineas":
        for k in range(-3, 4):
            p.append(R.barra("linea", ancho * 0.7, 0.012, (0, R.Y_ESFERA - 0.017, k * r * 0.18), 0, marcas, fondo=0.006))
    elif patron == "cuadros":
        for gx in range(-2, 3):
            for gz in range(-2, 3):
                p.append((A.caja("cuadro", (r * 0.22, 0.012, r * 0.22), (gx * r * 0.27, R.Y_ESFERA - 0.018, gz * r * 0.27),
                                 "gris"), sub_mat or mat))
    elif patron == "guilloche":
        for k in (0.3, 0.6):
            p.append(R.aro("guilloche", r * k, 0.008, R.Y_ESFERA - 0.017, 0, marcas, 16))
    elif patron == "rayos":
        for k in range(16):
            a = 2 * math.pi * k / 16
            p.append(R.barra("rayo", 0.008, r * 0.5, (math.sin(a) * r * 0.32, R.Y_ESFERA - 0.017, math.cos(a) * r * 0.32), -a,
                             marcas, fondo=0.006))
    posiciones = {3: ((-0.38, 0), (0.38, 0), (0, -0.4)), 2: ((-0.38, 0), (0.38, 0)), 1: ((0, -0.42),)}.get(subesferas, ())
    for (fx, fz) in posiciones:
        p.append(R.aro("subesfera", r * 0.2, 0.012, R.Y_INDICES, fz * r, sub_mat or marcas, 12))
        p[-1][0].location.x = fx * r
        p.append(R.barra("aguja_sub", 0.012, r * 0.15, (fx * r, R.Y_INDICES - 0.004, fz * r + r * 0.06), 0.5, marcas))
    if extra:
        p += extra(r)
    return p


def extra_tourbillon(r):
    """Ventana del tourbillon a las 6: aro dorado con rubí en el centro."""
    return [R.aro("tourbillon", r * 0.22, 0.02, R.Y_INDICES, -r * 0.45, "metal_oro_pulido", 16)] + \
        R.gema("rubi_tb", 0.035, (0, R.Y_INDICES, -r * 0.45), "gema_rubi")


def extra_astronomia(r):
    """Globo terráqueo, luna y tourbillon a la vista bajo la cúpula (diseño propio)."""
    return [
        (A.esfera("globo", r * 0.24, (-r * 0.35, R.Y_INDICES - 0.08, r * 0.2), "gris", segmentos=12, anillos=8), "esmalte_azul"),
        (A.esfera("luna", r * 0.13, (r * 0.4, R.Y_INDICES - 0.06, r * 0.25), "gris", segmentos=10, anillos=6), "metal_plata"),
        R.aro("tourbillon", r * 0.2, 0.02, R.Y_INDICES, -r * 0.42, "metal_oro_pulido", 16),
    ] + R.gema("diamante_tb", 0.04, (0, R.Y_INDICES - 0.02, -r * 0.42), "gema_diamante")


def cupula(r):
    """Cúpula de zafiro sobre la caja (va con la CAJA)."""
    return [(A.esfera("cupula", r * 0.92, (0, -0.16, 0), "gris", segmentos=10, anillos=5, escala=(1, 0.5, 1)), "cristal_zafiro")]


# ---------------------------------------------------------------------------
# Los 18 relojes (DEC-028 y DEC-031): diseños por TIPO de reloj, sin marcas
# ---------------------------------------------------------------------------

M, AU, CU = "Mecanico", "Automatico", "Cuarzo"
RELOJES = {
    # --- 6 generales ---
    "pocket": {
        "nombre": "Reloj de bolsillo (general)", "calibre": M,
        "case": lambda: caja_redonda(0.58, "metal_oro_pulido", "metal_oro_cepillado", asas=False) + [
            R.aro("aro_cadena", 0.16, 0.035, 0, 0.82, "metal_oro_pulido", 16)],
        "movement": lambda: calibre(0.46, M),
        "dial": lambda: esfera(0.5, "esmalte_blanco", "esmalte_negro", romanos=True),
        "hands": lambda: manecillas(0.5, "esmalte_azul", segundero="esmalte_azul"),
    },
    "wrist": {
        "nombre": "Reloj de pulsera (general)", "calibre": CU,
        "case": lambda: caja_forma("cuadrada", 0.9, 0.9, "metal_acero", correa="cuero_correa"),
        "movement": lambda: calibre(0.36, CU, placa="metal_acero"),
        "dial": lambda: esfera_forma(0.74, 0.74, "esmalte_azul", "metal_acero", forma="cuadrada"),
        "hands": lambda: manecillas(0.4, "metal_acero"),
    },
    "chrono": {
        "nombre": "Cronógrafo (general)", "calibre": M,
        "case": lambda: caja_redonda(0.6, "metal_acero", "esmalte_negro", pulsadores=True, correa="esmalte_negro"),
        "movement": lambda: calibre(0.46, M, placa="metal_acero"),
        "dial": lambda: esfera_forma(1.04, 1.04, "esmalte_azul", "metal_acero", subesferas=3, sub_mat="esmalte_blanco"),
        "hands": lambda: manecillas(0.52, "metal_acero"),
    },
    "legacy": {
        "nombre": "Reloj del Legado (general)", "calibre": AU,
        "case": lambda: caja_redonda(0.6, "metal_oro_pulido", "metal_oro_cepillado", correa="cuero_correa")
        + gemas_bisel(4, 0.56, "gema_zafiro", 0.05),
        "movement": lambda: calibre(0.46, AU),
        "dial": lambda: esfera_forma(1.04, 1.04, "esmalte_cosmico", "metal_oro_pulido", patron="romanos"),
        "hands": lambda: manecillas(0.52, "metal_oro_pulido", segundero="gema_zafiro"),
    },
    "royal": {
        "nombre": "Reloj real de rubí (general)", "calibre": AU,
        "case": lambda: caja_redonda(0.6, "metal_oro_pulido", "metal_oro_cepillado", correa="cuero_correa")
        + acanalado(20, 0.56, "metal_oro_cepillado"),
        "movement": lambda: calibre(0.46, AU),
        "dial": lambda: esfera_forma(1.04, 1.04, "esmalte_negro", "gema_rubi"),
        "hands": lambda: manecillas(0.52, "metal_oro_pulido"),
    },
    "millionaire": {
        "nombre": "Reloj del millonario (general)", "calibre": AU,
        "case": lambda: caja_redonda(0.6, "metal_oro_pulido", "metal_oro_pulido", asas=False)
        + gemas_bisel(6, 0.56, "gema_diamante", 0.055) + eslabones(0.8, 1.2, "metal_oro_pulido", "metal_oro_cepillado", filas=1),
        "movement": lambda: calibre(0.46, AU),
        "dial": lambda: esfera_forma(1.04, 1.04, "metal_oro_cepillado", "esmalte_negro", patron="rayos"),
        "hands": lambda: manecillas(0.52, "esmalte_negro"),
    },
    # --- 12 de lujo, uno por zona (material de la zona, DEC-031) ---
    "lunamaster": {
        "nombre": "Omigo Lunamaster (zona 1 · acero mate)", "calibre": M,
        "case": lambda: caja_redonda(0.6, "metal_acero", "esmalte_negro", pulsadores=True, correa="esmalte_negro",
                                     taquimetro=True),
        "movement": lambda: calibre(0.46, M, placa="metal_acero"),
        "dial": lambda: esfera(0.52, "esmalte_negro", "esmalte_blanco", subesferas=3, sub_mat="metal_acero"),
        "hands": lambda: manecillas(0.52, "esmalte_blanco"),
    },
    "santo": {
        "nombre": "Cartero Santo (zona 2 · acero cepillado y tornillos)", "calibre": AU,
        "case": lambda: caja_forma("cuadrada", 1.0, 1.0, "metal_acero", asas=False)
        + tornillos(8, 0.4, "metal_plata", lados=6, desfase=math.pi / 8, cuadrado=True)
        + eslabones(0.85, 1.0, "metal_acero"),
        "movement": lambda: calibre(0.4, AU, placa="metal_acero"),
        "dial": lambda: esfera_forma(0.76, 0.76, "esmalte_blanco", "esmalte_negro", patron="romanos", forma="cuadrada"),
        "hands": lambda: manecillas(0.42, "esmalte_azul", segundero="esmalte_azul"),
    },
    "reverso": {
        "nombre": "Jaguar-LeColtre Reversible (zona 3 · acero y esmalte art déco)", "calibre": M,
        "case": lambda: caja_forma("rectangular", 0.72, 1.12, "metal_acero", bisel_mat="metal_plata", correa="cuero_correa")
        + [R.barra("gallon", 0.66, 0.025, (0, -0.16, dz), math.pi / 2, "metal_plata", fondo=0.015)
           for dz in (0.5, 0.46, 0.42, -0.42, -0.46, -0.5)],
        "movement": lambda: calibre(0.3, M, placa="metal_acero"),
        "dial": lambda: esfera_forma(0.56, 0.86, "esmalte_blanco", "esmalte_negro", forma="rectangular"),
        "hands": lambda: manecillas(0.4, "esmalte_azul", segundero="esmalte_azul"),
    },
    "daytona": {
        "nombre": "Rolando Daytuna (zona 4 · oro amarillo)", "calibre": AU,
        "case": lambda: caja_redonda(0.6, "metal_oro_pulido", "esmalte_negro", pulsadores=True, asas=False,
                                     taquimetro=True) + eslabones(0.8, 1.2, "metal_oro_pulido", "metal_oro_cepillado"),
        "movement": lambda: calibre(0.46, AU),
        "dial": lambda: esfera_forma(1.04, 1.04, "metal_oro_cepillado", "esmalte_negro", subesferas=3, sub_mat="esmalte_negro"),
        "hands": lambda: manecillas(0.52, "esmalte_negro", segundero="esmalte_negro"),
    },
    "overseas": {
        "nombre": "Vacherón Ultramar (zona 5 · oro rosa)", "calibre": AU,
        "case": lambda: caja_redonda(0.6, "metal_laton", "metal_laton", asas=False)
        + acanalado(6, 0.56, "metal_oro_cepillado", largo=0.1, ancho=0.12) + eslabones(0.8, 1.2, "metal_laton"),
        "movement": lambda: calibre(0.46, AU),
        "dial": lambda: esfera_forma(1.04, 1.04, "esmalte_azul", "metal_oro_pulido", patron="rayos"),
        "hands": lambda: manecillas(0.52, "metal_oro_pulido"),
    },
    "nautil": {
        "nombre": "Philippon Nautil (zona 6 · acero y esfera azul)", "calibre": AU,
        "case": lambda: caja_forma("cojin", 1.14, 1.14, "metal_acero") + eslabones(0.8, 1.14, "metal_acero"),
        "movement": lambda: calibre(0.44, AU, placa="metal_acero"),
        "dial": lambda: esfera_forma(0.92, 0.92, "esmalte_azul", "metal_plata", patron="lineas", forma="octogono"),
        "hands": lambda: manecillas(0.46, "metal_plata"),
    },
    "roblereal": {
        "nombre": "Audemar Roble Real (zona 7 · acero y oro blanco)", "calibre": AU,
        "case": lambda: caja_forma("octogono", 1.18, 1.18, "metal_acero", bisel_mat="metal_plata")
        + tornillos(8, 0.48, "metal_plata", lados=6, desfase=math.pi / 8) + eslabones(0.8, 1.18, "metal_acero"),
        "movement": lambda: calibre(0.44, AU, placa="metal_acero"),
        "dial": lambda: esfera_forma(0.9, 0.9, "esmalte_azul", "metal_plata", patron="cuadros", sub_mat="esmalte_azul"),
        "hands": lambda: manecillas(0.45, "metal_plata"),
    },
    "bigbang": {
        "nombre": "Hublón Gran Explosión (zona 8 · cerámica y caucho)", "calibre": AU,
        "case": lambda: caja_redonda(0.64, "esmalte_negro", "esmalte_negro", correa="esmalte_negro")
        + tornillos(6, 0.6, "metal_acero", lados=6),
        "movement": lambda: calibre(0.48, AU, placa="metal_acero"),
        "dial": lambda: esfera_forma(1.06, 1.06, "esmalte_negro", "metal_acero", subesferas=2, sub_mat="metal_acero"),
        "hands": lambda: manecillas(0.54, "metal_acero", segundero="gema_rubi"),
    },
    "rm11": {
        "nombre": "Ricardo Mil RM-11 (zona 9 · carbono y zafiro)", "calibre": AU,
        "case": lambda: caja_forma("tonel", 1.0, 1.24, "esmalte_negro", bisel_mat="metal_acero", correa="esmalte_negro")
        + tornillos(8, 0.5, "metal_acero", lados=6),
        "movement": lambda: calibre(0.42, AU, placa="metal_acero", rueda="metal_plata"),
        "dial": lambda: esfera_forma(0.86, 1.06, "metal_acero", "esmalte_blanco", patron="calado"),
        "hands": lambda: manecillas(0.45, "metal_acero", segundero="gema_rubi"),
    },
    "tourbillon": {
        "nombre": "Bregué Clásico Tourbillon (zona 10 · oro con guilloché)", "calibre": M,
        "case": lambda: caja_redonda(0.6, "metal_oro_pulido", "metal_oro_cepillado", correa="cuero_correa")
        + acanalado(16, 0.61, "metal_oro_cepillado", largo=0.05, ancho=0.025, y=0.0),
        "movement": lambda: calibre(0.46, M),
        "dial": lambda: esfera_forma(1.04, 1.04, "esmalte_blanco", "esmalte_negro", patron="guilloche", extra=extra_tourbillon),
        "hands": lambda: manecillas(0.52, "esmalte_azul", segundero="esmalte_azul"),
    },
    "granmaestro": {
        "nombre": "Philippon Gran Maestro Campana (zona 11 · oro rosa y esmalte)", "calibre": M,
        "case": lambda: caja_redonda(0.62, "metal_laton", "metal_oro_cepillado", correa="cuero_correa")
        + [R.aro("grabado", 0.62 * 0.98, 0.014, -0.165, 0, "metal_oro_pulido", 16)],
        "movement": lambda: calibre(0.46, M),
        "dial": lambda: esfera_forma(1.06, 1.06, "esmalte_blanco", "metal_oro_pulido", patron="romanos", subesferas=2,
                                     sub_mat="esmalte_azul"),
        "hands": lambda: manecillas(0.52, "metal_oro_pulido"),
    },
    "astronomia": {
        "nombre": "Jacobo y Cía. Astronomía (zona 12 · zafiro y gemas)", "calibre": M,
        "case": lambda: caja_redonda(0.62, "metal_oro_pulido", "metal_oro_cepillado")
        + gemas_bisel(4, 0.58, "gema_diamante", 0.06) + cupula(0.6),
        "movement": lambda: calibre(0.46, M),
        "dial": lambda: esfera_forma(1.06, 1.06, "esmalte_cosmico", "gema_diamante", extra=extra_astronomia),
        "hands": lambda: manecillas(0.52, "metal_oro_pulido"),
    },
}

CLASES = [("case", "Caja"), ("movement", "Calibre"), ("dial", "Esfera"), ("hands", "Manecillas")]
# Capas del reloj armado (de atrás hacia delante, en −Y)
CAPA_ARMADO = {"movement": 0.0, "case": 0.0, "dial": 0.0, "hands": 0.0}  # cada pieza ya va a su profundidad


# ---------------------------------------------------------------------------
# Lámina de boceto
# ---------------------------------------------------------------------------


def colocar(piezas, dx, dy=0.0, dz=0.0):
    bpy.context.view_layer.update()
    for objeto, material in piezas:
        objeto.location.x += dx
        objeto.location.y += dy
        objeto.location.z += dz
        if not objeto.data.materials:
            objeto.data.materials.append(R.material_pbr(material))
        else:
            objeto.data.materials[0] = R.material_pbr(material)
    return piezas


def triangulos(piezas):
    total = 0
    for objeto, _ in piezas:
        objeto.data.calc_loop_triangles()
        total += len(objeto.data.loop_triangles)
    return total


def texto(cuerpo, pos, tam=0.22, color=(0.95, 0.94, 0.9, 1)):
    bpy.ops.object.text_add(location=pos, rotation=(math.pi / 2, 0, 0))
    t = bpy.context.active_object
    t.data.body = cuerpo
    t.data.size = tam
    t.data.align_x = "CENTER"
    mat = bpy.data.materials.new("texto")
    mat.diffuse_color = color
    mat.use_nodes = True
    mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = color
    t.data.materials.append(mat)
    return t


def muestra_rareza(i, nombre, hexa, x, z):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=0.17, location=(x, -0.2, z))
    bola = bpy.context.active_object
    mat = bpy.data.materials.new("rareza_" + str(i))
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    if hexa == "ARCOIRIS":
        rampa = mat.node_tree.nodes.new("ShaderNodeValToRGB")
        coords = mat.node_tree.nodes.new("ShaderNodeTexCoord")
        sep = mat.node_tree.nodes.new("ShaderNodeSeparateXYZ")
        mat.node_tree.links.new(coords.outputs["Generated"], sep.inputs["Vector"])
        mat.node_tree.links.new(sep.outputs["X"], rampa.inputs["Fac"])
        cols = [(1, 0.1, 0.1, 1), (1, 0.8, 0.1, 1), (0.2, 0.9, 0.3, 1), (0.2, 0.5, 1, 1), (0.7, 0.2, 1, 1)]
        rampa.color_ramp.elements[0].color = cols[0]
        rampa.color_ramp.elements[1].color = cols[-1]
        for k, c in enumerate(cols[1:-1], 1):
            e = rampa.color_ramp.elements.new(k / (len(cols) - 1))
            e.color = c
        mat.node_tree.links.new(rampa.outputs["Color"], bsdf.inputs["Base Color"])
    else:
        r, g, b = A._hex_rgb(hexa)
        bsdf.inputs["Base Color"].default_value = (r ** 2.2, g ** 2.2, b ** 2.2, 1)
    bsdf.inputs["Roughness"].default_value = 0.35
    bola.data.materials.append(mat)
    texto(nombre, (x, -0.2, z - 0.36), 0.11)


def preparar_render(ancho, alto):
    escena = bpy.context.scene
    motores = [i.identifier for i in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items]
    escena.render.engine = "BLENDER_EEVEE" if "BLENDER_EEVEE" in motores else "BLENDER_EEVEE_NEXT"
    mundo = bpy.data.worlds.new("estudio")
    escena.world = mundo
    mundo.use_nodes = True
    # Entorno medio: el metal necesita algo oscuro que reflejar (con fondo blanco sale blanco)
    mundo.node_tree.nodes["Background"].inputs["Color"].default_value = (0.32, 0.31, 0.3, 1)
    mundo.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6
    bpy.ops.object.light_add(type="AREA", location=(-7, -6, 7))
    luz = bpy.context.active_object
    luz.data.energy = 900
    luz.data.size = 6
    luz.rotation_euler = (math.radians(50), 0, math.radians(-50))
    escena.render.resolution_x, escena.render.resolution_y = ancho, alto
    escena.view_settings.view_transform = "Standard"
    escena.render.film_transparent = False


def lamina(reloj_id, vista=False):
    datos = RELOJES[reloj_id]
    A.limpiar_escena()
    A.crear_paleta()
    resumen = []
    separacion = 1.75
    for i, (clase, etiqueta) in enumerate(CLASES):
        piezas = colocar(datos[clase](), (i - 2) * separacion)
        tris = triangulos(piezas)
        tipo = {"Mecanico": "mecánico", "Automatico": "automático", "Cuarzo": "cuarzo"}[datos["calibre"]]
        nota = f"{etiqueta} ({tipo})" if clase == "movement" else etiqueta
        texto(f"{nota}\n{tris} triángulos", ((i - 2) * separacion, -0.3, -1.45), 0.14)
        resumen.append((clase, tris))
    # Reloj armado: las 4 piezas apiladas en capas
    armado = []
    for clase, _ in CLASES:
        armado += colocar(datos[clase](), 2 * separacion + 0.4, CAPA_ARMADO[clase])
    tris_armado = triangulos(armado)
    texto(f"Armado\n{tris_armado} triángulos", (2 * separacion + 0.4, -0.3, -1.45), 0.14)
    texto(datos["nombre"], (0.2, -0.3, 1.6), 0.24)
    for i, (nombre, hexa) in enumerate(RAREZAS):
        muestra_rareza(i, nombre, hexa, (i - 5.5) * 0.72, -2.05)
    texto("Rareza: cambia material, color y brillo (no la forma)", (0.2, -0.3, -2.75), 0.13)
    # Rutas absolutas: material_pbr las deja relativas a un .blend que aquí no se guarda
    for imagen in bpy.data.images:
        if imagen.filepath.startswith("//"):
            imagen.filepath = os.path.join(R.TEXTURAS, os.path.basename(imagen.filepath))
    preparar_render(1800, 1100)
    bpy.ops.object.camera_add(location=(0.2, -12, 0.1), rotation=(math.radians(90), 0, 0))
    cam = bpy.context.active_object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 9.6
    bpy.context.scene.camera = cam
    carpeta = os.path.join(A.ART, "export", "vistas") if vista else REFERENCIAS
    os.makedirs(carpeta, exist_ok=True)
    ruta = os.path.join(carpeta, f"rlj_{reloj_id}.png" if vista else f"boceto_{reloj_id}.png")
    bpy.context.scene.render.filepath = ruta
    bpy.ops.render.render(write_still=True)
    return ruta, resumen, tris_armado


CLASE_ES = dict(CLASES)


def exportar_reloj(reloj_id):
    """FBX con las 4 piezas en su sitio (reloj armado). Cada malla se llama «Clase__material»;
    en Studio se separan en pz_<reloj>_<clase> y mdl_reloj_<reloj> (ver ids_roblox.md)."""
    datos = RELOJES[reloj_id]
    A.limpiar_escena()
    A.crear_paleta()
    resumen, mallas = {}, []
    for clase, nombre_es in CLASES:
        piezas = datos[clase]()
        resumen[clase] = triangulos(piezas)
        por_material = {}
        for objeto, material in piezas:
            por_material.setdefault(material, []).append(objeto)
        for material, objetos in por_material.items():
            malla = A.unir(f"{nombre_es}__{material}", objetos)
            mallas.append(malla)
    bpy.ops.object.select_all(action="DESELECT")
    for malla in mallas:
        malla.select_set(True)
    bpy.context.view_layer.objects.active = mallas[0]
    os.makedirs(A.EXPORT_MODELOS, exist_ok=True)
    ruta = os.path.join(A.EXPORT_MODELOS, f"rlj_{reloj_id}.fbx")
    bpy.ops.export_scene.fbx(filepath=ruta, use_selection=True, apply_unit_scale=True, global_scale=1.0,
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="STRIP", bake_anim=False)
    os.makedirs(A.FUENTES_BLEND, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(A.FUENTES_BLEND, f"rlj_{reloj_id}.blend"))
    return ruta, resumen, len(mallas)


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    solo_boceto = "--boceto" in argumentos
    pedidos = [x for x in argumentos if not x.startswith("--")] or list(RELOJES)
    for reloj_id in pedidos:
        ruta_lamina, resumen, tris_armado = lamina(reloj_id, vista=not solo_boceto)
        detalle = ", ".join(f"{c}={t}" for c, t in resumen)
        aviso = "" if max(t for _, t in resumen) <= 800 and tris_armado <= 3000 else "  ⚠ FUERA DE PRESUPUESTO"
        print(f"== {reloj_id}: {detalle}, armado={tris_armado}{aviso} -> {ruta_lamina}")
        if not solo_boceto:
            ruta, _, n = exportar_reloj(reloj_id)
            print(f"   FBX {ruta} ({n} mallas)")
