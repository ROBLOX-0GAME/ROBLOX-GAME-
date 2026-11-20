"""
materiales_pbr.py — materiales PBR de los relojes (ART-006).

Genera un proyecto de Material Maker (.ptex) por material en art/texturas/fuentes/,
lo exporta con Material Maker por línea de comandos y deja en art/texturas/export/
los 4 mapas que usa SurfaceAppearance en Roblox:

    tex_<material>_color.png      → ColorMap
    tex_<material>_normal.png     → NormalMap (espacio tangente, convención OpenGL, la de Roblox)
    tex_<material>_rugosidad.png  → RoughnessMap
    tex_<material>_metalico.png   → MetalnessMap

Uso (desde la raíz del repositorio):
    macOS:   /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
                 --python art/blender/scripts/materiales_pbr.py
    Windows: "C:\\Program Files\\Blender Foundation\\Blender 5.3\\blender.exe" --background --factory-startup ^
                 --python art/blender/scripts/materiales_pbr.py

Material Maker: se busca en la variable de entorno MATERIAL_MAKER o en las rutas
habituales (/Applications en macOS, Escritorio en Windows). Con «-- solo_mapas»
no se llama a Material Maker y solo se convierten exportaciones ya hechas.

Los .ptex se pueden abrir y retocar a mano en Material Maker; si se guardan con
el mismo nombre y se vuelve a ejecutar el script con «-- sin_ptex», se exportan
sin sobrescribirlos.
"""

import glob
import json
import os
import shutil
import subprocess
import sys
import tempfile

import bpy
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402

FUENTES = os.path.join(A.ART, "texturas", "fuentes")
EXPORT = os.path.join(A.ART, "texturas", "export")
TAM_LOG2 = 9  # 2^9 = 512 px

# ---------------------------------------------------------------------------
# Definición de los materiales (PROPUESTA ART-006). Colores en sRGB 0–1.
#   ruido:  ("perlin", escala, iteraciones) | ("cepillado", escala_vetas)
#           | ("celdas", escala)  (voronoi: grano del cuero o facetas de gema)
#   color:  gradiente (oscuro, claro) aplicado al ruido
#   rug:    rugosidad mínima y máxima · metal: 0 o 1 · relieve: fuerza del normal
# ---------------------------------------------------------------------------
MATERIALES = {
    "metal_oro_pulido":    dict(ruido=("perlin", 6, 4), color=((0.86, 0.66, 0.28), (1.00, 0.80, 0.42)), rug=(0.12, 0.22), metal=1, relieve=0.25),
    "metal_oro_cepillado": dict(ruido=("cepillado", 256), color=((0.80, 0.60, 0.25), (0.98, 0.79, 0.42)), rug=(0.30, 0.45), metal=1, relieve=0.12),
    "metal_acero":         dict(ruido=("cepillado", 256), color=((0.60, 0.61, 0.64), (0.80, 0.81, 0.84)), rug=(0.26, 0.40), metal=1, relieve=0.1),
    "cristal_zafiro":      dict(ruido=("perlin", 3, 2), color=((0.80, 0.88, 0.98), (0.86, 0.92, 1.00)), rug=(0.02, 0.06), metal=0, relieve=0.05),
    "esmalte_blanco":      dict(ruido=("perlin", 3, 3), color=((0.92, 0.91, 0.88), (0.97, 0.96, 0.93)), rug=(0.08, 0.14), metal=0, relieve=0.1),
    "esmalte_negro":       dict(ruido=("perlin", 3, 3), color=((0.03, 0.03, 0.04), (0.08, 0.08, 0.09)), rug=(0.10, 0.16), metal=0, relieve=0.1),
    "esmalte_azul":        dict(ruido=("perlin", 3, 3), color=((0.05, 0.15, 0.42), (0.10, 0.25, 0.60)), rug=(0.10, 0.16), metal=0, relieve=0.1),
    "cuero_correa":        dict(ruido=("celdas", 28), color=((0.22, 0.11, 0.05), (0.40, 0.22, 0.11)), rug=(0.55, 0.80), metal=0, relieve=0.6),
    "gema_rubi":           dict(ruido=("celdas", 4), color=((0.45, 0.02, 0.06), (0.88, 0.10, 0.18)), rug=(0.02, 0.08), metal=0, relieve=1.0),
    "gema_diamante":       dict(ruido=("celdas", 4), color=((0.80, 0.86, 0.94), (1.00, 1.00, 1.00)), rug=(0.01, 0.05), metal=0, relieve=1.0),
    "gema_zafiro":         dict(ruido=("celdas", 4), color=((0.04, 0.10, 0.45), (0.16, 0.32, 0.88)), rug=(0.02, 0.08), metal=0, relieve=1.0),
}


