"""
iconos_mesa.py — ART-018: iconos de la mesa de armado ([[PROMPT_PIEZAS_RELOJ_ZADIEL]] §6.3).

Mismo estilo que los iconos del HUD (iconos.py: Workbench, paleta, contorno oscuro y sombra):
  ico_pz_caja, ico_pz_calibre, ico_pz_esfera, ico_pz_manecillas      (las 4 clases de pieza)
  ico_calibre_cuarzo, ico_calibre_mecanico, ico_calibre_automatico   (tipo de calibre)
  ico_ok (✔) e ico_aviso (⚠)
y el marco de rareza de 9 partes `ui_marco_rareza.png` (blanco: el código lo colorea con
ImageColor3; SliceCenter = Rect(24, 24, 104, 104) sobre 128 × 128).

    /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
        --python art/blender/scripts/iconos_mesa.py
"""

import math
import os
import sys

import bpy
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402
import iconos as I  # noqa: E402  (no rehace los iconos del HUD al importarlo)

FRENTE = (math.pi / 2, 0, 0)


def _aro(radio, grosor, color, lados=24, y=0.0):
    return A.anillo("aro", radio, grosor, (0, y, 0), color, lados=lados, rot=FRENTE)


def _engranaje(radio, color, dientes=10, centro=(0, 0), y=0.0, hueco="bronce"):
    """Engranaje dibujado por su contorno (dientes exactos)."""
    cx, cz = centro
    contorno = []
    for i in range(dientes * 4):
        a = 2 * math.pi * i / (dientes * 4)
        r = radio * (1.22 if (i % 4) in (1, 2) else 1.0)
        contorno.append((cx + math.cos(a) * r, cz + math.sin(a) * r))
    return [A.prisma_poligono("engranaje", contorno, 0.3, (0, y, 0), color),
            A.cilindro("hueco", radio * 0.35, 0.34, (cx, y - 0.02, cz), hueco, lados=12, rot=FRENTE)]


def _aguja(largo, ancho, angulo, color, y):
    """Aguja como contorno 2D desde el centro; angulo 0 = las 12, horario visto de frente."""
    dx, dz = math.sin(angulo), math.cos(angulo)
    px, pz = dz, -dx  # perpendicular
    puntos = [(-px * ancho / 2 - dx * 0.15, -pz * ancho / 2 - dz * 0.15), (px * ancho / 2 - dx * 0.15, pz * ancho / 2 - dz * 0.15),
              (px * ancho * 0.3 + dx * largo, pz * ancho * 0.3 + dz * largo), (-px * ancho * 0.3 + dx * largo, -pz * ancho * 0.3 + dz * largo)]
    return A.prisma_poligono("aguja", puntos, 0.1, (0, y, 0), color)


def icono_caja():
    return [
        A.cilindro("caja", 1.15, 0.4, (0, 0.05, 0), "gris", lados=28, rot=FRENTE),
        A.cilindro("hueco", 0.85, 0.45, (0, 0, 0), "gris_oscuro", lados=28, rot=FRENTE),
        _aro(1.05, 0.1, "blanco", 28, -0.2),
        A.caja("asa", (0.75, 0.3, 0.5), (0, 0.05, 1.35), "gris"),
        A.caja("asa", (0.75, 0.3, 0.5), (0, 0.05, -1.35), "gris"),
        A.cilindro("corona", 0.16, 0.36, (1.3, 0.05, 0), "dorado", lados=10, rot=(0, math.pi / 2, 0)),
    ]


def icono_calibre():
    return ([A.cilindro("platina", 1.25, 0.3, (0, 0.15, 0), "bronce", lados=28, rot=FRENTE)]
            + _engranaje(0.5, "dorado", 10, (-0.35, 0.3), -0.1)
            + _engranaje(0.35, "dorado", 8, (0.5, 0.35), -0.1)
            + [A.esfera("rubi", 0.13, (0.25, -0.2, -0.55), "rojo", 8, 5),
               A.esfera("rubi", 0.13, (-0.55, -0.2, -0.45), "rojo", 8, 5)])


def icono_esfera():
    piezas = [A.cilindro("esfera", 1.2, 0.3, (0, 0, 0), "blanco", lados=28, rot=FRENTE),
              _aro(1.2, 0.08, "dorado", 28, -0.1)]
    for h in range(12):
        a = 2 * math.pi * h / 12
        t = 0.24 if h % 3 == 0 else 0.15
        piezas.append(A.caja("indice", (t, 0.1, t), (math.sin(a) * 0.88, -0.2, math.cos(a) * 0.88), "negro"))
    piezas += [_aguja(0.55, 0.16, math.radians(-60), "negro", -0.28), _aguja(0.8, 0.11, math.radians(60), "negro", -0.3),
               A.cilindro("eje", 0.1, 0.1, (0, -0.33, 0), "dorado", lados=10, rot=FRENTE)]
    return piezas


