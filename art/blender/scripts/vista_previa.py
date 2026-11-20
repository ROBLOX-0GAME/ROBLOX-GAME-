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


def preparar_eevee(escena):
    """EEVEE con un cielo en degradado (los metales necesitan algo que reflejar) y luz de estudio."""
    motores = [i.identifier for i in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items]
    escena.render.engine = "BLENDER_EEVEE" if "BLENDER_EEVEE" in motores else "BLENDER_EEVEE_NEXT"
    mundo = bpy.data.worlds.new("estudio")
    escena.world = mundo
    mundo.use_nodes = True
    nodos, enlaces = mundo.node_tree.nodes, mundo.node_tree.links
    coordenadas = nodos.new("ShaderNodeTexCoord")
    separar = nodos.new("ShaderNodeSeparateXYZ")
    rampa = nodos.new("ShaderNodeValToRGB")
    rampa.color_ramp.elements[0].position = 0.35
    rampa.color_ramp.elements[0].color = (0.08, 0.07, 0.06, 1)  # suelo oscuro
    rampa.color_ramp.elements[1].position = 0.6
    rampa.color_ramp.elements[1].color = (1.0, 0.98, 0.95, 1)  # cielo claro
    mapa = nodos.new("ShaderNodeMapRange")
    mapa.inputs["From Min"].default_value = -1
    enlaces.new(coordenadas.outputs["Generated"], separar.inputs["Vector"])
    enlaces.new(separar.outputs["Z"], mapa.inputs["Value"])
    enlaces.new(mapa.outputs["Result"], rampa.inputs["Fac"])
    fondo = nodos.get("Background")
    enlaces.new(rampa.outputs["Color"], fondo.inputs["Color"])
    fondo.inputs["Strength"].default_value = 1.2
    bpy.ops.object.light_add(type="AREA", location=(-3, -4, 4))
    luz = bpy.context.active_object
    luz.data.energy = 300
    luz.data.size = 3
    luz.rotation_euler = (math.radians(50), 0, math.radians(-35))


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
    if escena.get("render_pbr"):
        preparar_eevee(escena)  # modelos con materiales PBR (relojes de ART-006)
    else:
        escena.render.engine = "BLENDER_WORKBENCH"
        escena.display.shading.color_type = "TEXTURE"
        escena.display.shading.light = "STUDIO"
    escena.render.resolution_x = 512
    escena.render.resolution_y = 512
    escena.render.film_transparent = True
    os.makedirs(VISTAS, exist_ok=True)
    nombre = os.path.splitext(os.path.basename(ruta_blend))[0]
    escena.render.filepath = os.path.join(VISTAS, nombre + ".png")
    bpy.ops.render.render(write_still=True)
    print("vista ->", escena.render.filepath)


def hoja_de_contactos(columnas=6, tam=256):
    """Une todas las vistas en una sola imagen (art/export/vistas/_hoja_contactos.png)."""
    import numpy as np

    archivos = sorted(f for f in os.listdir(VISTAS) if f.endswith(".png") and not f.startswith("_"))
    filas = (len(archivos) + columnas - 1) // columnas
    hoja = np.ones((filas * tam, columnas * tam, 4), dtype=np.float32)
    for indice, archivo in enumerate(archivos):
        imagen = bpy.data.images.load(os.path.join(VISTAS, archivo))
        imagen.scale(tam, tam)
        pixeles = np.array(imagen.pixels[:], dtype=np.float32).reshape(tam, tam, 4)
        # Fondo transparente → blanco, para revisarla cómodamente
        alfa = pixeles[:, :, 3:4]
        pixeles[:, :, :3] = pixeles[:, :, :3] * alfa + (1 - alfa)
        pixeles[:, :, 3] = 1
        fila, columna = indice // columnas, indice % columnas
        # Blender guarda las filas de abajo arriba
        y = (filas - 1 - fila) * tam
        hoja[y:y + tam, columna * tam:(columna + 1) * tam] = pixeles
        bpy.data.images.remove(imagen)
    salida = bpy.data.images.new("hoja", columnas * tam, filas * tam, alpha=True)
    salida.pixels = hoja.ravel()
    salida.filepath_raw = os.path.join(VISTAS, "_hoja_contactos.png")
    salida.file_format = "PNG"
    salida.save()
    print("hoja de contactos ->", salida.filepath_raw)
    print("orden:", ", ".join(os.path.splitext(a)[0] for a in archivos))


pedidos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else None
for archivo in sorted(os.listdir(A.FUENTES_BLEND)):
    if archivo.endswith(".blend") and (pedidos is None or os.path.splitext(archivo)[0] in pedidos):
        renderizar(os.path.join(A.FUENTES_BLEND, archivo))
hoja_de_contactos()
