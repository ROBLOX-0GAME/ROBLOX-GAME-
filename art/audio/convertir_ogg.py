"""
convertir_ogg.py — convierte art/audio/fuentes/*.wav a OGG (Vorbis) con el motor de audio de Blender.

    blender --background --factory-startup --python art/audio/convertir_ogg.py

Roblox acepta OGG y MP3. Salida en art/audio/export/.
"""

import os

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))
FUENTES = os.path.join(AQUI, "fuentes")
EXPORT = os.path.join(AQUI, "export")
os.makedirs(EXPORT, exist_ok=True)

for archivo in sorted(os.listdir(FUENTES)):
    if not archivo.endswith(".wav"):
        continue
    bpy.ops.wm.read_factory_settings(use_empty=True)
    escena = bpy.context.scene
    escena.render.fps = 100  # precisión de 10 ms en la duración
    editor = escena.sequence_editor_create()
    # Blender 4.4+ llama «strips» a lo que antes era «sequences»
    coleccion = editor.strips if hasattr(editor, "strips") else editor.sequences
    pista = coleccion.new_sound("sfx", os.path.join(FUENTES, archivo), channel=1, frame_start=1)
    escena.frame_start = 1
    escena.frame_end = pista.frame_final_end
    salida = os.path.join(EXPORT, os.path.splitext(archivo)[0] + ".ogg")
    bpy.ops.sound.mixdown(filepath=salida, container="OGG", codec="VORBIS", mixrate=44100)
    print("ogg ->", os.path.basename(salida))
