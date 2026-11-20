"""
arte_comun.py — utilidades compartidas para generar assets low-poly con Blender (ART-001).

Estilo: low-poly colorido tipo «simulador de Roblox». Todos los modelos usan UNA
sola textura de paleta (art/texturas/export/tex_paleta.png): cada cara se pinta
asignando sus UV al centro de una celda de color. Así un único material sirve
para todo el juego y la paleta se puede retocar en Krita sin tocar los modelos.

Unidades: 1 unidad de Blender = 1 stud de Roblox. Al importar en Studio
(3D Importer) se elige la unidad «Stud».

Uso (sin abrir la interfaz de Blender):
    blender --background --factory-startup --python art/blender/scripts/generar_todo.py
"""

import math
import os

import bpy

# Raíz del repositorio: art/blender/scripts/ → ../../..
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
ART = os.path.join(REPO, "art")
EXPORT_MODELOS = os.path.join(ART, "export", "modelos")
FUENTES_BLEND = os.path.join(ART, "blender", "fuentes")
PALETA_PNG = os.path.join(ART, "texturas", "export", "tex_paleta.png")

# Paleta del proyecto (PROPUESTA ART-001). Nombre → color hex.
# 16 colores en una cuadrícula de 4×4 celdas de 64 px (imagen de 256×256).
PALETA = [
    ("negro", "1E1F26"), ("gris_oscuro", "3C3F4A"), ("gris", "8A8D99"), ("blanco", "F2F0EA"),
    ("madera", "A8703F"), ("madera_oscura", "6B4426"), ("dorado", "F2C14E"), ("bronce", "C27B3A"),
    ("rojo", "D9534F"), ("naranja", "F08A3C"), ("verde", "5CB85C"), ("verde_oscuro", "2E7D4F"),
    ("azul", "4A90D9"), ("azul_oscuro", "2C4F80"), ("morado", "9B59B6"), ("cian", "5BD5E0"),
]
CELDAS = 4
TAM_CELDA = 64


def _hex_rgb(value):
    return tuple(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4))


def limpiar_escena():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    escena = bpy.context.scene
    escena.unit_settings.system = "NONE"  # 1 unidad = 1 stud


def crear_paleta():
    """Crea (o recrea) la textura de paleta y la guarda como PNG."""
    tam = CELDAS * TAM_CELDA
    imagen = bpy.data.images.get("tex_paleta") or bpy.data.images.new("tex_paleta", tam, tam, alpha=False)
    pixeles = [0.0] * (tam * tam * 4)
    for indice, (_, valor) in enumerate(PALETA):
        r, g, b = _hex_rgb(valor)
        columna, fila = indice % CELDAS, indice // CELDAS
        for y in range(fila * TAM_CELDA, (fila + 1) * TAM_CELDA):
            for x in range(columna * TAM_CELDA, (columna + 1) * TAM_CELDA):
                i = (y * tam + x) * 4
                pixeles[i:i + 4] = (r, g, b, 1.0)
    imagen.pixels = pixeles
    os.makedirs(os.path.dirname(PALETA_PNG), exist_ok=True)
    imagen.filepath_raw = PALETA_PNG
    imagen.file_format = "PNG"
    imagen.save()
    return imagen


