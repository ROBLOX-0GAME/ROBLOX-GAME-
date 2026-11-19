
# 🤖 PROTOCOLO DE TRABAJO DE LOS AGENTES IA

## 1. Propósito

Establecer las reglas de colaboración, coordinación, comunicación y ejecución de tareas entre los dos agentes Claude Code de Roblox Game Studio.

Los agentes deben trabajar como integrantes de un mismo estudio, respetando la arquitectura, documentación y decisiones oficiales.

## 2. Organización de los agentes

### CLAUDE 1 — GAMEPLAY & WORLD

Responsabilidad principal:

- Movimiento.
- Combate.
- Habilidades.
- Enemigos.
- Jefes.
- Mundo.
- Regiones y zonas.
- NPC.
- Misiones.
- Eventos.
- Exploración.
- Contenido jugable.

### CLAUDE 2 — SYSTEMS & INFRASTRUCTURE

Responsabilidad principal:

- Inventario.
- Economía.
- Progresión.
- Guardado de datos.
- Arquitectura.
- Rendimiento.
- Seguridad.
- Infraestructura técnica.

Ambos agentes pueden colaborar en otras áreas cuando exista una necesidad justificada y coordinación.

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

Al finalizar:

- Revisar los archivos modificados.
- Comprobar que no se incluyen archivos sensibles.
- Crear un commit descriptivo.
- Publicar los cambios cuando esté autorizado.
- Informar del commit realizado.

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

---

**Estado:** Borrador inicial
**Agentes:** Claude 1 y Claude 2
**Aprobación:** Pendiente del equipo
