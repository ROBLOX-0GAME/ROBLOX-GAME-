---
paths:
  - "03 - ARQUITECTURA TECNICA/Arquitectura-General.md"
  - "03 - ARQUITECTURA TECNICA/Memoria-de-Area.md"
  - "game/**"
---

# 03 - ARQUITECTURA TÉCNICA

Función: Roblox Studio, Luau, cliente/servidor, datos y rendimiento.

Nota canónica: 03 - ARQUITECTURA TECNICA/Arquitectura-General.md; memoria: 03 - ARQUITECTURA TECNICA/Memoria-de-Area.md.

Responsable operativo: Lidera Cuenta A (Jhonn/Zadiel); Cuenta B revisa impacto visible para el jugador.

## Entorno aprobado
- El código fuente se mantiene en game/ dentro del repositorio de la bóveda.
- El flujo elegido es parcialmente gestionado: Git contiene código y configuración; el place, el mundo y los assets permanecen en Roblox Studio.
- Roblox Studio se usa en las PC Windows destinadas al desarrollo.
- El scaffold inicial de Rojo está en game/default.project.json; su versión está fijada en game/rokit.toml.
- No existe un place ni un placeId. La lista servePlaceIds vacía bloquea la sincronización en vivo hasta que se registre un destino aprobado.
- No publiques ni sincronices a un place cuando el ID no esté aprobado.

## Mantenimiento
- Consulta Registro-de-Decisiones.md antes de editar contenido sustantivo.
- Sigue ACTIVE_TASKS.md y OWNERS.md; no edites rutas reservadas por otra tarea.
- Guarda memoria breve en Memoria-de-Area.md: aprobado, propuesta, pendiente, fecha, fuente, responsable y enlaces.
- Conserva nombres y enlaces de Obsidian; no borres ni cambies trabajo ajeno.
- Cuenta A cubre gameplay, sistemas y técnica; Cuenta B cubre mundo, narrativa, arte y UX. Cambios transversales requieren revisión de ambas parejas.
