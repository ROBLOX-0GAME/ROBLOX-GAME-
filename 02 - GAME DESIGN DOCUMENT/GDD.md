
# 🎮 GAME DESIGN DOCUMENT (GDD)

## 1. Información general

- **Nombre del juego:** Pendiente de definir
- **Género:** Pendiente de definir
- **Plataforma:** Roblox
- **Estado:** Diseño conceptual
- **Documento principal:** GDD

## 2. Concepto del juego

### Descripción
Pendiente de definir.

### Propuesta de valor
¿Qué hará especial a nuestro juego?

Pendiente de definir.

### Público objetivo
Pendiente de definir.

## 3. Gameplay principal

### Bucle principal (Core Loop)

1. Pendiente de definir.
2. Pendiente de definir.
3. Pendiente de definir.
4. Pendiente de definir.

### Actividades principales
- Exploración.
- Combate.
- Progresión.
- Recolección.
- Interacción con el mundo.

Estas actividades son categorías iniciales, no mecánicas aprobadas.

## 4. Sistemas de juego

- Movimiento y controles.
- Combate y habilidades.
- Inventario y equipamiento.
- Enemigos y jefes.
- Misiones y eventos.
- Economía.
- Progresión.
- Guardado de datos.
- Multijugador.

Cada sistema tendrá su documentación específica.

## 5. Mundo y ambientación

- Temática: Pendiente.
- Ambientación: Pendiente.
- Regiones: Pendiente.
- Zonas: Pendiente.
- NPC: Pendiente.
- Historia y narrativa: Pendiente.

## 6. Personajes y entidades

- Personaje del jugador.
- NPC.
- Enemigos.
- Jefes.
- Aliados.

Detalles pendientes de definir.

## 7. Progresión del jugador

- Niveles.
- Experiencia.
- Estadísticas.
- Desbloqueos.
- Recompensas.
- Equipamiento.

Pendiente de diseñar.

## 8. Economía del juego

- Monedas.
- Recursos.
- Recompensas.
- Tiendas.
- Precios.
- Compras.

Pendiente de diseñar.

## 9. Multijugador

- Número de jugadores por servidor: Pendiente.
- Cooperación: Pendiente.
- Grupos: Pendiente.
- Interacciones entre jugadores: Pendiente.
- Sistemas competitivos: Pendiente.

## 10. Interfaz y experiencia de usuario

- HUD.
- Menús.
- Inventario.
- Mapas.
- Indicadores.
- Tutorial.

Pendiente de diseñar.

## 11. Monetización

Pendiente de definir.

Toda monetización deberá respetar las políticas de Roblox y mantener una experiencia justa para los jugadores.

## 12. Alcance del proyecto

### Primera versión (MVP)
Pendiente de definir.

### Futuras actualizaciones
Pendiente de definir.

## 13. Criterios de calidad

- Gameplay comprensible.
- Progresión equilibrada.
- Rendimiento adecuado.
- Interfaz clara.
- Sistemas coherentes.
- Experiencia multijugador estable.

## 14. Documentos relacionados

- [[Dashboard]]
- [[Vision-General]]
- [[Arquitectura-General]]
- [[Lista-de-Sistemas]]
- [[Diseño-del-Mundo]]
- [[UI-UX]]
- [[Economia-y-Progresion]]
- [[Multiplayer]]
- [[Backlog]]

---

**Estado:** Borrador inicial  
**Aprobación:** Pendiente del equipo


## 15. Propuesta de diseño: robo por zonas (DEV-003 a DEV-005)

> Dirección definida por Jhonn el 2026-11-20. Las cifras son **propuesta** y están en `juego/src/shared/Config.luau` y `GameData.luau`. Decisiones: DEC-004, DEC-005 y DEC-006 en [[Registro-de-Decisiones]].

### 15.1 Bucle principal

1. Sales de la **base segura**, donde están el Taller, la Tienda, el Museo y, más adelante, el Cronómetro Maestro y el Criadero.
2. Corres por el camino hacia **zonas cada vez más ricas**. Cada zona tiene 4 casas con 3 piezas cada una, de distintas rarezas.
3. Entras a una casa y **robas** piezas manteniendo el botón; las piezas raras tardan más. Lo robado es **botín**: lo llevas encima, pero todavía no es tuyo.
4. Al **salir de la casa**, el dueño sale tras de ti. Si llegas a la base, el botín se guarda. Si te atrapa, si caes o si sales del juego, lo pierdes.
5. Con las piezas fabricas relojes y los vendes o los exhibes. Con el dinero compras **velocidad**, más adelante también **mascotas**, para abrir zonas más ricas.

### 15.2 Zonas (DEV-003)

| # | Zona | Velocidad mínima | Velocidad del dueño | Qué se encuentra |
|---|---|---|---|---|
| 1 | Barrio Humilde | — | 14 | Casi solo piezas comunes |
| 2 | Barrio Obrero | 18 | 17 | Cristales y correas; rubí muy raro |
| 3 | Zona Residencial | 22 | 21 | Muchas poco comunes; algún diamante |
| 4 | Mansiones | 28 | 26 | Rubíes frecuentes; diamantes |
| 5 | Colina de los Millonarios | 34 | 32 | Sobre todo rubíes y diamantes |

- **Puertas de velocidad:** son una barrera roja que se vuelve verde y atravesable solo para quien tiene la velocidad. Si no llegas al mínimo, te quedas en tu zona y tienes que robar ahí.
- El dueño siempre es un poco más lento que la velocidad mínima de su zona. Quien apenas cumple el mínimo puede escapar, pero solo si no se deja alcanzar al salir.
- El dueño se rinde si llegas a la base, si te alejas más de 140 studs o después de 25 segundos. Persigue a un ladrón a la vez; los demás esperan en cola.
- Nueva pieza **Diamante** (legendaria) y nuevo **Reloj del millonario** (nivel 8, se vende por 5000).
- La mejora **Velocidad** sube a 10 niveles, para llegar a 36. La **Suerte** ahora da probabilidad de robar 2 piezas en vez de 1.
- **Seguridad:** el servidor rechaza robos en zonas sin la velocidad necesaria, aunque alguien cruce la puerta con trampas. El botín se descarta al cargar los datos.
