
# 🤖 PROTOCOLO DE TRABAJO DE LOS AGENTES IA

## 1. Propósito

Establecer las reglas de colaboración, coordinación, comunicación y ejecución de tareas entre los dos agentes Claude Code de Roblox Game Studio.

Los agentes deben trabajar como integrantes de un mismo estudio, respetando la arquitectura, documentación y decisiones oficiales.

## 2. Organización de los agentes

### CLAUDE 1 — CUENTA A: GAMEPLAY & SYSTEMS

Administrada por Zadiel y Jhonn. Responsabilidad principal:

- Loop de juego y mecánicas.
- Inventario, objetos y crafting.
- Habilidades, progresión y economía.
- Implementación técnica en Roblox.

### CLAUDE 2 — CUENTA B: WORLD & PRESENTATION

Administrada por Michael y Einell. Responsabilidad principal:

- Mundo, narrativa y personajes.
- Dirección visual y assets.
- Contenido y experiencia de usuario (UX).

Ambas cuentas pueden colaborar fuera de su área cuando la tarea lo requiera. Cada tarea identifica a una persona responsable y a quien la revisa; los cambios transversales requieren revisión de ambas parejas.

## 3. Inicio obligatorio de cada tarea

Antes de comenzar, cada agente debe:

1. Leer [[Instrucciones-Generales]].
2. Consultar [[Dashboard]].
3. Leer los documentos relacionados con su tarea.
4. Consultar [[Registro-de-Decisiones]].
5. Revisar [[Backlog]].
6. Comprobar el estado del repositorio Git.
7. Identificar dependencias y posibles conflictos.

## 4. Asignación de tareas

Cada tarea debe tener:

- Identificador.
- Descripción.
- Responsable principal.
- Área.
- Prioridad.
- Estado.
- Criterios de aceptación.

No deben existir dos responsables principales trabajando simultáneamente sobre el mismo cambio sin coordinación.

## 5. Comunicación entre agentes

Antes de realizar cambios que afecten al trabajo del otro agente:

1. Identificar el sistema afectado.
2. Revisar sus dependencias.
3. Documentar la modificación propuesta.
4. Comunicar el impacto.
5. Coordinar la integración.

Los agentes no deben asumir que el otro conoce cambios que no han sido comunicados.

## 6. Protección de archivos

- No sobrescribir cambios ajenos.
- No eliminar documentos sin autorización.
- No modificar configuraciones compartidas sin necesidad.
- No alterar archivos fuera del alcance de la tarea.
- Revisar cambios existentes antes de editar.
- Detenerse si aparecen modificaciones inesperadas.

## 7. Procedimiento de desarrollo

Cada tarea seguirá este flujo:

1. Leer la documentación.
2. Comprender el objetivo.
3. Identificar dependencias.
4. Planificar la implementación.
5. Realizar los cambios.
6. Ejecutar pruebas.
7. Revisar el resultado.
8. Actualizar la documentación.
9. Informar del trabajo realizado.
10. Preparar la integración en Git.

## 8. Control de versiones

GitHub es el repositorio central.

Antes de trabajar:

- Comprobar la rama actual.
- Revisar el estado de Git.
- Obtener los cambios remotos.
- Confirmar que no existen conflictos.

Durante el trabajo y al finalizar (DEC-009: se trabaja directo en main):

- Reservar las rutas en [[ACTIVE_TASKS]] y subir la reserva a main antes de editar.
- Anotar cada avance en la memoria de Obsidian (Memoria-de-Area.md del área, Backlog y, si aplica, Registro-de-Decisiones).
- Revisar los archivos modificados y comprobar que no se incluyen archivos sensibles.
- Hacer `git pull`, crear un commit descriptivo y subirlo directamente a main.
- Al cerrar, marcar la tarea como Completada en ACTIVE_TASKS.md y subirlo.
- Informar de los commits realizados.

Obsidian Git sincroniza solo cada 5 minutos (commit, subida y bajada), así que los demás ven los cambios sin hacer nada.

Nunca utilizar force push para solucionar conflictos.

