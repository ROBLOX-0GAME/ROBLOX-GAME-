

## ART-014 (2026-11-20, Zadiel; revisor Jhonn)

- **Auditoría visual:**
  - En la salida se superponen 3 rótulos con el modelo del cartel.
  - Hay demasiados `BillboardGui` visibles a la vez (vitrinas, casas, estaciones y puertas).
  - Las rarezas casi no se distinguen al estar puesto el modelo: solo queda la `PointLight`.
  - No hay efectos en fabricar, vender, subir de nivel ni abrir cápsulas.
  - El HUD tiene paneles grandes y 5 botones azules sin icono.
  - Ya están: `UIScale`, mando y táctil, iconos y sonidos con ID (DEV-018) y DEC-022.
- **Propuesta DEC-024 (pendiente de pasar al Registro; DEV-019 lo tenía reservado):** dirección visual «taller de relojería fantástico».
  - Paleta de acentos: madera cálida, carbón `#1E1F26`, marfil `#F2F0EA`, latón `#C27B3A`, oro `#F2C14E` y cian `#5BD5E0`. Son colores de la paleta actual, no hay ninguno nuevo.
  - Carteles por contexto, efectos breves solo en el cliente, brillo por rareza a partir de Raro, HUD compacto con iconos e identidad propia por zona.
  - Se conservan DEC-016, DEC-018 y DEC-022.
  - Detalle en [[UI-UX]] §12.
- **Pendiente:** ART-015 (aplicar [[UI-UX]] §12 en `game/src` y subir a Studio los modelos e iconos de ART-014).

- 2026-11-20 · ART-015 (Zadiel): [[UI-UX]] §12 aplicado en `game/src` (`0b92ac5`) como propuesta DEC-024, con `Client/Vfx.luau` nuevo. Pasa `build.py` y `rojo build`. Falta cargarlo completo en la place, probarlo en Play y guardar.
- 2026-11-20 · ART-015 cerrada: cargado en la place y probado en Play (Plan de Pruebas §26). Place guardada en la versión 21, sin publicar. DEC-024 pendiente de aprobación.
