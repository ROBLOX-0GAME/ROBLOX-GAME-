"""
identidad_visual.py — ART-014: identidad «taller de relojería fantástico» (PROPUESTA DEC-024).

Genera, con la misma paleta de 16 colores (tex_paleta.png) y el mismo estilo low-poly:
- Un punto focal para la plaza: la torre de reloj (mdl_torre_reloj).
- Detalles propios de cada zona, para que las 5 se distingan por vegetación,
  arquitectura y ambiente sin cambiar sus nombres, puertas ni límites:
    Z1 Barrio Humilde ........ tendedero (con el árbol, arbusto y valla actuales)
    Z2 Barrio Obrero ......... álamo y barriles de taller
    Z3 Zona Residencial ...... árbol redondo, seto y buzón
    Z4 Mansiones ............. ciprés, fuente y topiario
    Z5 Colina Millonarios .... palmera, estatua de reloj dorada y farol dorado
- Iconos de las estaciones (Taller, Museo, Tienda, Criadero y Cronómetro Maestro).

Convención: X = ancho, Y = fondo (el FRENTE mira a -Y), Z = arriba; 1 unidad = 1 stud.
Diseños originales: no copian modelos, criaturas ni mapas de otros juegos.

    /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
        --python art/blender/scripts/identidad_visual.py [-- nombre1 nombre2 ...]

Sin nombres, genera todo. Después: vista_previa.py -- <nombres> para las vistas.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402

FRENTE = (math.pi / 2, 0, 0)  # disco mirando a -Y
LADO = (0, math.pi / 2, 0)  # disco mirando a ±X


def _girar(objeto, euler):
    objeto.rotation_euler = euler
    return objeto


# ---------------------------------------------------------------------------
# Plaza: torre de reloj (punto focal, ~8 × 26 × 8 studs)
# ---------------------------------------------------------------------------


def _esfera_reloj(piezas, centro, normal):
    """Esfera de reloj en una cara de la torre. normal: (nx, ny) hacia fuera."""
    nx, ny = normal
    cx, cy, cz = centro
    rot = LADO if nx else FRENTE
    piezas.append(A.cilindro("esfera", 2.2, 0.3, (cx, cy, cz), "blanco", lados=16, rot=rot))
    piezas.append(A.anillo("bisel", 2.25, 0.18, (cx + nx * 0.15, cy + ny * 0.15, cz), "dorado", lados=16, rot=rot))
    # Índices de las 12, 3, 6 y 9 y agujas a las 10:10 (simplificadas en vertical y horizontal)
    fuera = 0.2
    for dz, dh in ((1.7, 0), (-1.7, 0), (0, 1.7), (0, -1.7)):
        dx, dy = (0, dh) if nx else (dh, 0)
        tam = (0.25, 0.3, 0.35) if not nx else (0.3, 0.25, 0.35)
        piezas.append(A.caja("indice", tam, (cx + nx * fuera + dx, cy + ny * fuera + dy, cz + dz), "negro"))
    larga = (0.2, 0.12, 1.5) if not nx else (0.12, 0.2, 1.5)
    corta = (1.1, 0.12, 0.2) if not nx else (0.12, 1.1, 0.2)
    piezas.append(A.caja("aguja_larga", larga, (cx + nx * 0.25, cy + ny * 0.25, cz + 0.7), "negro"))
    dx, dy = (0, -0.5) if nx else (-0.5, 0)
    piezas.append(A.caja("aguja_corta", corta, (cx + nx * 0.25 + dx, cy + ny * 0.25 + dy, cz), "negro"))
    piezas.append(A.cilindro("eje", 0.25, 0.5, (cx + nx * 0.3, cy + ny * 0.3, cz), "dorado", lados=8, rot=rot))


def torre_reloj():
    piezas = [
        A.caja("zocalo", (8, 8, 1.6), (0, 0, 0.8), "gris_oscuro"),
        A.caja("escalon", (9, 9, 0.5), (0, 0, 0.25), "gris"),
        A.caja("cuerpo", (6.4, 6.4, 10.4), (0, 0, 6.8), "gris"),
        A.caja("franja", (7, 7, 0.6), (0, 0, 12.3), "madera_oscura"),
        A.caja("camara_reloj", (6, 6, 6), (0, 0, 15.6), "madera"),
        A.caja("cornisa", (7.2, 7.2, 0.6), (0, 0, 18.9), "madera_oscura"),
        _girar(A.cono("tejado", 5.0, 0.25, 5.2, (0, 0, 21.8), "bronce", lados=4), (0, 0, math.pi / 4)),
        A.cilindro("linterna", 0.7, 1.4, (0, 0, 25.0), "cian", lados=8),
        A.cono("remate", 0.8, 0.05, 0.9, (0, 0, 26.1), "dorado", lados=8),
        # Puerta de madera y engranaje de latón en el frente
        A.caja("puerta", (2.2, 0.3, 3.4), (0, -3.25, 3.3), "madera_oscura"),
        A.anillo("engranaje", 1.0, 0.22, (0, -3.3, 8.2), "dorado", lados=10, rot=FRENTE),
    ]
    # Vigas de madera en las esquinas del cuerpo (aire de taller)
    for sx in (-1, 1):
        for sy in (-1, 1):
            piezas.append(A.caja("pilar", (0.9, 0.9, 10.4), (sx * 3.0, sy * 3.0, 6.8), "madera_oscura"))
    for normal in ((0, -1), (0, 1), (-1, 0), (1, 0)):
        nx, ny = normal
        _esfera_reloj(piezas, (nx * 3.15, ny * 3.15, 15.6), normal)
    return A.unir("mdl_torre_reloj", piezas)


# ---------------------------------------------------------------------------
# Zona 1 — Barrio Humilde
# ---------------------------------------------------------------------------


def z1_tendedero():
    piezas = [
        A.caja("poste", (0.3, 0.3, 4), (-3, 0, 2), "madera_oscura"),
        A.caja("poste", (0.3, 0.3, 4), (3, 0, 2), "madera_oscura"),
        A.caja("cuerda", (6, 0.06, 0.06), (0, 0, 3.8), "blanco"),
        A.caja("ropa", (1.1, 0.08, 1.3), (-1.7, 0, 3.1), "rojo"),
        A.caja("ropa", (0.9, 0.08, 1.0), (0, 0, 3.25), "azul"),
        A.caja("ropa", (1.2, 0.08, 1.5), (1.7, 0, 3.0), "naranja"),
        A.cilindro("cubo", 0.5, 0.8, (2.4, 1.0, 0.4), "gris", lados=8),
    ]
    return A.unir("mdl_z1_tendedero", piezas)


# ---------------------------------------------------------------------------
# Zona 2 — Barrio Obrero
# ---------------------------------------------------------------------------


def z2_alamo():
    piezas = [
        A.cilindro("tronco", 0.4, 3.2, (0, 0, 1.6), "madera_oscura", lados=6),
        A.esfera("copa", 1.6, (0, 0, 7), "verde_oscuro", segmentos=7, anillos=5, escala=(1, 1, 3)),
        A.esfera("copa", 1.1, (0.4, -0.3, 8.6), "verde", segmentos=7, anillos=5, escala=(1, 1, 2.2)),
    ]
    return A.unir("mdl_z2_alamo", piezas)


def _barril(nombre, pos):
    x, y, z = pos
    return [
        A.cilindro(nombre, 0.8, 1.8, (x, y, z + 0.9), "madera", lados=10),
        A.cilindro("aro", 0.84, 0.15, (x, y, z + 0.35), "gris_oscuro", lados=10),
        A.cilindro("aro", 0.84, 0.15, (x, y, z + 1.45), "gris_oscuro", lados=10),
    ]


def z2_barriles():
    piezas = _barril("barril", (-0.85, 0, 0)) + _barril("barril", (0.85, 0.2, 0)) + _barril("barril", (0, 0.1, 1.8))
    piezas.append(A.caja("tablon", (3.4, 0.8, 0.2), (0, -1.1, 0.1), "madera_oscura"))
    return A.unir("mdl_z2_barriles", piezas)


# ---------------------------------------------------------------------------
# Zona 3 — Zona Residencial
# ---------------------------------------------------------------------------


def z3_arbol_redondo():
    piezas = [
        A.cilindro("tronco", 0.5, 3.6, (0, 0, 1.8), "madera_oscura", lados=6),
        A.esfera("copa", 2.6, (0, 0, 5.6), "verde", segmentos=8, anillos=5),
        A.esfera("copa", 1.6, (1.3, -0.6, 4.6), "verde_oscuro", segmentos=7, anillos=4),
        A.esfera("copa", 1.3, (-1.3, 0.5, 6.6), "verde_oscuro", segmentos=7, anillos=4),
    ]
    return A.unir("mdl_z3_arbol_redondo", piezas)


def z3_seto():
    """Tramo de seto de 8 studs (mismo largo que la valla)."""
    piezas = [
        A.caja("seto", (8, 1.6, 2.0), (0, 0, 1.0), "verde_oscuro"),
        A.caja("copete", (7.8, 1.4, 0.4), (0, 0, 2.2), "verde"),
    ]
    return A.unir("mdl_z3_seto", piezas)


def z3_buzon():
    piezas = [
        A.caja("poste", (0.3, 0.3, 3), (0, 0, 1.5), "madera"),
        A.caja("caja", (0.9, 1.6, 0.9), (0, 0, 3.3), "azul"),
        A.cilindro("techo", 0.45, 1.6, (0, 0, 3.75), "azul_oscuro", lados=8, rot=FRENTE),
        A.caja("bandera", (0.1, 0.3, 0.7), (0.5, 0.4, 3.6), "rojo"),
    ]
    return A.unir("mdl_z3_buzon", piezas)


# ---------------------------------------------------------------------------
# Zona 4 — Mansiones
# ---------------------------------------------------------------------------


def z4_cipres():
    piezas = [
        A.cilindro("tronco", 0.3, 1.2, (0, 0, 0.6), "madera_oscura", lados=6),
        A.cono("copa", 1.3, 0.1, 9, (0, 0, 5.6), "verde_oscuro", lados=8),
    ]
    return A.unir("mdl_z4_cipres", piezas)


def z4_fuente():
    piezas = [
        A.cilindro("pila", 3.5, 0.8, (0, 0, 0.4), "blanco", lados=16),
        A.cilindro("agua", 3.0, 0.1, (0, 0, 0.85), "cian", lados=16),
        A.cilindro("columna", 0.5, 2.4, (0, 0, 2.0), "blanco", lados=8),
        A.cilindro("plato", 1.4, 0.3, (0, 0, 3.3), "blanco", lados=12),
        A.cilindro("agua", 1.2, 0.1, (0, 0, 3.5), "cian", lados=12),
        A.esfera("remate", 0.4, (0, 0, 3.95), "dorado", segmentos=8, anillos=4),
    ]
    return A.unir("mdl_z4_fuente", piezas)


def z4_topiario():
    piezas = [
        A.cilindro("maceta", 0.9, 1.0, (0, 0, 0.5), "blanco", lados=8),
        A.cilindro("borde", 1.0, 0.2, (0, 0, 1.0), "dorado", lados=8),
        A.cilindro("tallo", 0.15, 1.2, (0, 0, 1.6), "madera_oscura", lados=6),
        A.esfera("bola", 1.1, (0, 0, 2.9), "verde", segmentos=8, anillos=5),
        A.esfera("bola", 0.7, (0, 0, 4.4), "verde_oscuro", segmentos=7, anillos=4),
    ]
    return A.unir("mdl_z4_topiario", piezas)


# ---------------------------------------------------------------------------
# Zona 5 — Colina de los Millonarios
# ---------------------------------------------------------------------------


def _hoja_palmera(origen, angulo, color):
    """Hoja caída: tira de 3 tramos que sale de la punta del tronco hacia `angulo`."""
    import bpy

    ox, oy, oz = origen
    dx, dy = math.cos(angulo), math.sin(angulo)
    px, py = -dy, dx  # perpendicular en el plano
    tramos = ((0.0, 0.25, 0.0), (1.7, 0.55, 0.35), (3.2, 0.45, -0.4), (4.2, 0.05, -1.4))  # (distancia, media anchura, altura)
    verts = []
    for d, w, h in tramos:
        cx, cy, cz = ox + dx * d, oy + dy * d, oz + h
        verts += [(cx + px * w, cy + py * w, cz), (cx - px * w, cy - py * w, cz)]
    caras = []
    for k in range(len(tramos) - 1):
        a, b = 2 * k, 2 * k + 2
        caras += [(a, b, b + 1, a + 1), (a + 1, b + 1, b, a)]  # dos caras: se ve por arriba y por abajo
    malla = bpy.data.meshes.new("hoja")
    malla.from_pydata(verts, [], caras)
    malla.update()
    objeto = bpy.data.objects.new("hoja", malla)
    bpy.context.collection.objects.link(objeto)
    bpy.context.view_layer.objects.active = objeto
    return A.pintar(objeto, color)


def z5_palmera():
    piezas = []
    x, z = 0.0, 0.0
    for i in range(6):  # tronco ligeramente curvado
        piezas.append(A.cilindro("tronco", 0.45 - i * 0.03, 1.6, (x, 0, z + 0.8), ("madera", "bronce")[i % 2], lados=6))
        x += 0.18
        z += 1.5
    for i in range(6):
        piezas.append(_hoja_palmera((x, 0, z - 0.1), 2 * math.pi * i / 6 + 0.3, ("verde", "verde_oscuro")[i % 2]))
    for i in range(3):
        a = 2 * math.pi * i / 3 + 0.5
        piezas.append(A.esfera("coco", 0.32, (x + math.cos(a) * 0.45, math.sin(a) * 0.45, z - 0.5), "bronce", segmentos=6, anillos=4))
    return A.unir("mdl_z5_palmera", piezas)


def z5_estatua_reloj():
    """Reloj de bolsillo gigante de oro sobre pedestal de marfil (diseño original)."""
    piezas = [
        A.caja("pedestal", (3, 3, 2.2), (0, 0, 1.1), "blanco"),
        A.caja("cornisa", (3.3, 3.3, 0.3), (0, 0, 2.35), "dorado"),
        A.caja("base_reloj", (1.4, 1.0, 0.5), (0, 0, 2.75), "dorado"),
        A.cilindro("caja", 1.6, 0.5, (0, 0, 4.4), "dorado", lados=16, rot=FRENTE),
        A.cilindro("esfera", 1.3, 0.55, (0, -0.03, 4.4), "blanco", lados=16, rot=FRENTE),
        A.caja("aguja", (0.15, 0.1, 1.0), (0, -0.35, 4.85), "negro"),
        A.caja("aguja", (0.7, 0.1, 0.15), (-0.3, -0.35, 4.4), "negro"),
        A.cilindro("corona", 0.3, 0.5, (0, 0, 6.2), "dorado", lados=8),
        A.anillo("asa", 0.45, 0.12, (0, 0, 6.75), "dorado", lados=10, rot=FRENTE),
    ]
    return A.unir("mdl_z5_estatua_reloj", piezas)


def z5_farol_dorado():
    piezas = [
        A.cilindro("base", 0.55, 0.6, (0, 0, 0.3), "negro", lados=8),
        A.cilindro("poste", 0.16, 5.6, (0, 0, 3.4), "negro", lados=8),
        A.anillo("aro", 0.3, 0.08, (0, 0, 1.2), "dorado", lados=8),
        A.caja("farol", (0.9, 0.9, 1.1), (0, 0, 6.75), "cian"),
        A.caja("marco", (1.05, 1.05, 0.15), (0, 0, 6.2), "dorado"),
        A.cono("sombrero", 0.8, 0.05, 0.7, (0, 0, 7.65), "dorado", lados=4),
    ]
    return A.unir("mdl_z5_farol_dorado", piezas)


MODELOS = {
    "mdl_torre_reloj": torre_reloj,
    "mdl_z1_tendedero": z1_tendedero,
    "mdl_z2_alamo": z2_alamo,
    "mdl_z2_barriles": z2_barriles,
    "mdl_z3_arbol_redondo": z3_arbol_redondo,
    "mdl_z3_seto": z3_seto,
    "mdl_z3_buzon": z3_buzon,
    "mdl_z4_cipres": z4_cipres,
    "mdl_z4_fuente": z4_fuente,
    "mdl_z4_topiario": z4_topiario,
    "mdl_z5_palmera": z5_palmera,
    "mdl_z5_estatua_reloj": z5_estatua_reloj,
    "mdl_z5_farol_dorado": z5_farol_dorado,
}

# ---------------------------------------------------------------------------
# Iconos de estaciones (se ven de frente, desde -Y; mismo render que iconos.py)
# ---------------------------------------------------------------------------


def icono_taller():
    piezas = [A.cilindro("engranaje", 1.0, 0.3, (0.35, 0.1, 0.2), "dorado", lados=16, rot=FRENTE)]
    for i in range(8):
        a = 2 * math.pi * i / 8
        piezas.append(A.caja("diente", (0.4, 0.3, 0.4), (0.35 + math.cos(a) * 1.15, 0.1, 0.2 + math.sin(a) * 1.15), "dorado"))
    piezas.append(A.cilindro("hueco", 0.4, 0.35, (0.35, 0.05, 0.2), "bronce", lados=10, rot=FRENTE))
    llave = A.caja("llave", (0.45, 0.3, 2.8), (-0.4, -0.2, -0.1), "gris")
    _girar(llave, (0, math.radians(-40), 0))
    piezas.append(llave)
    piezas.append(A.anillo("boca", 0.42, 0.16, (-1.25, -0.2, 0.9), "gris", lados=8, rot=FRENTE))
    return piezas


def icono_museo():
    return [
        A.caja("base", (2.6, 1, 0.5), (0, 0, -1.25), "madera_oscura"),
        A.caja("vitrina", (2.2, 0.9, 2.0), (0, 0.1, 0.0), "cian"),
        A.caja("marco", (2.4, 1.0, 0.25), (0, 0, 1.1), "dorado"),
        A.cilindro("reloj", 0.6, 0.3, (0, -0.4, -0.05), "dorado", lados=14, rot=FRENTE),
        A.cilindro("esfera", 0.45, 0.32, (0, -0.42, -0.05), "blanco", lados=14, rot=FRENTE),
    ]


def icono_tienda():
    bolsa = [(-1.2, -1.4), (1.2, -1.4), (1.45, -0.2), (0.9, 0.7), (-0.9, 0.7), (-1.45, -0.2)]
    return [
        A.prisma_poligono("bolsa", bolsa, 0.5, (0, 0, 0), "verde"),
        A.caja("nudo", (1.0, 0.55, 0.45), (0, 0, 0.9), "verde_oscuro"),
        A.cono("boca", 0.7, 0.3, 0.6, (0, 0, 1.4), "verde", lados=6),
        A.cilindro("moneda", 0.6, 0.3, (0, -0.3, -0.4), "dorado", lados=14, rot=FRENTE),
        A.cilindro("relieve", 0.38, 0.32, (0, -0.32, -0.4), "bronce", lados=14, rot=FRENTE),
    ]


def icono_criadero():
    return [
        A.esfera("capsula", 1.2, (0, 0, 0.2), "morado", segmentos=12, anillos=8, escala=(1, 1, 1.3)),
        A.cilindro("cierre", 1.25, 0.25, (0, 0, 0.1), "dorado", lados=16),
        A.esfera("brillo", 0.35, (-0.45, -0.95, 0.9), "blanco", segmentos=8, anillos=4),
        A.caja("base", (2.0, 1.0, 0.4), (0, 0, -1.45), "madera"),
    ]


def icono_cronometro():
    return [
        A.cilindro("caja", 1.4, 0.35, (0, 0.05, -0.1), "rojo", lados=18, rot=FRENTE),
        A.cilindro("esfera", 1.1, 0.4, (0, 0, -0.1), "blanco", lados=18, rot=FRENTE),
        A.caja("aguja", (0.18, 0.2, 0.9), (0, -0.25, 0.25), "negro"),
        A.caja("aguja", (0.7, 0.2, 0.16), (0.3, -0.25, -0.1), "negro"),
        A.cilindro("pulsador", 0.3, 0.5, (0, 0, 1.55), "dorado", lados=8),
        A.caja("pulsador_lado", (0.35, 0.3, 0.35), (1.15, 0, 0.95), "dorado"),
    ]


ICONOS = {
    "ico_est_taller": icono_taller,
    "ico_est_museo": icono_museo,
    "ico_est_tienda": icono_tienda,
    "ico_est_criadero": icono_criadero,
    "ico_est_cronometro": icono_cronometro,
}


if __name__ == "__main__":
    pedidos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else None
    resumen = []
    for nombre, constructor in MODELOS.items():
        if pedidos and nombre not in pedidos:
            continue
        A.limpiar_escena()
        A.crear_paleta()
        objeto = constructor()
        _, tris = A.exportar(objeto, nombre)
        dims = objeto.dimensions
        resumen.append(f"{nombre}: {tris} triángulos, {dims.x:.2f} × {dims.z:.2f} × {dims.y:.2f} (ancho × alto × fondo)")
    import iconos as I  # noqa: E402  (después de los modelos: limpia la escena al renderizar)

    for nombre, constructor in ICONOS.items():
        if pedidos and nombre not in pedidos:
            continue
        I.render_icono(nombre, constructor)
        resumen.append(f"{nombre}: icono 256 px")
    print("\n".join(["== ART-014 =="] + resumen))