## 9. Conflictos entre agentes

Si dos agentes modifican el mismo archivo o sistema:

1. Detener la integración automática.
2. Identificar los cambios de ambos.
3. Determinar qué modificaciones son compatibles.
4. Consultar al responsable humano si existe una decisión contradictoria.
5. Resolver el conflicto sin perder información.
6. Verificar el resultado.

## 10. Límites de autonomía

Los agentes pueden ejecutar tareas técnicas dentro del alcance autorizado.

Deben solicitar aprobación humana para:

- Cambiar decisiones de diseño aprobadas.
- Modificar la arquitectura general.
- Eliminar sistemas importantes.
- Alterar estructuras de datos persistentes.
- Introducir dependencias importantes.
- Modificar permisos o credenciales.
- Realizar cambios de gran impacto en el proyecto.

## 11. Informe obligatorio al finalizar

Cada agente debe informar:

### Resumen de la tarea
Qué se realizó.

### Archivos modificados
Lista de archivos afectados.

### Pruebas
Qué pruebas se ejecutaron y sus resultados.

### Problemas
Errores, limitaciones o tareas pendientes.

### Integración
Estado del commit y publicación en GitHub.

### Siguiente paso
Recomendaciones para continuar.

## 12. Regla fundamental

La prioridad de ambos agentes es trabajar de forma coordinada, mantener la integridad del proyecto y respetar las decisiones del equipo humano.

La velocidad nunca debe estar por encima de la seguridad, la calidad y la conservación del trabajo.

## 13. Documentos relacionados

- [[Dashboard]]
- [[Instrucciones-Generales]]
- [[Equipo-y-Responsabilidades]]
- [[Backlog]]
- [[Registro-de-Decisiones]]
- [[Arquitectura-General]]
- [[Plan-de-Pruebas]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]


## 14. Ramas por tarea, reservas y revisión

- Usa exactamente una rama por tarea: `task/<ID>-<slug>`; las cuentas no mantienen ramas permanentes.
- Antes de editar, revisa `git status`, la rama, `ACTIVE_TASKS.md`, `OWNERS.md` y los Pull Requests abiertos. Comprueba también que no haya cambios locales sin guardar en las rutas asignadas.
- Registra el ID en Backlog.md y reserva las rutas exactas o patrones en ACTIVE_TASKS.md. El Pull Request inicial de reserva solo debe cambiar esos dos registros. Espera que se integre antes de editar las rutas reservadas. INFRA-001 fue la única excepción de arranque: registró e implementó el scaffold en un solo Pull Request porque el registro y el control todavía no existían.
- El hook compartido `.claude/settings.json` bloquea las herramientas Edit/Write de Claude Code en `main`, fuera de una reserva integrada o sobre rutas activas de otra tarea. No uses Bash o editores externos para evadirlo; GitHub Actions es la barrera de integración y también rechaza cambios fuera de la reserva, cambios a filas ajenas, reservas duplicadas y rutas solapadas en Pull Requests abiertos. El hook local no es un bloqueo del sistema de archivos y puede saltarse fuera de las herramientas Edit/Write.
- Usa una aprobación humana distinta del autor. Cuenta A coordina la integración, pero no aprueba su propio cambio. Los controles requeridos son `reservation-check` y `rojo-build`.
- La protección efectiva de main debe activarse en GitHub Settings; el workflow por sí solo no impide un push directo. Exige PR, una aprobación distinta del autor, `reservation-check`, `rojo-build`, rama actualizada y bloquea force push/eliminación de main. Para limitar escritura a las cuatro personas, configura Write solo para sus cuentas exactas y permiso base Read. Para limitar borrado de repositorio, desactiva el borrado/transferencia por miembros en la organización; los propietarios siguen teniendo ese poder.
- Al cerrar una tarea, actualiza Backlog.md y marca su reserva Completada en el Pull Request final. Una reserva En revisión se mantiene hasta que el Pull Request de esa tarea se integre.

---

**Estado:** Borrador inicial
**Agentes:** Claude 1 y Claude 2
**Aprobación:** Pendiente del equipo