# ---------------------------------------------------------------------------
# Construcción del .ptex (grafo de Material Maker 1.8)
# ---------------------------------------------------------------------------

def _gradiente(a, b):
    return {"type": "Gradient", "interpolation": 1, "points": [
        {"pos": 0, "r": a[0], "g": a[1], "b": a[2], "a": 1},
        {"pos": 1, "r": b[0], "g": b[1], "b": b[2], "a": 1},
    ]}


def _gris(a, b):
    return _gradiente((a, a, a), (b, b, b))


def _nodo(nombre, tipo, x, y, **parametros):
    return {"name": nombre, "type": tipo, "node_position": {"x": x, "y": y}, "parameters": parametros}


def ptex(nombre, d):
    nodos, conexiones = [], []

    def unir(origen, puerto_o, destino, puerto_d):
        conexiones.append({"from": origen, "from_port": puerto_o, "to": destino, "to_port": puerto_d})

    tipo = d["ruido"][0]
    if tipo == "perlin":
        nodos.append(_nodo("ruido", "perlin", -600, 0, scale_x=d["ruido"][1], scale_y=d["ruido"][1],
                           iterations=d["ruido"][2], persistence=0.5))
        color_src = alto_src = ("ruido", 0)
    elif tipo == "cepillado":  # vetas finas horizontales (metal cepillado)
        nodos.append(_nodo("ruido", "fbm2", -600, 0, noise=0, scale_x=2, scale_y=d["ruido"][1],
                           folds=0, iterations=3, persistence=0.5, offset=0))
        color_src = alto_src = ("ruido", 0)
    else:  # celdas (voronoi): 0 = distancia, 1 = bordes, 2 = color aleatorio por celda
        e = d["ruido"][1]
        nodos.append(_nodo("ruido", "voronoi", -600, 0, scale_x=e, scale_y=e, stretch_x=1, stretch_y=1,
                           intensity=1, randomness=0.85))
        if nombre.startswith("gema"):
            color_src, alto_src = ("ruido", 2), ("ruido", 1)  # una tonalidad por faceta, aristas marcadas
        else:
            color_src = alto_src = ("ruido", 0)  # grano del cuero

    nodos.append(_nodo("albedo", "colorize", -300, -200, gradient=_gradiente(*d["color"])))
    nodos.append(_nodo("rugosidad", "colorize", -300, 0, gradient=_gris(*d["rug"])))
    nodos.append(_nodo("metal", "uniform_greyscale", -300, 150, color=float(d["metal"])))
    nodos.append(_nodo("ao", "uniform_greyscale", -300, 250, color=1.0))
    nodos.append(_nodo("altura", "colorize", -450, 350, gradient=_gris(0.0, 1.0)))
    nodos.append(_nodo("normal", "normal_map", -300, 350, param0=TAM_LOG2, param1=d["relieve"], param2=0, param4=1))
    nodos.append(_nodo("Material", "material", 0, 0, albedo_color={"type": "Color", "r": 1, "g": 1, "b": 1, "a": 1},
                       metallic=1, roughness=1, emission_energy=1, normal=1, ao=1, depth_scale=0.5,
                       flags_transparent=False, sss=0, size=TAM_LOG2))

    unir(color_src[0], color_src[1], "albedo", 0)
    unir("ruido", 0, "rugosidad", 0)
    unir(alto_src[0], alto_src[1], "altura", 0)
    unir("altura", 0, "normal", 0)
    unir("albedo", 0, "Material", 0)
    unir("metal", 0, "Material", 1)
    unir("rugosidad", 0, "Material", 2)
    unir("normal", 0, "Material", 4)
    unir("ao", 0, "Material", 5)
    return {"name": nombre, "label": nombre, "type": "graph", "node_position": {"x": 0, "y": 0},
            "parameters": {}, "nodes": nodos, "connections": conexiones}


