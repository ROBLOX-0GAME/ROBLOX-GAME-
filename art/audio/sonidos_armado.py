"""
sonidos_armado.py — ART-018: sonidos de la mesa de armado ([[PROMPT_PIEZAS_RELOJ_ZADIEL]] §7.2).

Sintetizados con las mismas funciones y el mismo pulido que sonidos.py (sin recursos externos):
  sfx_encajar              clic metálico al colocar una pieza (< 0,3 s)
  sfx_armar_<rareza>       12 sonidos, de 1 a 3 s, que suben de intensidad con la rareza:
                           más notas, más agudo, brillo desde Raro y golpe grave desde Mítico
  sfx_reloj_perfecto       remate de «¡Reloj perfecto!»

    python3 art/audio/sonidos_armado.py
    /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/audio/convertir_ogg.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sonidos import guardar, mezclar, ruido, seguir, silencio, tono  # noqa: E402

RAREZAS = ["comun", "poco_comun", "raro", "epico", "legendario", "mitico",
           "divino", "celestial", "cosmico", "eterno", "ancestral", "atemporal"]
# Escala mayor (do mayor) en varias octavas para los arpegios
ESCALA = [523.25, 587.33, 659.25, 698.46, 783.99, 880.0, 987.77,
          1046.5, 1174.66, 1318.51, 1396.91, 1567.98, 1760.0, 1975.53, 2093.0]


def encajar():
    return mezclar(ruido(0.025, 0.35, 0.02), tono(2200, 0.06, "seno", 0.45, caida=0.05),
                   seguir(silencio(0.02), tono(3300, 0.05, "seno", 0.2, caida=0.04)))


def armar(k):
    """k = 1 (Común) … 12 (Atemporal)."""
    notas = 3 + k  # arpegio más largo cuanto más rara
    paso = 0.05 + 0.012 * min(k, 6)
    forma = "triangular" if k < 5 else "seno"
    arpegio = seguir(*[tono(ESCALA[min(i + k // 3, len(ESCALA) - 1)], paso + 0.02, forma, 0.38, caida=paso)
                       for i in range(notas)])
    largo = 1.0 + 2.0 * (k - 1) / 11  # 1 s (Común) → 3 s (Atemporal)
    final = ESCALA[min(7 + k // 2, len(ESCALA) - 1)]
    acorde = mezclar(tono(final, largo * 0.55, "seno", 0.32, caida=largo * 0.5),
                     tono(final * 1.25, largo * 0.55, "seno", 0.22, caida=largo * 0.5),
                     tono(final * 1.5, largo * 0.55, "seno", 0.18, caida=largo * 0.5))
    capas = [seguir(arpegio, acorde)]
    if k >= 3:  # brillo agudo (Raro en adelante)
        capas.append(seguir(silencio(0.1), *[tono(3000 + 300 * (i % 4), 0.04, "seno", 0.08 + 0.01 * k, caida=0.035)
                                             for i in range(4 + k)]))
    if k >= 6:  # golpe grave (Mítico en adelante): «el tiempo se detiene»
        capas.append(tono(110, 0.5 + 0.08 * k, "seno", 0.5, ataque=0.01, caida=0.4, freq_fin=55))
    if k == 12:  # Atemporal: barrido arcoíris ascendente
        capas.append(seguir(silencio(0.2), tono(400, 1.2, "seno", 0.18, caida=0.5, freq_fin=2400)))
    return mezclar(*capas)


def perfecto():
    fanfarria = seguir(*[tono(f, 0.1, "cuadrada", 0.3, caida=0.04) for f in (783.99, 1046.5, 1318.51)])
    acorde = mezclar(tono(1567.98, 0.6, "triangular", 0.35, caida=0.5), tono(1046.5, 0.6, "triangular", 0.3, caida=0.5),
                     tono(1318.51, 0.6, "triangular", 0.25, caida=0.5))
    campanas = seguir(silencio(0.3), *[tono(2637 + 200 * (i % 3), 0.05, "seno", 0.15, caida=0.045) for i in range(8)])
    return mezclar(seguir(fanfarria, acorde), campanas)


if __name__ == "__main__":
    guardar("sfx_encajar", encajar())
    for k, nombre in enumerate(RAREZAS, 1):
        guardar(f"sfx_armar_{nombre}", armar(k))
    guardar("sfx_reloj_perfecto", perfecto())
