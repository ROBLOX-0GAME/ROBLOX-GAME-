"""
piezas_detalladas.py — piezas robables, piezas del legado y cápsulas con materiales PBR (ART-009, DEC-018).

Igual que relojes_detallados.py: cada modelo se exporta como VARIAS mallas, una por
material, con el nombre del material (metal_laton, gema_rubi…). En Roblox se importa
como un Model con un MeshPart por material y cada MeshPart lleva un SurfaceAppearance.

Mismos nombres de archivo, medidas, origen en la base y frente hacia −Y que los
modelos base (modelos_prioridad1.py, modelos_prioridad2.py y generar_todo.py), así
que el juego los usa sin tocar código. generar_todo.py ya no los sobrescribe salvo
que se pidan por nombre.

Requisito: los mapas de materiales_pbr.py (incluidos metal_laton, metal_plata y
esmalte_cosmico).

Uso (desde la raíz del repositorio):
    Windows: "C:\\Program Files\\Blender Foundation\\Blender 5.3\\blender.exe" --background --factory-startup ^
                 --python art/blender/scripts/piezas_detalladas.py [-- mdl_pieza_engranaje ...]
    macOS:   /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
                 --python art/blender/scripts/piezas_detalladas.py
Después, vista_previa.py los renderiza con EEVEE (los .blend llevan «render_pbr»).
"""

import math
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402
import relojes_detallados as R  # noqa: E402  (no ejecuta main al importarlo)

FRENTE = R.FRENTE
LIMITE_PIEZAS = 1000  # triángulos por pieza robable o del legado
LIMITE_CAPSULAS = 3000


def m(objeto, mat):
    return objeto, mat


# ---------------------------------------------------------------------------
# Piezas robables (≈ 1,4 studs, base en z = 0)
# ---------------------------------------------------------------------------

def pieza_engranaje():
    z = 0.7
    p = [m(A.cilindro("disco", 0.5, 0.22, (0, 0, z), "gris", lados=24, rot=FRENTE), "metal_laton"),
         m(A.anillo("llanta", 0.42, 0.04, (0, -0.12, z), "gris", lados=24, rot=FRENTE), "metal_oro_cepillado"),
         m(A.cilindro("eje", 0.13, 0.36, (0, 0, z), "gris", lados=12, rot=FRENTE), "metal_acero")]
    for i in range(12):  # dientes
        a = 2 * math.pi * i / 12
        p.append(R.barra("diente", 0.16, 0.18, (math.cos(a) * 0.58, 0, z + math.sin(a) * 0.58), -a + math.pi / 2,
                         "metal_laton", fondo=0.22))
    for i in range(4):  # radios calados (rendijas oscuras)
        a = 2 * math.pi * i / 4 + math.pi / 4
        p.append(R.barra("calado", 0.1, 0.2, (math.cos(a) * 0.27, -0.115, z + math.sin(a) * 0.27), -a + math.pi / 2,
                         "esmalte_negro"))
    p += R.gema("rubi_eje", 0.07, (0, -0.2, z), "gema_rubi")  # rubí de rodamiento, como en los relojes reales
    return p


def pieza_resorte():
    p = [m(A.anillo("espira", 0.35, 0.065, (0, 0, 0.25 + i * 0.2), "gris", lados=14, rot=(0.12 * (-1) ** i, 0, 0)),
           "metal_acero") for i in range(6)]
    p.append(m(A.cilindro("tapa_abajo", 0.36, 0.06, (0, 0, 0.12), "gris", lados=14), "metal_acero"))
    p.append(m(A.cilindro("tapa_arriba", 0.36, 0.06, (0, 0, 1.33), "gris", lados=14), "metal_acero"))
    return p


def pieza_tornillo():
    p = [m(A.cilindro("cuerpo", 0.12, 1, (0, 0, 0.5), "gris", lados=10), "metal_acero"),
         m(A.cilindro("cabeza", 0.3, 0.2, (0, 0, 1.1), "gris", lados=12), "metal_acero"),
         m(A.caja("ranura", (0.45, 0.08, 0.05), (0, 0, 1.2), "gris"), "esmalte_negro"),
         m(A.cono("punta", 0.12, 0, 0.12, (0, 0, -0.0), "gris", lados=10, rot=(math.pi, 0, 0)), "metal_acero")]
    R.biselar(p[1][0], 0.03, 1)
    for i in range(5):
        p.append(m(A.anillo("rosca", 0.13, 0.03, (0, 0, 0.12 + i * 0.18), "gris", lados=10), "metal_acero"))
    return p