# ---------------------------------------------------------------------------
# Material Maker y conversión de mapas
# ---------------------------------------------------------------------------

def buscar_material_maker():
    candidatos = [os.environ.get("MATERIAL_MAKER", ""),
                  "/Applications/Material Maker.app/Contents/MacOS/Material Maker"]
    candidatos += glob.glob(os.path.join(os.path.expanduser("~"), "Desktop", "material_maker*", "material_maker.exe"))
    candidatos += glob.glob(os.path.join(os.path.expanduser("~"), "Escritorio", "material_maker*", "material_maker.exe"))
    for ruta in candidatos:
        if ruta and os.path.isfile(ruta):
            return ruta
    raise SystemExit("No se encontró Material Maker. Indica su ruta en la variable MATERIAL_MAKER.")


def exportar_mm(mm, ruta_ptex, salida):
    # «Godot 4 ORM» exporta albedo, normal (OpenGL) y ORM (R = oclusión, G = rugosidad, B = metálico)
    comando = [mm, "--export-material", "-t", "Godot/Godot 4 ORM", "-o", salida, "--size", str(2 ** TAM_LOG2), ruta_ptex]
    resultado = subprocess.run(comando, capture_output=True, text=True, timeout=300)
    if "succesfully exported" not in resultado.stdout and "successfully exported" not in resultado.stdout:
        print(resultado.stdout[-2000:], resultado.stderr[-2000:])
        raise SystemExit(f"Material Maker no exportó {ruta_ptex}")


def _leer(ruta):
    imagen = bpy.data.images.load(ruta)
    w, h = imagen.size
    pixeles = np.array(imagen.pixels[:], dtype=np.float32).reshape(h, w, 4)
    bpy.data.images.remove(imagen)
    return pixeles


def _guardar(pixeles, ruta, gris=False):
    h, w = pixeles.shape[:2]
    imagen = bpy.data.images.new(os.path.basename(ruta), w, h, alpha=False)
    if gris:
        imagen.colorspace_settings.name = "Non-Color"
    imagen.pixels = pixeles.ravel()
    imagen.filepath_raw = ruta
    imagen.file_format = "PNG"
    imagen.save()
    bpy.data.images.remove(imagen)


def convertir(nombre, carpeta):
    base = os.path.join(carpeta, "mm_" + nombre)
    color = _leer(base + "_albedo.png")
    color[:, :, 3] = 1
    _guardar(color, os.path.join(EXPORT, f"tex_{nombre}_color.png"))
    shutil.copyfile(base + "_normal.png", os.path.join(EXPORT, f"tex_{nombre}_normal.png"))
    orm = _leer(base + "_orm.png")
    for canal, sufijo in ((1, "rugosidad"), (2, "metalico")):
        gris = np.repeat(orm[:, :, canal:canal + 1], 4, axis=2)
        gris[:, :, 3] = 1
        _guardar(gris, os.path.join(EXPORT, f"tex_{nombre}_{sufijo}.png"), gris=True)
    return float(orm[:, :, 1].mean()), float(orm[:, :, 2].mean()), color.shape[1]


def main():
    opciones = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(FUENTES, exist_ok=True)
    os.makedirs(EXPORT, exist_ok=True)
    if "sin_ptex" not in opciones:
        for nombre, d in MATERIALES.items():
            with open(os.path.join(FUENTES, f"mm_{nombre}.ptex"), "w", encoding="utf-8") as f:
                json.dump(ptex("mm_" + nombre, d), f, indent=1)
    carpeta = tempfile.mkdtemp(prefix="mm_relojes_")
    mm = buscar_material_maker()
    print("Material Maker:", mm)
    resumen = []
    for nombre in MATERIALES:
        exportar_mm(mm, os.path.join(FUENTES, f"mm_{nombre}.ptex"), carpeta)
        rug, met, tam = convertir(nombre, carpeta)
        resumen.append(f"{nombre}: {tam}px · rugosidad media {rug:.2f} · metálico medio {met:.2f}")
    shutil.rmtree(carpeta, ignore_errors=True)
    print("=== Materiales PBR ===")
    print("\n".join(resumen))


main()
