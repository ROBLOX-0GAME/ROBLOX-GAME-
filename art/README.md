# art/ — fuentes y exportaciones de arte

Traspaso a Zadiel (MacBook): [[PROMPT_ARTE_ZADIEL_MAC|Prompt de arte y materiales]].

Traspaso a la PC Windows con Studio (ART-007): [[PROMPT_ARTE_WINDOWS_STUDIO|Prompt para importar los relojes PBR y seguir el arte]].

Pipeline completo, estilo, formatos y lista de assets: [[Pipeline-de-Arte|Pipeline de Arte]] (`art/Pipeline-de-Arte.md`).

| Carpeta | Contenido |
|---|---|
| `blender/scripts/` | Generadores Python de modelos low-poly (`generar_todo.py`), relojes PBR (`materiales_pbr.py`, `relojes_detallados.py`) y vistas previas (`vista_previa.py`) |
| `blender/fuentes/` | Archivos `.blend` |
| `export/modelos/` | `.fbx` para importar en Roblox Studio (unidad: Stud) |
| `export/vistas/` | Imágenes de vista previa |
| `texturas/fuentes/` | `.kra` (Krita) y `.ptex` (Material Maker) |
| `texturas/export/` | `.png` para Roblox (`tex_paleta.png`, iconos, mapas PBR `tex_<material>_*.png`) |
| `audio/fuentes/` | Proyectos `.aup3` (Audacity) |
| `audio/export/` | `.ogg` / `.mp3` para Roblox |
| `referencias/` | Imágenes de referencia, con su licencia anotada |

Generar los modelos base y las vistas (desde la raíz del repositorio):

```
# Windows
"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/generar_todo.py
"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/vista_previa.py
# macOS
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/generar_todo.py
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/vista_previa.py
```

Relojes con materiales PBR (ART-006): primero `materiales_pbr.py` (Material Maker → `texturas/export/tex_<material>_*.png`) y después `relojes_detallados.py`, con el mismo comando. Detalle y montaje de `SurfaceAppearance` en Studio: [[Pipeline-de-Arte#Materiales PBR de los relojes (ART-006, propuesta)|Pipeline de Arte]].