def pieza_cristal():
    # Cristal de reloj tallado; en Studio, Transparency ≈ 0,3 (no 0,85 como en los relojes)
    p = [m(A.esfera("cristal", 0.5, (0, 0, 0.7), "gris", segmentos=8, anillos=4, escala=(0.8, 0.8, 1.4)), "cristal_zafiro"),
         m(A.cilindro("base", 0.3, 0.1, (0, 0, 0.05), "gris", lados=8), "metal_plata")]
    return p


def pieza_correa():
    p = [m(A.anillo("correa", 0.5, 0.12, (0, 0, 0.6), "gris", lados=16, rot=FRENTE), "cuero_correa")]
    # Hebilla: marco de cuatro barras y lengüeta
    p += [m(A.caja("hebilla_arriba", (0.4, 0.3, 0.06), (0, 0, 0.27), "gris"), "metal_acero"),
          m(A.caja("hebilla_abajo", (0.4, 0.3, 0.06), (0, 0, -0.03), "gris"), "metal_acero"),
          m(A.caja("hebilla_izq", (0.06, 0.3, 0.3), (-0.17, 0, 0.12), "gris"), "metal_acero"),
          m(A.caja("hebilla_der", (0.06, 0.3, 0.3), (0.17, 0, 0.12), "gris"), "metal_acero"),
          m(A.caja("lengueta", (0.04, 0.34, 0.26), (0, 0, 0.12), "gris"), "metal_oro_pulido")]
    return p


def pieza_rubi():
    return [m(A.cilindro("cuerpo", 0.5, 0.25, (0, 0, 0.55), "gris", lados=8), "gema_rubi"),
            m(A.cono("corona", 0.5, 0.25, 0.3, (0, 0, 0.82), "gris", lados=8), "gema_rubi"),
            m(A.cono("punta", 0.5, 0.0, 0.45, (0, 0, 0.2), "gris", lados=8, rot=(math.pi, 0, 0)), "gema_rubi")]


def pieza_diamante():
    return [m(A.cono("pabellon", 0.6, 0.0, 0.7, (0, 0, 0.35), "gris", lados=12, rot=(math.pi, 0, 0)), "gema_diamante"),
            m(A.cono("corona", 0.6, 0.35, 0.3, (0, 0, 0.85), "gris", lados=12), "gema_diamante")]


# ---------------------------------------------------------------------------
# Piezas del legado (ficticias, sin marcas reales)
# ---------------------------------------------------------------------------

def legado_espiral():
    """Espiral Celestial: espiral de oro dentro de un aro de plata y diamante central."""
    z = 0.7
    p = R.gema("gema", 0.16, (0, -0.02, z), "gema_diamante")
    pasos = 40
    for i in range(pasos):
        t = i / pasos * 3 * math.pi
        radio = 0.14 + t * 0.055
        p.append(m(A.caja("tramo", (0.075, 0.08, 0.075), (math.cos(t) * radio, 0, z + math.sin(t) * radio), "gris"),
                   "metal_oro_pulido"))
    p.append(m(A.anillo("marco", 0.7, 0.045, (0, 0, z), "gris", lados=24, rot=FRENTE), "metal_plata"))
    return p


def legado_corona():
    """Corona de Zafiro Real: aro de oro con puntas y zafiros tallados."""
    p = [m(A.cilindro("aro", 0.55, 0.35, (0, 0, 0.35), "gris", lados=16), "metal_oro_pulido"),
         m(A.anillo("borde", 0.56, 0.04, (0, 0, 0.53), "gris", lados=16), "metal_oro_cepillado")]
    for i in range(6):
        a = 2 * math.pi * i / 6
        x, y = math.cos(a) * 0.5, math.sin(a) * 0.5
        p.append(m(A.cono("punta", 0.15, 0, 0.4, (x, y, 0.72), "gris", lados=4), "metal_oro_pulido"))
        p.append(m(A.esfera("zafiro", 0.09, (x, y, 0.95), "gris", segmentos=6, anillos=3), "gema_zafiro"))
    p += R.gema("zafiro_central", 0.18, (0, -0.55, 0.35), "gema_zafiro")
    return p