def material_paleta():
    """Un único material que usa la paleta (sin suavizar los píxeles)."""
    material = bpy.data.materials.get("mat_paleta")
    if material:
        return material
    material = bpy.data.materials.new("mat_paleta")
    material.use_nodes = True
    nodos = material.node_tree.nodes
    bsdf = nodos.get("Principled BSDF")
    textura = nodos.new("ShaderNodeTexImage")
    textura.image = bpy.data.images.get("tex_paleta") or crear_paleta()
    textura.interpolation = "Closest"
    material.node_tree.links.new(textura.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.8
    return material


def uv_de_color(nombre):
    indice = [n for n, _ in PALETA].index(nombre)
    columna, fila = indice % CELDAS, indice // CELDAS
    return ((columna + 0.5) / CELDAS, (fila + 0.5) / CELDAS)


def pintar(objeto, color):
    """Pinta todo el objeto de un color de la paleta (UV al centro de la celda)."""
    malla = objeto.data
    if not malla.uv_layers:
        malla.uv_layers.new(name="UVMap")
    u, v = uv_de_color(color)
    for loop in malla.uv_layers.active.data:
        loop.uv = (u, v)
    malla.materials.clear()
    malla.materials.append(material_paleta())
    for poligono in malla.polygons:
        poligono.use_smooth = False  # sombreado plano, propio del low-poly
    return objeto


def caja(nombre, tam, pos, color):
    """Caja de tamaño (ancho X, largo Y, alto Z) en studs; pos = centro."""
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    objeto = bpy.context.active_object
    objeto.name = nombre
    objeto.scale = tam
    bpy.ops.object.transform_apply(scale=True)
    return pintar(objeto, color)


def cilindro(nombre, radio, alto, pos, color, lados=12, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=lados, radius=radio, depth=alto, location=pos, rotation=rot)
    objeto = bpy.context.active_object
    objeto.name = nombre
    bpy.ops.object.transform_apply(rotation=True)
    return pintar(objeto, color)


def esfera(nombre, radio, pos, color, segmentos=10, anillos=6, escala=(1, 1, 1)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segmentos, ring_count=anillos, radius=radio, location=pos)
    objeto = bpy.context.active_object
    objeto.name = nombre
    objeto.scale = escala
    bpy.ops.object.transform_apply(scale=True)
    return pintar(objeto, color)


def cono(nombre, radio_abajo, radio_arriba, alto, pos, color, lados=8, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=lados, radius1=radio_abajo, radius2=radio_arriba, depth=alto, location=pos, rotation=rot)
    objeto = bpy.context.active_object
    objeto.name = nombre
    bpy.ops.object.transform_apply(rotation=True)
    return pintar(objeto, color)


def anillo(nombre, radio, grosor, pos, color, lados=12, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=radio, minor_radius=grosor, major_segments=lados,
                                     minor_segments=4, location=pos, rotation=rot)
    objeto = bpy.context.active_object
    objeto.name = nombre
    bpy.ops.object.transform_apply(rotation=True)
    return pintar(objeto, color)


def prisma_triangular(nombre, ancho, largo, alto, pos, color):
    """Tejado a dos aguas: prisma de base ancho (X) × largo (Y) y altura alto (Z)."""
    w, l = ancho / 2, largo / 2
    vertices = [(-w, -l, 0), (w, -l, 0), (0, -l, alto), (-w, l, 0), (w, l, 0), (0, l, alto)]
    caras = [(0, 1, 2), (3, 5, 4), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]
    malla = bpy.data.meshes.new(nombre)
    malla.from_pydata(vertices, [], caras)
    malla.update()
    objeto = bpy.data.objects.new(nombre, malla)
    objeto.location = pos
    bpy.context.collection.objects.link(objeto)
    bpy.context.view_layer.objects.active = objeto
    return pintar(objeto, color)


def prisma_poligono(nombre, puntos, grosor, pos, color):
    """Extruye un contorno 2D (lista de (x, z), en orden) con grosor en Y. Útil para iconos."""
    n = len(puntos)
    frente = [(x, -grosor / 2, z) for x, z in puntos]
    detras = [(x, grosor / 2, z) for x, z in puntos]
    caras = [tuple(range(n - 1, -1, -1)), tuple(range(n, 2 * n))]
    for i in range(n):
        j = (i + 1) % n
        caras.append((i, j, n + j, n + i))
    malla = bpy.data.meshes.new(nombre)
    malla.from_pydata(frente + detras, [], caras)
    malla.update()
    objeto = bpy.data.objects.new(nombre, malla)
    objeto.location = pos
    bpy.context.collection.objects.link(objeto)
    bpy.context.view_layer.objects.active = objeto
    return pintar(objeto, color)


def unir(nombre, objetos):
    """Une varias piezas en una sola malla (un MeshPart en Roblox)."""
    # Recalcula las matrices: si una pieza se giró después de crearla, sin esto
    # se uniría en su posición antigua (error encontrado en ART-004).
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action="DESELECT")
    for objeto in objetos:
        objeto.select_set(True)
    bpy.context.view_layer.objects.active = objetos[0]
    bpy.ops.object.join()
    resultado = bpy.context.active_object
    resultado.name = nombre
    # Origen en la base del modelo, centrado (cómodo para colocar en Studio)
    bpy.context.scene.cursor.location = (0, 0, 0)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
    return resultado


def triangulos(objeto):
    return sum(len(p.vertices) - 2 for p in objeto.data.polygons)


def exportar(objeto, nombre):
    """Guarda la fuente .blend y exporta el FBX. Devuelve (ruta_fbx, triángulos)."""
    os.makedirs(EXPORT_MODELOS, exist_ok=True)
    os.makedirs(FUENTES_BLEND, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    objeto.select_set(True)
    bpy.context.view_layer.objects.active = objeto
    ruta_fbx = os.path.join(EXPORT_MODELOS, nombre + ".fbx")
    bpy.ops.export_scene.fbx(
        filepath=ruta_fbx,
        use_selection=True,
        apply_unit_scale=True,
        global_scale=1.0,
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        path_mode="STRIP",  # la textura se sube aparte (tex_paleta.png)
        bake_anim=False,
    )
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(FUENTES_BLEND, nombre + ".blend"))
    return ruta_fbx, triangulos(objeto)


def anillo_poligonal(radio, lados=12):
    return [(math.cos(2 * math.pi * i / lados) * radio, math.sin(2 * math.pi * i / lados) * radio) for i in range(lados)]
