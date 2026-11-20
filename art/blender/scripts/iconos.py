"""
iconos.py — renderiza los iconos del HUD (ART-004, retocados en ART-010) como PNG de 256×256 con fondo transparente.

    blender --background --factory-startup --python art/blender/scripts/iconos.py

Salida: art/texturas/export/ico_*.png (para subir a Roblox y retocar en Krita).

ART-010 (propuesta de estilo para Michael y Einell):
- Contorno oscuro (color «negro» de la paleta) y sombra suave alrededor de cada icono,
  para que se lean a 32-48 px sobre cualquier fondo del HUD.
- Transformación de color «Standard» (antes AgX, que apagaba los colores de la paleta).
- Formas nuevas para monedas (dos monedas de distinto tono con estrella), mochila
  (tapa, hebilla, bolsillo y correas), carga (cajas apiladas) y robux (gema verde
  original; el hexágono anterior se parecía al logotipo oficial).
Las formas de modelos_prioridad3.ICONOS se reutilizan para el resto.
"""

import math
import os
import sys

import bpy
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402
import modelos_prioridad3 as P3  # noqa: E402

SALIDA = os.path.join(A.ART, "texturas", "export")
FRENTE = P3.FRENTE

# Contorno y sombra (en píxeles de la imagen de 256 px)
GROSOR_CONTORNO = 7
COLOR_CONTORNO = A._hex_rgb("1E1F26")  # «negro» de la paleta, en sRGB 0-1
SOMBRA_DESPLAZAMIENTO = (3, 5)  # (x, y) hacia abajo a la derecha
SOMBRA_OPACIDAD = 0.35


# ---------------------------------------------------------------------------
# Formas nuevas (ART-010). Frente hacia -Y, contornos 2D en (x, z).
# ---------------------------------------------------------------------------


def _estrella(radio_ext, radio_int, puntas=5):
    puntos = []
    for i in range(puntas * 2):
        r = radio_ext if i % 2 == 0 else radio_int
        a = math.pi / 2 + math.pi * i / puntas
        puntos.append((math.cos(a) * r, math.sin(a) * r))
    return puntos


def icono_monedas():
    # Moneda trasera en bronce y delantera en dorado: dos tonos para que no se fundan
    piezas = [
        A.cilindro("moneda_atras", 1.0, 0.3, (-0.6, 0.35, 0.5), "bronce", lados=16, rot=FRENTE),
        A.anillo("canto_atras", 0.72, 0.08, (-0.6, 0.15, 0.5), "madera", lados=16, rot=FRENTE),
        A.cilindro("moneda", 1.2, 0.35, (0.35, 0, -0.3), "dorado", lados=18, rot=FRENTE),
        A.anillo("canto", 0.9, 0.1, (0.35, -0.2, -0.3), "bronce", lados=18, rot=FRENTE),
    ]
    estrella = A.prisma_poligono("estrella", _estrella(0.55, 0.24), 0.2, (0.35, -0.22, -0.3), "bronce")
    piezas.append(estrella)
    return piezas


def icono_mochila():
    return [
        A.caja("correa_izq", (0.25, 0.5, 2.0), (-1.1, 0.15, -0.15), "madera_oscura"),
        A.caja("correa_der", (0.25, 0.5, 2.0), (1.1, 0.15, -0.15), "madera_oscura"),
        A.caja("cuerpo", (2.0, 1.0, 2.3), (0, 0, -0.15), "naranja"),
        A.caja("tapa", (2.1, 1.1, 0.85), (0, -0.03, 0.75), "bronce"),
        A.caja("cierre", (0.3, 0.2, 0.55), (0, -0.62, 0.35), "madera_oscura"),
        A.caja("hebilla", (0.45, 0.25, 0.3), (0, -0.66, 0.2), "dorado"),
        A.caja("bolsillo", (1.3, 0.35, 0.8), (0, -0.6, -0.75), "bronce"),
        A.anillo("asa", 0.42, 0.12, (0, 0, 1.4), "madera_oscura", lados=10, rot=FRENTE),
    ]


def _caja_carga(nombre, pos, color):
    x, y, z = pos
    return [
        A.caja(nombre, (1.45, 1.0, 1.15), pos, color),
        A.caja(nombre + "_fleje", (1.5, 1.05, 0.22), (x, y, z), "madera_oscura"),
        A.caja(nombre + "_liston", (0.22, 1.05, 1.2), (x, y - 0.01, z), "madera_oscura"),
    ]


def icono_carga():
    # Cajas apiladas: «cuántos objetos llevas por viaje»
    return (_caja_carga("caja_izq", (-0.78, 0, -0.85), "madera")
            + _caja_carga("caja_der", (0.78, 0, -0.85), "bronce")
            + _caja_carga("caja_arriba", (0, 0, 0.35), "madera"))