def legado_rotor():
    """Rotor de Diamantes Arcoíris: disco de plata con gemas alternas en el borde."""
    z = 0.7
    p = [m(A.cilindro("rotor", 0.6, 0.12, (0, 0, z), "gris", lados=24, rot=FRENTE), "metal_plata"),
         m(A.anillo("canto", 0.6, 0.03, (0, -0.06, z), "gris", lados=24, rot=FRENTE), "metal_oro_pulido"),
         m(A.cilindro("eje", 0.12, 0.2, (0, 0, z), "gris", lados=12, rot=FRENTE), "metal_oro_pulido")]
    gemas = ["gema_rubi", "gema_diamante", "gema_zafiro"]
    for i in range(12):
        a = 2 * math.pi * i / 12
        p += R.gema("gema", 0.075, (math.cos(a) * 0.46, -0.08, z + math.sin(a) * 0.46), gemas[i % 3])
    return p


# ---------------------------------------------------------------------------
# Cápsulas (≈ 2 × 2 × 3 studs)
# ---------------------------------------------------------------------------

def capsula(arriba, anillo, cosmica=False):
    p = [m(A.esfera("arriba", 1, (0, 0, 1.9), "gris", segmentos=16, anillos=8, escala=(1, 1, 1.15)), arriba),
         m(A.esfera("abajo", 1, (0, 0, 1.1), "gris", segmentos=16, anillos=8), "esmalte_blanco"),
         m(A.cilindro("anillo", 1.05, 0.25, (0, 0, 1.5), "gris", lados=16), anillo),
         m(A.cilindro("cierre", 0.18, 0.1, (0, -1.06, 1.5), "gris", lados=8, rot=FRENTE), "metal_acero"),
         m(A.cilindro("pie", 0.7, 0.3, (0, 0, 0.15), "gris", lados=16), "esmalte_negro")]
    if cosmica:
        for i in range(5):
            a = 2 * math.pi * i / 5
            p.append(m(A.cono("estrella", 0.18, 0, 0.35, (math.cos(a) * 0.95, math.sin(a) * 0.95, 2.1), "gris", lados=4),
                       "gema_diamante"))
        p += R.gema("orbe", 0.25, (0, 0, 3.2), "gema_diamante")
    return p


MODELOS = {
    "mdl_pieza_engranaje": pieza_engranaje,
    "mdl_pieza_resorte": pieza_resorte,
    "mdl_pieza_tornillo": pieza_tornillo,
    "mdl_pieza_cristal": pieza_cristal,
    "mdl_pieza_correa": pieza_correa,
    "mdl_pieza_rubi": pieza_rubi,
    "mdl_pieza_diamante": pieza_diamante,
    "mdl_legado_espiral": legado_espiral,
    "mdl_legado_corona": legado_corona,
    "mdl_legado_rotor": legado_rotor,
    "mdl_capsula_laton": lambda: capsula("metal_laton", "metal_oro_pulido"),
    "mdl_capsula_plata": lambda: capsula("metal_plata", "metal_oro_pulido"),
    "mdl_capsula_oro": lambda: capsula("metal_oro_pulido", "metal_oro_cepillado"),
    "mdl_capsula_cosmica": lambda: capsula("esmalte_cosmico", "metal_plata", cosmica=True),
}


def main():
    pedidos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else list(MODELOS)
    resultados = []
    for nombre in pedidos:
        A.limpiar_escena()
        mallas = R.unir_por_material(MODELOS[nombre]())
        if nombre == "mdl_pieza_cristal":  # en la vista previa se ve tallado, no casi invisible
            bpy.data.materials["cristal_zafiro"].node_tree.nodes["Principled BSDF"].inputs["Alpha"].default_value = 0.55
        for material in list(bpy.data.materials):
            if material.users == 0:
                bpy.data.materials.remove(material)
        for imagen in list(bpy.data.images):
            if imagen.users == 0:
                bpy.data.images.remove(imagen)
        ruta = R.exportar(nombre, mallas)
        total = sum(A.triangulos(x) for x in mallas)
        resultados.append((nombre, total, [(x.name, A.triangulos(x)) for x in mallas], ruta))
    print("=== Piezas detalladas ===")
    for nombre, total, partes, ruta in resultados:
        limite = LIMITE_CAPSULAS if nombre.startswith("mdl_capsula_") else LIMITE_PIEZAS
        aviso = "" if total <= limite else f"  ⚠️ supera {limite}"
        print(f"{nombre}: {total} triángulos{aviso} -> {os.path.relpath(ruta, A.REPO)}")
        print("    " + ", ".join(f"{n} ({t})" for n, t in partes))


if __name__ == "__main__":
    main()
