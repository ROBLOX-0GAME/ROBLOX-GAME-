
# 🧠 REGISTRO DE DECISIONES DEL EQUIPO

## 1. Propósito

Este documento registra las decisiones oficiales de Roblox Game Studio.

Su objetivo es evitar contradicciones, conservar el contexto del proyecto y permitir que los integrantes humanos y los agentes IA trabajen siguiendo los mismos criterios.

## 2. Estados de las decisiones

- **Propuesta:** pendiente de evaluación.
- **Aprobada:** aceptada oficialmente por el equipo.
- **Rechazada:** descartada.
- **Reemplazada:** sustituida por una decisión posterior.

## 3. Autoridad de decisión

- Las decisiones estratégicas corresponden al equipo humano.
- Los agentes IA pueden investigar, proponer y recomendar soluciones.
- Ningún agente puede presentar una propuesta como decisión aprobada.
- Las decisiones técnicas importantes deben documentarse.
- Los cambios que afecten varias áreas deben revisarse con los responsables correspondientes.

## 4. Registro de decisiones

### DEC-001 — Código en Git y flujo parcialmente gestionado con Rojo

- **Fecha:** 2026-11-19.
- **Estado:** Aprobada por la persona usuaria responsable del proyecto.
- **Responsable:** Equipo Roblox Game Studio.
- **Área:** Arquitectura técnica.

**Contexto:**

El repositorio existente contiene la bóveda de Obsidian, pero no tenía un proyecto de código Roblox.

**Decisión:**

Crear el código fuente dentro de game/ en este mismo repositorio. Usar Rojo con flujo parcialmente gestionado: Git conserva el código y Roblox Studio conserva el place, el mundo y los assets. Fijar la versión de Rojo y dejar la sincronización en vivo bloqueada hasta crear el place y aprobar su placeId.

**Justificación:**

La documentación del proyecto recomienda mantener el código versionado y revisar cambios en GitHub, mientras Studio conserva recursos que no se gestionan como archivos de texto.

**Consecuencias:**

La MacBook sigue dedicada a Obsidian; Rojo y Roblox Studio se instalarán en las PC Windows de desarrollo. El scaffold y los enlaces quedan en game/ y en el Dashboard. La conexión en vivo no se activa sin placeId.

**Documentos afectados:**

- [[Arquitectura-General]]
- [[Dashboard]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[game/README|Proyecto fuente de Roblox con Rojo]]

### DEC-002 — Ramas por tarea y revisión obligatoria

- **Fecha:** 2026-11-19.
- **Estado:** Aprobada para implementar por la persona usuaria responsable del proyecto.
- **Responsable:** Cuenta A (Jhonn/Zadiel).
- **Área:** GitHub y coordinación de agentes.

**Decisión:**

Cada tarea usa una rama task/<ID>-<slug>. main recibe cambios solo por Pull Request, con al menos una aprobación humana y los controles automatizados aprobados. Cuenta A coordina la integración; nadie aprueba su propio Pull Request.

**Consecuencias:**

ACTIVE_TASKS.md registra las rutas reservadas; el control de GitHub Actions bloquea Pull Requests que invadan rutas de otra tarea. La configuración de protección de main debe activarse en GitHub Settings y no se modifica desde un archivo del repositorio.

**Documentos afectados:**

- [[Protocolo-de-Trabajo-IA]]
- [[Backlog]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]

### Plantilla de decisión

#### Plantilla — Título de la decisión

- **Fecha:** Pendiente.
- **Estado:** Propuesta.
- **Responsable:** Pendiente.
- **Área:** Pendiente.

**Contexto:**

¿Qué situación requiere una decisión?

**Opciones consideradas:**

1. Opción A.
2. Opción B.
3. Opción C.

**Decisión:**

Pendiente de aprobación.

**Justificación:**

Pendiente.

**Consecuencias:**

Pendiente.

**Documentos afectados:**

Pendiente.

---

## 5. Reglas de modificación

1. No modificar decisiones aprobadas sin registrar una revisión.
2. No eliminar decisiones antiguas.
3. Registrar el motivo de cada cambio.
4. Identificar qué documentos resultan afectados.
5. Mantener un historial comprensible.
6. Comunicar las decisiones que afecten a otras áreas.

## 6. Relación con los agentes IA

Los agentes deben:

- Consultar este documento antes de realizar cambios importantes.
- Respetar las decisiones aprobadas.
- Informar cuando una tarea contradiga una decisión existente.
- Proponer modificaciones cuando detecten problemas.
- Esperar aprobación humana cuando corresponda.

## 7. Documentos relacionados

- [[Dashboard]]
- [[Vision-General]]
- [[GDD]]
- [[Arquitectura-General]]
- [[Lista-de-Sistemas]]
- [[Backlog]]
- [[Equipo-y-Responsabilidades]]
- [[Instrucciones-Generales]]
- [[Protocolo-de-Trabajo-IA]]

---

**Estado:** Activo  
**Responsable:** Equipo Roblox Game Studio