def icono_manecillas():
    return [
        _aguja(0.85, 0.32, math.radians(-60), "negro", 0.0),
        _aguja(1.3, 0.22, math.radians(60), "negro", -0.05),
        _aguja(1.35, 0.08, math.radians(200), "rojo", -0.1),
        A.cilindro("eje", 0.18, 0.3, (0, -0.15, 0), "dorado", lados=12, rot=FRENTE),
    ]


def icono_cuarzo():
    return [
        A.cilindro("platina", 1.2, 0.3, (0, 0.15, 0), "gris", lados=28, rot=FRENTE),
        A.cilindro("pila", 0.55, 0.3, (0, -0.05, 0.25), "blanco", lados=24, rot=FRENTE),
        A.caja("polo", (0.4, 0.35, 0.08), (0, -0.1, 0.25), "gris_oscuro"),
        A.caja("circuito", (1.2, 0.3, 0.45), (0, 0, -0.65), "verde"),
        A.caja("pista", (0.9, 0.34, 0.06), (0, -0.02, -0.6), "dorado"),
    ]


def icono_mecanico():
    return ([A.cilindro("platina", 1.2, 0.3, (0, 0.15, 0), "gris", lados=28, rot=FRENTE)]
            + _engranaje(0.55, "dorado", 12, (0, 0.1), -0.1)
            + [A.anillo("volante", 0.32, 0.06, (0.55, -0.15, -0.6), "bronce", lados=16, rot=FRENTE),
               A.esfera("rubi", 0.14, (-0.6, -0.2, -0.6), "rojo", 8, 5)])


def icono_automatico():
    contorno = [(math.cos(math.pi * k / 12) * 1.1, math.sin(math.pi * k / 12) * 1.1) for k in range(13)]
    contorno += [(math.cos(math.pi * k / 12) * 0.25, math.sin(math.pi * k / 12) * 0.25) for k in range(12, -1, -1)]
    return ([A.cilindro("platina", 1.2, 0.3, (0, 0.15, 0), "gris", lados=28, rot=FRENTE)]
            + _engranaje(0.4, "bronce", 10, (0.3, -0.5), 0.0)
            + [A.prisma_poligono("rotor", contorno, 0.25, (0, -0.15, -0.05), "dorado"),
               A.cilindro("eje", 0.18, 0.4, (0, -0.2, -0.05), "rojo", lados=10, rot=FRENTE)])


def icono_ok():
    marca = [(-1.15, 0.1), (-0.45, -0.6), (1.15, 1.0), (1.4, 0.75), (-0.45, -1.15), (-1.4, -0.15)]
    return [A.prisma_poligono("ok", marca, 0.4, (0, 0, 0), "verde")]


def icono_aviso():
    triangulo = [(0, 1.45), (1.5, -1.2), (-1.5, -1.2)]
    return [
        A.prisma_poligono("aviso", triangulo, 0.35, (0, 0, 0), "dorado"),
        A.caja("palo", (0.28, 0.4, 0.95), (0, -0.05, 0.2), "negro"),
        A.caja("punto", (0.3, 0.4, 0.28), (0, -0.05, -0.75), "negro"),
    ]


ICONOS = {
    "ico_pz_caja": icono_caja,
    "ico_pz_calibre": icono_calibre,
    "ico_pz_esfera": icono_esfera,
    "ico_pz_manecillas": icono_manecillas,
    "ico_calibre_cuarzo": icono_cuarzo,
    "ico_calibre_mecanico": icono_mecanico,
    "ico_calibre_automatico": icono_automatico,
    "ico_ok": icono_ok,
    "ico_aviso": icono_aviso,
}


def marco_rareza(ruta, tam=128, borde=10, radio=22):
    """Marco blanco de esquinas redondeadas y fondo transparente (9-slice; el código lo colorea)."""
    y, x = np.mgrid[0:tam, 0:tam].astype(np.float32) + 0.5

    def dentro(margen, r):
        lo, hi = margen, tam - margen
        cx = np.clip(x, lo + r, hi - r)
        cy = np.clip(y, lo + r, hi - r)
        d = np.sqrt((x - cx) ** 2 + (y - cy) ** 2)
        return np.clip(r - d + 0.5, 0, 1) * ((x > lo - 1) & (x < hi + 1) & (y > lo - 1) & (y < hi + 1))

    exterior = dentro(2, radio)
    interior = dentro(2 + borde, max(radio - borde, 2))
    alfa = np.clip(exterior - interior, 0, 1)
    brillo = np.clip(exterior - dentro(5, radio - 3), 0, 1) * 0.0  # borde liso
    px = np.ones((tam, tam, 4), dtype=np.float32)
    px[..., 3] = np.clip(alfa + brillo, 0, 1)
    imagen = bpy.data.images.new("marco", tam, tam, alpha=True)
    imagen.pixels = px.ravel().tolist()
    imagen.filepath_raw = ruta
    imagen.file_format = "PNG"
    imagen.save()


if __name__ == "__main__":
    for nombre, constructor in ICONOS.items():
        I.render_icono(nombre, constructor)
    marco_rareza(os.path.join(I.SALIDA, "ui_marco_rareza.png"))
    print("== iconos de la mesa:", len(ICONOS), "+ ui_marco_rareza.png")
