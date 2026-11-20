# art/ — fuentes y exportaciones de arte

Traspaso a Zadiel (MacBook): [[PROMPT_ARTE_ZADIEL_MAC|Prompt de arte y materiales]].

Pipeline completo, estilo, formatos y lista de assets: [[Pipeline-de-Arte|Pipeline de Arte]] (`art/Pipeline-de-Arte.md`).

| Carpeta | Contenido |
|---|---|
| `blender/scripts/` | Generadores Python de modelos low-poly (`generar_todo.py`) y vistas previas (`vista_previa.py`) |
| `blender/fuentes/` | Archivos `.blend` |
| `export/modelos/` | `.fbx` para importar en Roblox Studio (unidad: Stud) |
| `export/vistas/` | Imágenes de vista previa |
| `texturas/fuentes/` | `.kra` (Krita) y `.ptex` (Material Maker) |
| `texturas/export/` | `.png` para Roblox (`tex_paleta.png`, iconos) |
| `audio/fuentes/` | Proyectos `.aup3` (Audacity) |
| `audio/export/` | `.ogg` / `.mp3` para Roblox |
| `referencias/` | Imágenes de referencia, con su licencia anotada |

Generar los modelos base (desde la raíz del repositorio):

```
"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/generar_todo.py
"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/vista_previa.py
```
