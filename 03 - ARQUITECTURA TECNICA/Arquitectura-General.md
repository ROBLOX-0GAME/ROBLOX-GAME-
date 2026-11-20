
# 🏗️ ARQUITECTURA TÉCNICA GENERAL

## 1. Propósito

Definir la estructura técnica del proyecto Roblox Game Studio, sus componentes, responsabilidades y criterios de organización.

## 2. Plataforma y tecnología

- **Plataforma:** Roblox
- **Motor:** Roblox Studio
- **Lenguaje principal:** Luau
- **Entorno de desarrollo:** Roblox Studio
- **Control de versiones:** Git y GitHub
- **Documentación:** Obsidian
- **Herramienta de sincronización:** Rojo

### Entorno de trabajo por dispositivo

- Roblox Studio se instalará manualmente en las PC Windows destinadas al desarrollo.
- La MacBook se usará para Obsidian y tareas escolares; no se planifica el desarrollo de Roblox Studio en ella.
- El repositorio GitHub contiene la bóveda de Obsidian y el código fuente inicial en game/; el place de Roblox todavía no existe.
- El flujo acordado es parcialmente gestionado: Git contiene código y configuración, y Roblox Studio conserva el place, el mundo y los assets.
- game/default.project.json deja servePlaceIds vacío para impedir la sincronización en vivo hasta que el equipo cree el place y apruebe su placeId.
- Rojo sirve desde la PC Windows de desarrollo y su plugin local se conecta a ese servidor; GitHub no mantiene una conexión directa con Studio.
- Consulta [[game/README|Proyecto fuente de Roblox con Rojo]] para instalación, build y sincronización.

## 3. Arquitectura general

El scaffold inicial vive en game/ y separa claramente:

- Cliente.
- Servidor.
- Módulos compartidos.
- Servicios del juego.
- Sistemas de datos.
- Interfaces.

La implementación específica de sistemas está pendiente de diseño y aprobación.

## 4. Organización del código

### Cliente
Responsable de las funcionalidades que se ejecutan en el dispositivo del jugador.

### Servidor
Responsable de la lógica autoritativa, validaciones y estado compartido del juego.

### Módulos compartidos
Contendrán componentes y definiciones que necesiten utilizar tanto el cliente como el servidor.

## 5. Sistemas técnicos

- Sistema de jugadores.
- Sistema de combate.
- Sistema de habilidades.
- Sistema de inventario.
- Sistema de economía.
- Sistema de progresión.
- Sistema de guardado.
- Sistema de enemigos.
- Sistema de misiones.
- Sistema multijugador.
- Sistema de interfaz.

## 6. Comunicación cliente-servidor

Definir los mecanismos de comunicación, validaciones y límites de confianza.

Principio fundamental: el servidor debe validar las acciones importantes del jugador.

## 7. Gestión de datos

- Persistencia.
- Guardado.
- Carga.
- Validación.
- Recuperación ante errores.
- Evolución de estructuras de datos.

Tecnología y diseño detallado pendientes de aprobación.

## 8. Rendimiento y optimización

- Control de uso de memoria.
- Optimización de scripts.
- Gestión de eventos.
- Optimización de física.
- Control de carga de recursos.
- Pruebas de rendimiento.

## 9. Seguridad

- Validación en servidor.
- Protección de eventos remotos.
- Control de datos.
- Prevención de exploits.
- Verificación de transacciones.

## 10. Estándares de desarrollo

- Código modular.
- Responsabilidades claras.
- Nombres consistentes.
- Documentación del código.
- Evitar duplicación innecesaria.
- Probar antes de integrar cambios.

## 11. Decisiones técnicas pendientes

Registrar aquí las decisiones que el equipo todavía debe aprobar.

## 12. Documentos relacionados

- [[Dashboard]]
- [[Vision-General]]
- [[GDD]]
- [[Lista-de-Sistemas]]
- [[Backlog]]
- [[Registro-de-Decisiones]]
- [[Plan-de-Pruebas]]
- [[game/README|Proyecto fuente de Roblox con Rojo]]
- [[03 - ARQUITECTURA TECNICA/Memoria-de-Area|Memoria de Arquitectura]]
- [[OWNERS]]
- [[ACTIVE_TASKS]]

---

**Estado:** Borrador inicial  
**Aprobación técnica:** Pendiente
