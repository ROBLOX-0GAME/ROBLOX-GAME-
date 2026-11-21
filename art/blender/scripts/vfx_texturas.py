"""
vfx_texturas.py — ART-018: texturas de efectos de armado ([[PROMPT_PIEZAS_RELOJ_ZADIEL]] §7.2).

Flipbooks de 1024 × 1024 con transparencia, en BLANCO (el ParticleEmitter los tiñe con el
color de la rareza): cada cuadro centrado.
  vfx_chispa_4x4.png      chispa en cruz que se apaga         (FlipbookLayout = Grid4x4)
  vfx_engranaje_8x8.png   engranaje que gira una vuelta        (Grid8x8)
  vfx_estrella_4x4.png    destello de 4 puntas que parpadea   (Grid4x4)
  vfx_confeti_4x4.png     engranaje pequeño dando vueltas     (Grid4x4)
  vfx_anillo_4x4.png      anillo de choque que se expande      (Grid4x4)
Texturas de Beam (256 × 64, degradado a transparente en los extremos):
  vfx_rayo_dorado.png, vfx_rayo_cian.png

Todo procedural (sin recursos externos).
    /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
        --python art/blender/scripts/vfx_texturas.py
"""

import math
import os
import sys

import bpy
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402

SALIDA = os.path.join(A.ART, "texturas", "export")


def guardar(nombre, rgba):
    alto, ancho = rgba.shape[:2]
    imagen = bpy.data.images.new(nombre, ancho, alto, alpha=True)
    imagen.pixels = np.flipud(rgba).astype(np.float32).ravel().tolist()  # Blender empieza abajo
    imagen.filepath_raw = os.path.join(SALIDA, nombre + ".png")
    imagen.file_format = "PNG"
    imagen.save()
    bpy.data.images.remove(imagen)


def rejilla(n, tam, cuadro):
    """Monta n × n cuadros (función i → alfa de tam × tam) en una hoja blanca con alfa."""
    hoja = np.zeros((n * tam, n * tam, 4), dtype=np.float32)
    hoja[..., :3] = 1.0
    for i in range(n * n):
        f, c = divmod(i, n)
        hoja[f * tam:(f + 1) * tam, c * tam:(c + 1) * tam, 3] = np.clip(cuadro(i / (n * n - 1), tam), 0, 1)
    return hoja


def coords(tam):
    y, x = np.mgrid[0:tam, 0:tam].astype(np.float32)
    x = (x + 0.5) / tam * 2 - 1
    y = (y + 0.5) / tam * 2 - 1
    return x, y, np.sqrt(x * x + y * y), np.arctan2(y, x)


def suave(d, borde):
    return np.clip(0.5 - d / borde, 0, 1)


def chispa(t, tam):
    x, y, r, _ = coords(tam)
    fuerza = (1 - t) ** 1.5
    cruz = np.exp(-(np.abs(x) * 9) ** 2 / (0.02 + 0.6 * fuerza)) * np.exp(-np.abs(y) * 3) + \
        np.exp(-(np.abs(y) * 9) ** 2 / (0.02 + 0.6 * fuerza)) * np.exp(-np.abs(x) * 3)
    nucleo = np.exp(-(r / (0.18 * fuerza + 0.02)) ** 2)
    return (cruz * 0.8 + nucleo) * fuerza


def engranaje(angulo, tam, radio=0.62, dientes=10):
    _, _, r, a = coords(tam)
    perfil = radio * (1 + 0.16 * np.clip(np.cos(dientes * (a - angulo)) * 3, -1, 1))
    cuerpo = suave(r - perfil, 0.03)
    hueco = suave(r - radio * 0.32, 0.03)  # 1 dentro del hueco
    return np.clip(cuerpo - hueco, 0, 1)


def estrella(t, tam):
    x, y, r, _ = coords(tam)
    brillo = math.sin(math.pi * t)
    puntas = np.exp(-np.abs(x) * 14) * np.exp(-np.abs(y) * 2.2) + np.exp(-np.abs(y) * 14) * np.exp(-np.abs(x) * 2.2)
    return (puntas + np.exp(-(r / 0.12) ** 2)) * brillo


def confeti(t, tam):
    # engranaje pequeño que da vueltas: se achata en X para fingir el giro 3D
    x, y, _, _ = coords(tam)
    escala = max(abs(math.cos(2 * math.pi * t)), 0.15)
    xs = x / escala
    r = np.sqrt(xs * xs + y * y)
    a = np.arctan2(y, xs)
    perfil = 0.45 * (1 + 0.18 * np.clip(np.cos(8 * (a - t * 2 * math.pi)) * 3, -1, 1))
    return np.clip(suave(r - perfil, 0.04) - suave(r - 0.14, 0.04), 0, 1)


def anillo(t, tam):
    _, _, r, _ = coords(tam)
    radio = 0.1 + 0.8 * t
    grosor = 0.12 * (1 - t) + 0.02
    return np.exp(-((r - radio) / grosor) ** 2) * (1 - t) ** 0.7


def rayo(color):
    alto, ancho = 64, 256
    y, x = np.mgrid[0:alto, 0:ancho].astype(np.float32)
    u = (x + 0.5) / ancho
    v = (y + 0.5) / alto * 2 - 1
    centro = np.exp(-(v / 0.35) ** 2)
    extremos = np.clip(np.minimum(u, 1 - u) / 0.2, 0, 1)
    rgba = np.zeros((alto, ancho, 4), dtype=np.float32)
    nucleo = np.exp(-(v / 0.12) ** 2)[..., None]
    rgba[..., :3] = np.array(color, dtype=np.float32) * (1 - nucleo) + nucleo  # centro casi blanco
    rgba[..., 3] = centro * extremos
    return rgba


if __name__ == "__main__":
    os.makedirs(SALIDA, exist_ok=True)
    guardar("vfx_chispa_4x4", rejilla(4, 256, chispa))
    guardar("vfx_engranaje_8x8", rejilla(8, 128, lambda t, tam: engranaje(t * 2 * math.pi / 10, tam)))
    guardar("vfx_estrella_4x4", rejilla(4, 256, estrella))
    guardar("vfx_confeti_4x4", rejilla(4, 256, confeti))
    guardar("vfx_anillo_4x4", rejilla(4, 256, anillo))
    guardar("vfx_rayo_dorado", rayo(A._hex_rgb("F2C14E")))
    guardar("vfx_rayo_cian", rayo(A._hex_rgb("5BD5E0")))
    print("== texturas de efectos: 5 flipbooks y 2 rayos")
