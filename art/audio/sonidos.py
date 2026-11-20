"""
sonidos.py — sintetiza los efectos de sonido base del juego (ART-004).

    python art/audio/sonidos.py

Solo usa la biblioteca estándar de Python. Escribe art/audio/fuentes/sfx_*.wav
(44,1 kHz, 16 bits, mono). Después, art/audio/convertir_ogg.py (con Blender) los
convierte a OGG en art/audio/export/. Son bases para pulir en Audacity.
"""

import math
import os
import random
import struct
import wave

TASA = 44100
CARPETA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fuentes")
random.seed(7)  # resultado reproducible


def tono(freq, dur, forma="seno", vol=0.6, ataque=0.005, caida=0.05, freq_fin=None):
    """Muestras de un tono con envolvente; freq_fin hace un barrido."""
    n = int(TASA * dur)
    fase = 0.0
    muestras = []
    for i in range(n):
        t = i / n
        f = freq if freq_fin is None else freq + (freq_fin - freq) * t
        fase += 2 * math.pi * f / TASA
        if forma == "seno":
            v = math.sin(fase)
        elif forma == "cuadrada":
            v = 0.6 if math.sin(fase) >= 0 else -0.6
        elif forma == "sierra":
            v = 0.8 * (((fase / (2 * math.pi)) % 1) * 2 - 1)
        else:  # triangular
            x = (fase / (2 * math.pi)) % 1
            v = 4 * x - 1 if x < 0.5 else 3 - 4 * x
        segundo = i / TASA
        env = min(1.0, segundo / ataque) if ataque > 0 else 1.0
        restante = dur - segundo
        if restante < caida:
            env *= max(0.0, restante / caida)
        muestras.append(v * vol * env)
    return muestras


def ruido(dur, vol=0.4, caida=0.05):
    n = int(TASA * dur)
    return [random.uniform(-1, 1) * vol * min(1.0, (dur - i / TASA) / caida) for i in range(n)]


def silencio(dur):
    return [0.0] * int(TASA * dur)


def mezclar(*pistas):
    largo = max(len(p) for p in pistas)
    return [sum(p[i] for p in pistas if i < len(p)) for i in range(largo)]


def seguir(*partes):
    salida = []
    for parte in partes:
        salida += parte
    return salida


def guardar(nombre, muestras):
    pico = max(1e-9, max(abs(m) for m in muestras))
    escala = 0.89 / pico  # normaliza a ~ -1 dBFS
    os.makedirs(CARPETA, exist_ok=True)
    with wave.open(os.path.join(CARPETA, nombre + ".wav"), "wb") as archivo:
        archivo.setnchannels(1)
        archivo.setsampwidth(2)
        archivo.setframerate(TASA)
        archivo.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, m * escala)) * 32767)) for m in muestras))
    print(f"{nombre}: {len(muestras) / TASA:.2f} s")


NOTAS = {"C5": 523.25, "E5": 659.25, "G5": 783.99, "C6": 1046.5, "E6": 1318.5, "G6": 1568.0, "C7": 2093.0}

EFECTOS = {
    # Robar una pieza: barrido rápido hacia arriba
    "sfx_robar": lambda: mezclar(tono(500, 0.16, "cuadrada", 0.4, freq_fin=1150), seguir(silencio(0.12), tono(1500, 0.05, "seno", 0.3))),
    # El dueño te ve: sirena de dos tonos
    "sfx_alarma_dueno": lambda: seguir(*[tono(880 if i % 2 == 0 else 660, 0.18, "cuadrada", 0.45, caida=0.02) for i in range(6)]),
    # Te atrapan: caída grave con ruido
    "sfx_atrapado": lambda: mezclar(tono(420, 0.55, "sierra", 0.5, freq_fin=110), ruido(0.25, 0.25, 0.2)),
    # Botín guardado: arpegio de monedas
    "sfx_guardar_botin": lambda: seguir(*[tono(NOTAS[n], 0.08, "triangular", 0.5, caida=0.06) for n in ("C6", "E6", "G6", "C7")], silencio(0.05)),
    # Comprar: clic + campanas
    "sfx_comprar": lambda: mezclar(ruido(0.03, 0.4, 0.02), seguir(silencio(0.02), mezclar(tono(1318.5, 0.35, "seno", 0.4, caida=0.3), tono(1760, 0.35, "seno", 0.3, caida=0.3)))),
    # Abrir cápsula: pop grave + destellos
    "sfx_abrir_capsula": lambda: seguir(mezclar(ruido(0.05, 0.5, 0.04), tono(220, 0.12, "seno", 0.6, freq_fin=80)),
                                        *[tono(NOTAS[n], 0.06, "seno", 0.35, caida=0.05) for n in ("E6", "G6", "C7", "G6", "C7")]),
    # Ruleta girando: tics que se frenan (ART-010: 14 tics, ≈ 1,64 s, por debajo del límite de 2 s)
    "sfx_ruleta": lambda: seguir(*[seguir(tono(1800, 0.012, "cuadrada", 0.4, caida=0.008), silencio(0.04 + i * 0.010)) for i in range(14)]),
    # Subir de nivel: fanfarria
    "sfx_subir_nivel": lambda: seguir(*[tono(NOTAS[n], 0.11, "cuadrada", 0.35, caida=0.04) for n in ("C5", "E5", "G5")],
                                      mezclar(tono(NOTAS["C6"], 0.45, "triangular", 0.4, caida=0.35), tono(NOTAS["G5"], 0.45, "triangular", 0.3, caida=0.35))),
    # Entrenando: pasos suaves en bucle (1 s exacto para repetirse sin cortes)
    "sfx_entrenar": lambda: seguir(*[seguir(tono(180, 0.08, "seno", 0.5, caida=0.06), silencio(0.17)) for _ in range(4)]),
    # Pulsar un botón: clic corto
    "sfx_boton": lambda: tono(1000, 0.035, "seno", 0.5, caida=0.025),
}

if __name__ == "__main__":
    for nombre, generar in EFECTOS.items():
        guardar(nombre, generar())
