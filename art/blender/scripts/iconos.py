"""
iconos.py — renderiza los iconos del HUD (ART-004) como PNG de 256×256 con fondo transparente.

    blender --background --factory-startup --python art/blender/scripts/iconos.py

Salida: art/texturas/export/ico_*.png (para subir a Roblox y retocar en Krita).
"""

import math
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402
import modelos_prioridad3 as P3  # noqa: E402

SALIDA = os.path.join(A.ART, "texturas", "export")


def render_icono(nombre, constructor):
    A.limpiar_escena()
    A.crear_paleta()
    constructor()
    escena = bpy.context.scene
    # Cámara ortográfica de frente (desde -Y), con un leve giro para dar volumen
    bpy.ops.object.camera_add(location=(1.2, -10, 1.0), rotation=(math.radians(84), 0, math.radians(7)))
    camara = bpy.context.active_object
    camara.data.type = "ORTHO"
    camara.data.ortho_scale = 4.6
    escena.camera = camara
    escena.render.engine = "BLENDER_WORKBENCH"
    escena.display.shading.color_type = "TEXTURE"
    escena.display.shading.light = "STUDIO"
    escena.display.shading.show_object_outline = True
    escena.display.shading.object_outline_color = (0.08, 0.08, 0.1)
    escena.render.resolution_x = 256
    escena.render.resolution_y = 256
    escena.render.film_transparent = True
    escena.render.image_settings.color_mode = "RGBA"
    os.makedirs(SALIDA, exist_ok=True)
    escena.render.filepath = os.path.join(SALIDA, nombre + ".png")
    bpy.ops.render.render(write_still=True)
    print("icono ->", nombre)


for nombre, constructor in P3.ICONOS.items():
    render_icono(nombre, constructor)