def icono_robux():
    # Gema verde tallada (dibujo original, no el logotipo oficial)
    contorno = [(0, -1.45), (1.25, 0.35), (0.7, 1.1), (-0.7, 1.1), (-1.25, 0.35)]
    mesa = [(0, -0.55), (0.6, 0.35), (0.35, 0.8), (-0.35, 0.8), (-0.6, 0.35)]
    brillo = [(-0.5, 0.45), (-0.3, 0.72), (-0.05, 0.72), (-0.3, 0.45)]
    return [
        A.prisma_poligono("gema", contorno, 0.4, (0, 0, 0), "verde"),
        A.prisma_poligono("mesa", mesa, 0.45, (0, -0.03, 0), "verde_oscuro"),
        A.prisma_poligono("brillo", brillo, 0.5, (0, -0.06, 0), "cian"),
    ]


ICONOS = dict(P3.ICONOS)
ICONOS.update({
    "ico_monedas": icono_monedas,
    "ico_mochila": icono_mochila,
    "ico_carga": icono_carga,
    "ico_robux": icono_robux,
})


# ---------------------------------------------------------------------------
# Render y contorno
# ---------------------------------------------------------------------------


def _dilatar(alfa, radio):
    """Máximo de la transparencia en un disco de `radio` píxeles."""
    alto, ancho = alfa.shape
    relleno = np.pad(alfa, radio)
    salida = np.zeros_like(alfa)
    for dy in range(-radio, radio + 1):
        for dx in range(-radio, radio + 1):
            if dx * dx + dy * dy <= radio * radio + radio:
                trozo = relleno[radio + dy:radio + dy + alto, radio + dx:radio + dx + ancho]
                np.maximum(salida, trozo, out=salida)
    return salida


def _desplazar(alfa, dx, dy):
    """Desplaza la máscara dx píxeles a la derecha y dy hacia abajo (la imagen de Blender empieza abajo)."""
    salida = np.zeros_like(alfa)
    alto, ancho = alfa.shape
    salida[0:alto - dy, dx:ancho] = alfa[dy:alto, 0:ancho - dx]
    return salida


def _sobre(arriba_rgb, arriba_a, abajo_rgb, abajo_a):
    """Composición «over» con transparencia no premultiplicada."""
    a = arriba_a + abajo_a * (1 - arriba_a)
    seguro = np.where(a > 0, a, 1)
    rgb = (arriba_rgb * arriba_a[..., None] + abajo_rgb * (abajo_a * (1 - arriba_a))[..., None]) / seguro[..., None]
    return rgb, a


def contornear(ruta):
    imagen = bpy.data.images.load(ruta)
    ancho, alto = imagen.size
    px = np.array(imagen.pixels[:], dtype=np.float32).reshape(alto, ancho, 4)
    rgb, alfa = px[..., :3], px[..., 3]

    borde = np.clip(_dilatar(alfa, GROSOR_CONTORNO), 0, 1)
    color_borde = np.broadcast_to(np.array(COLOR_CONTORNO, dtype=np.float32), rgb.shape)
    rgb, a = _sobre(rgb, alfa, color_borde, borde)

    sombra = _desplazar(borde, *SOMBRA_DESPLAZAMIENTO) * SOMBRA_OPACIDAD
    rgb, a = _sobre(rgb, a, color_borde, sombra)

    px[..., :3], px[..., 3] = rgb, a
    imagen.pixels = px.ravel().tolist()
    imagen.filepath_raw = ruta
    imagen.file_format = "PNG"
    imagen.save()
    bpy.data.images.remove(imagen)


def render_icono(nombre, constructor):
    A.limpiar_escena()
    A.crear_paleta()
    constructor()
    escena = bpy.context.scene
    # Cámara ortográfica de frente (desde -Y), con un leve giro para dar volumen
    bpy.ops.object.camera_add(location=(1.2, -10, 1.0), rotation=(math.radians(84), 0, math.radians(7)))
    camara = bpy.context.active_object
    camara.data.type = "ORTHO"
    camara.data.ortho_scale = 5.0  # margen para el contorno
    escena.camera = camara
    escena.render.engine = "BLENDER_WORKBENCH"
    escena.display.shading.color_type = "TEXTURE"
    escena.display.shading.light = "STUDIO"
    escena.display.shading.show_object_outline = True
    escena.display.shading.object_outline_color = (0.08, 0.08, 0.1)
    escena.view_settings.view_transform = "Standard"
    escena.view_settings.exposure = 0.45
    escena.render.resolution_x = 256
    escena.render.resolution_y = 256
    escena.render.film_transparent = True
    escena.render.image_settings.color_mode = "RGBA"
    os.makedirs(SALIDA, exist_ok=True)
    ruta = os.path.join(SALIDA, nombre + ".png")
    escena.render.filepath = ruta
    bpy.ops.render.render(write_still=True)
    contornear(ruta)
    print("icono ->", nombre)


for nombre, constructor in ICONOS.items():
    render_icono(nombre, constructor)
