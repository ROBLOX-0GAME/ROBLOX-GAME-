"""
vista_previa.py — renderiza una imagen de cada modelo para revisarlo sin abrir Blender.

    blender --background --factory-startup --python art/blender/scripts/vista_previa.py

Crea art/export/vistas/<modelo>.png a partir de art/blender/fuentes/<modelo>.blend.
"""

import math
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402

VISTAS = os.path.join(A.ART, "export", "vistas")


def renderizar(ruta_blend):
    bpy.ops.wm.open_mainfile(filepath=ruta_blend)
    escena = bpy.context.scene
    objetos = [o for o in escena.objects if o.type == "MESH"]
    # Encuadre: cámara en diagonal que abarca el modelo
    tam = max(max(o.dimensions) for o in objetos)
    centro_z = max(o.dimensions.z for o in objetos) / 2
    distancia = tam * 1.9
    bpy.ops.object.camera_add(location=(distancia, -distancia, centro_z + distancia * 0.7))
    camara = bpy.context.active_object
    direccion = (-distancia, distancia, -distancia * 0.7)
    camara.rotation_euler = (math.atan2(math.hypot(direccion[0], direccion[1]), -direccion[2]), 0, math.atan2(direccion[1], direccion[0]) - math.pi / 2)
    escena.camera = camara
    bpy.ops.object.light_add(type="SUN", location=(5, -5, 10))
    escena.render.engine = "BLENDER_WORKBENCH"
    escena.display.shading.color_type = "TEXTURE"
    escena.display.shading.light = "STUDIO"
    escena.render.resolution_x = 512
    escena.render.resolution_y = 512
    escena.render.film_transparent = False
    os.makedirs(VISTAS, exist_ok=True)
    nombre = os.path.splitext(os.path.basename(ruta_blend))[0]
    escena.render.filepath = os.path.join(VISTAS, nombre + ".png")
    bpy.ops.render.render(write_still=True)
    print("vista ->", escena.render.filepath)


for archivo in sorted(os.listdir(A.FUENTES_BLEND)):
    if archivo.endswith(".blend"):
        renderizar(os.path.join(A.FUENTES_BLEND, archivo))
