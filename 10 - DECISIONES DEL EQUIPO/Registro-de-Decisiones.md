
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

Todavía no existen decisiones de diseño definitivas registradas en esta reconstrucción.

### Plantilla de decisión

#### DEC-001 — Título de la decisión

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


## 8. Propuestas abiertas

#### DEC-001 — Código del juego en texto con estructura Rojo

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Responsable:** Jhonn. **Área:** Arquitectura.
- **Propuesta:** el código vive en `juego/src` dentro de este repositorio; la place se genera con `juego/build.py` o se sincroniza con Rojo. Studio no es la fuente del código.
- **Motivo:** historial, revisión y fusión con Git; los archivos binarios `.rbxl` no se pueden revisar ni fusionar.
- **Documentos afectados:** [[Arquitectura-General]], [[Changelog]].

#### DEC-002 — Bucle MVP y cifras de balance iniciales

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Responsable:** Jhonn. **Área:** Sistemas, economía y progresión.
- **Propuesta:** cajas de piezas → Taller → Tienda/Museo → mejoras, con las cifras de `juego/src/shared/Config.luau` y `GameData.luau`. Sin robo, mascotas ni compras con Robux en esta versión.
- **Documentos afectados:** [[Economia-y-Progresion]], [[Lista-de-Sistemas]], [[Backlog]].

#### DEC-003 — Tutorial de 5 objetivos con premios

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Responsable:** Jhonn. **Área:** Sistemas / UX.
- **Propuesta:** recoger 5 cajas (20) → fabricar (30) → vender (30) → exhibir (40) → mejorar (50); guía luminosa hacia el destino. Textos en `juego/src/shared/GameData.luau`.
- **Documentos afectados:** [[GDD]], [[UI-UX]], [[Backlog]].

#### DEC-004 — Bucle principal: robo por zonas con persecución

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn; falta que el equipo apruebe las cifras). **Área:** Gameplay / economía.
- **Propuesta:** 5 zonas con puertas de velocidad; botín que se pierde si el dueño te atrapa; reemplaza a las cajas de DEC-002. Detalle en [[GDD]] §15.2.
- **Reemplaza en parte:** DEC-002 (la recolección por cajas).

#### DEC-005 — Jefe cooperativo: Cronómetro Maestro

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Área:** Sistemas / multijugador.
- **Propuesta:** evento cada 7 min; entrega de piezas por puntos de rareza; 12 monedas por punto si se repara; reembolso si falla. Detalle en [[GDD]] §15.3.
