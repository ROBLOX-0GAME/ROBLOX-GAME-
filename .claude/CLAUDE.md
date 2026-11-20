# Instrucciones raíz de Claude Code

Estas reglas se aplican al trabajar desde la raíz de la bóveda y del repositorio de Roblox Game Studio.

## Autoridad y fuentes
- Sigue la solicitud explícita de la persona usuaria y las reglas de seguridad de la plataforma.
- Registro-de-Decisiones.md contiene las decisiones aprobadas. OWNERS.md asigna áreas y ACTIVE_TASKS.md registra reservas de rutas.
- Las notas del proyecto describen el alcance y las decisiones; una propuesta no se presenta como aprobada.
- Claude puede corregir redacción y formato, pero no aprobar decisiones de diseño ni sus propios cambios sustantivos.

## Inicio de tarea y coordinación
1. Lee este archivo, 00 - CENTRO DE CONTROL/Instrucciones-Generales.md, Dashboard.md, Protocolo-de-Trabajo-IA.md, Backlog.md, OWNERS.md y ACTIVE_TASKS.md.
2. Lee solo la nota principal y Memoria-de-Area.md de las áreas necesarias.
3. Confirma el ID, objetivo, Cuenta Claude, responsable humano, revisor, criterios de aceptación y rutas exactas.
4. Antes de editar, inspecciona la rama y el estado de GitHub y revisa ACTIVE_TASKS.md. Cada tarea usa una rama task/<ID>-<slug>.
5. Registra la tarea en Backlog.md y reserva sus rutas en ACTIVE_TASKS.md mediante un Pull Request de reserva. Espera a que la reserva quede integrada en main antes de cambiar esas rutas. El Pull Request de implementación debe incluir el ID y solo modificar rutas reservadas.
6. Si una ruta está reservada por otra tarea, no la edites. Escoge una tarea independiente o consulta a la persona responsable.
7. No borres, muevas ni renombres notas existentes. OWNERS.md y ACTIVE_TASKS.md son los registros compartidos de este flujo.

## Equipo
- Cuenta A — Claude 1, administrada por Jhonn y Zadiel. Lidera gameplay, mecánicas, sistemas, economía, progresión, arquitectura técnica y Git/Obsidian.
- Cuenta B — Claude 2, administrada por Michael y Einell. Lidera mundo, narrativa, personajes, dirección visual, assets, contenido y UX.
- El Backlog identifica a una persona responsable por tarea y a su revisor. Los cambios transversales requieren revisión de ambas parejas.
- Cuenta A coordina la integración a main. El integrador no aprueba su propio Pull Request.
- WhatsApp es el canal diario humano. Claude no contacta a otros agentes por WhatsApp ni prepara mensajes para reenviar.

## GitHub e integración
- Repositorio: https://github.com/ROBLOX-0GAME/ROBLOX-GAME-.git. La rama estable es main.
- Usa una rama por tarea con nombre task/<ID>-<slug>; no se usan ramas permanentes por cuenta.
- Ningún agente hace push directo a main, fuerza pushes ni fusiona su propio Pull Request.
- Todo cambio se integra mediante Pull Request hacia main. Requiere una aprobación humana y que pasen los controles de GitHub Actions.
- El integrador central es Cuenta A. La persona humana autorizada integra después de la revisión.
- La protección efectiva de main requiere una regla del repositorio en GitHub; el archivo de workflow por sí solo no activa esa configuración.
- Antes de sincronizar, revisa rama, cambios y estado remoto. Conserva trabajo no relacionado. No uses force push.

## Roblox Studio y Rojo
- El código fuente de Roblox vive en game/ dentro de este repositorio. Git es la fuente de verdad del código; Roblox Studio conserva mundo, assets y place, según el flujo parcialmente gestionado confirmado por el equipo.
- Roblox Studio se instalará manualmente en las PC Windows de desarrollo. La MacBook se usa para Obsidian y tareas escolares.
- El scaffold está en game/default.project.json y la versión de Rojo se fija en game/rokit.toml.
- Todavía no existe un place ni un placeId. servePlaceIds está vacío para impedir la sincronización en vivo. No conectes Rojo a ningún place hasta que el equipo cree uno y el placeId quede registrado y aprobado.
- Rojo sincroniza una copia local mediante el servidor Rojo y el plugin de Studio; GitHub no se conecta directamente al proceso local de Studio.

## Límites y seguridad
- No guardes contraseñas, tokens, cookies ni claves.
- No publiques el juego ni cambies permisos o credenciales.
- No alteres decisiones de diseño, datos persistentes o publicación sin autorización humana.
- No declares pruebas que no se ejecutaron.
- Si el proyecto no permite verificar un conflicto o falta una decisión aprobada, pausa solo ese cambio y continúa con tareas independientes.

## Informe de cierre
Informa el resumen, rutas cambiadas, responsable y revisor, rama, commit y Pull Request, controles realmente ejecutados, limitaciones pendientes y próximo paso. La persona integradora libera o cierra la reserva cuando corresponda.
