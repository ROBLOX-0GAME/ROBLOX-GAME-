
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

> Dirección definida por Jhonn el 2026-11-20. Las cifras son **propuesta** y están en `game/src/ReplicatedStorage/Shared/Config.luau` y `GameData.luau`. Decisiones propuestas: DEC-005 a DEC-008 en [[Registro-de-Decisiones]].

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

### 15.3 Jefe cooperativo: el Cronómetro Maestro (DEV-004)

- Está en la base. Funciona hasta que **se avería**: primero a los 90 s de abrir el servidor y luego cada 7 min.
- Mientras está averiado (2 min 30 s), **todos los jugadores del servidor** le entregan piezas guardadas. Cada rareza vale distintos puntos: común 1, poco común 3, rara 8 y legendaria 20.
- **Meta:** 25 puntos por jugador conectado (mínimo 30).
  - Si la alcanzan, cada participante gana **12 monedas por punto** aportado.
  - Si se acaba el tiempo, se devuelven las piezas a quien siga conectado.
- Sin combate. Le da otro uso a las piezas y empuja a cooperar en un juego de robo.
- El aviso llega a todo el servidor. El menú muestra el tiempo, el progreso y el aporte de cada jugador; la esfera echa humo mientras está averiado.
- **Futuro (no implementado):** fases de diagnóstico y calibración en equipo, y premio de huevo de mascota (pendiente de DEV-005).

### 15.4 Mascotas: multiplicador de velocidad (DEV-005)

- Se compran como **huevos** en el **Criadero** de la base. Al abrir un huevo sale una mascota al azar, que se equipa sola si hay espacio.
- Se pueden equipar **hasta 3**. **Velocidad = (16 + mejoras de Velocidad) × (1 + suma de los bonus de las mascotas equipadas)**, con un tope de 60.

| Mascota | Rareza | Bonus |
|---|---|---|
| Ratón de Cuerda | Común | +5% |
| Gato Engranaje | Poco común | +10% |
| Zorro Relojero | Raro | +20% |
| Halcón de Cuarzo | Épico | +35% |
| Dragón del Tiempo | Legendario | +60% |

| Huevo | Precio | Probabilidades |
|---|---|---|
| Latón | 500 | Ratón 60% · Gato 30% · Zorro 10% |
| Plata | 5.000 | Gato 50% · Zorro 35% · Halcón 15% |
| Oro | 40.000 | Zorro 50% · Halcón 35% · Dragón 15% |

- **Relación con las zonas:** un Zorro solo (16 × 1,2 = 19,2) ya abre el Barrio Obrero (18). Con 3 Dragones y Velocidad al máximo se llega al tope de 60. Mascotas y mejoras de Velocidad son dos caminos que se suman.
- Gestión desde la Mochila, en cualquier lugar: Equipar, Quitar, Liberar y «Equipar mejores». Máximo 50 mascotas.
- **Cronómetro Maestro:** quien aporte 20 puntos o más a una reparación exitosa gana además un Huevo de Latón.
- Solo se compran con monedas del juego. Las compras con Robux siguen sin implementarse hasta que el equipo las apruebe.

### 15.5 Velocidad como eje del juego y Robux (DEV-006)

> Jhonn (2026-11-20): el juego se centra en la **velocidad**; **no hay fuerza**. Los pases pueden dar ventajas fuertes («pay to win»).

**Fórmula de velocidad**

Velocidad = (16 + 2 × nivel de la mejora Velocidad + velocidad entrenada) × multiplicador de mascotas × 1,25 si tienes el pase Corredor VIP. Tiene un tope de 80.

**Caminadoras de entrenamiento** (en la base, a la izquierda)

- Pulsas para entrenar y vuelves a pulsar para parar. Mientras entrenas no te mueves.
- Cada segundo ganas 0,01 de velocidad × el multiplicador de la caminadora, hasta **+30**.

| Caminadora | Multiplicador | Cómo se consigue |
|---|---|---|
| Básica | ×1 | Gratis |
| De Acero | ×2,5 | 2.500 monedas |
| Turbo | ×6 | Pase de Robux |

**Pases (Robux, permanentes)**

| Pase | Efecto |
|---|---|
| Mascota Suprema | Mascota exclusiva un **20% mejor que tu mejor mascota**; mejora sola cuando consigues mejores |
| Caminadora Turbo | Entrenamiento ×6 |
| Corredor VIP | +25% de velocidad |
| VIP | +20% de monedas al vender y en el museo |
| Mochila Gigante | +20 espacios |
| Ranura de Mascota | +1 mascota equipada |

**Productos (Robux, repetibles):** Bolsa, Cofre y Bóveda de monedas (2.500 / 15.000 / 75.000), Entrenamiento instantáneo (+5 de velocidad entrenada) y Huevo de Oro instantáneo, con las probabilidades visibles como exige Roblox.

**Reglas técnicas**

- Los pases se consultan a Roblox cada vez que entras; no se guardan como datos propios.
- Cada producto se entrega una sola vez por compra: se guarda el id de la compra y solo se confirma a Roblox después de guardar.
- Los IDs se copian del Creator Hub en `Config.GAMEPASS_IDS` y `Config.PRODUCT_IDS`. Mientras valgan 0, la tienda muestra «Próximamente».
- Para probar en Studio: `Config.STUDIO_GRANT_ALL_PASSES = true` activa todos los pases solo durante esa sesión.

### 15.6 Plot personal (DEV-008)

> Dirección de Jhonn (2026-11-20). Cifras en propuesta (DEC-010).

- **Un plot por jugador** (10 en la base, 5 a cada lado). Se asigna al entrar y se libera al salir. El cartel muestra el nombre del dueño y al reaparecer apareces delante de tu plot.
- **Taller al fondo del plot:** ahí se fabrican los relojes. Sustituye al Taller compartido.
- **Vitrinas del plot:** funcionan como el antiguo Museo. Cada reloj exhibido da **ingreso pasivo** cada 10 s y un **pequeño bonus de suerte**, que es probabilidad de robar 2 piezas.

| Reloj | Suerte que da exhibido |
|---|---|
| Bolsillo | +0,5% |
| Pulsera | +1% |
| Cronógrafo | +2% |
| Real de rubí | +3% |
| Millonario | +5% |

  La suerte del plot tiene un tope de 15%, y la suerte total (mejora + plot) de 60%.
- **Caminadora enfrente del plot:** entrena velocidad. Su multiplicador es 1 + 0,5 por nivel (de ×1 a ×6), y el pase Caminadora Turbo lo multiplica ×2.
- **Mejoras del plot** (se compran en el panel del propio plot):

| Mejora | Efecto | Niveles | Precio inicial |
|---|---|---|---|
| Vitrinas del plot | +2 vitrinas (de 3 a 15) | 6 | 300 (×2 por nivel) |
| Caminadora del plot | +0,5 al multiplicador | 10 | 400 (×1,75 por nivel) |

- **Solo el dueño** usa el taller, las vitrinas y la caminadora de su plot; lo valida el servidor.
- La Tienda sigue vendiendo Mochila, Velocidad, Salto y Suerte. El Criadero y el Cronómetro Maestro siguen compartidos.
- **Pendiente para la fase de arte:** los modelos del plot y las skins de los dueños de las casas. Se recomiendan personajes originales «al estilo» de famosos de Roblox, como un «Gamer Robot» propio, y no copiar creadores o personajes reales sin permiso.

### 15.7 Mascotas en cápsulas, recompensas y Robux (DEV-009)

> Dirección de Jhonn (2026-11-20). Cifras en propuesta (DEC-011). Sustituye a los «huevos» de §15.4.

**Cómo se consiguen las mascotas:** siempre salen de **cápsulas**. Las cápsulas ganadas o compradas con Robux se guardan en la **Mochila** y se abren cuando quieras.

| Cápsula | Cómo se consigue | Mascotas |
|---|---|---|
| Latón | 500 monedas · recompensas | Ratón 60% · Gato 30% · Zorro 10% |
| Plata | 5.000 monedas · recompensas | Gato 50% · Zorro 35% · Halcón 15% |
| Oro | 40.000 monedas · recompensas · Robux | Zorro 50% · Halcón 35% · Dragón 15% |
| **Cósmica** | **Solo Robux** | **Fénix Cronal +80% (60%) · Titán de Cuarzo +100% (30%) · Señor del Tiempo +150% (10%)** |

Las mascotas de la Cápsula Cósmica son exclusivas de Robux y más fuertes que cualquiera de monedas (el Dragón es +60%). Las probabilidades se muestran en el Criadero, como exige Roblox para compras aleatorias pagadas.

**Recompensa diaria** (una vez por día UTC; la racha vuelve al día 1 si saltas un día):

| Día 1 | Día 2 | Día 3 | Día 4 | Día 5 | Día 6 | Día 7 |
|---|---|---|---|---|---|---|
| 250 monedas | 1 Latón | 750 monedas | 2 Latón | 2.000 monedas | 1 Plata | 1 Oro |

**Premios por tiempo jugado** (cada día, se reclaman una vez): 5 min → 150 monedas · 15 min → 1 Latón · 30 min → 1.000 monedas · 60 min → 1 Plata · 120 min → 1 Oro.

- El botón **«Premios»** abre el panel. El juego avisa al entrar y cuando hay un premio listo.
- El premio extra del Cronómetro Maestro ahora es una Cápsula de Latón en la Mochila.
- **Seguridad:** el servidor controla las fechas (UTC) y el tiempo jugado; el cliente solo pide reclamar.

### 15.8 Distribución de la base en media luna (DEV-010)

> Dirección de Jhonn (2026-11-20). Propuesta DEC-012. Distribución funcional: el arte final se hará aparte.

- **6 jugadores por servidor** y **6 plots** en **media luna** alrededor de la plaza central de la base. La media luna se abre hacia el muro frontal. El límite de 6 se fija al publicar, en Game Settings → Places → Max Players.
- **Cada plot** mide 34 × 40 studs y mira hacia la plaza. De delante hacia atrás tiene: la **caminadora** (fuera del plot, del lado de la plaza), el **panel** del plot (esquina delantera), las **vitrinas** (hasta 15, en el centro) y el **taller** (al fondo).
- **Muro frontal** amplio, en el borde de la base, con una **abertura central** para salir a correr hacia las zonas. Pegados a su cara interior están la **Tienda**, la **Tienda Robux**, el **Criadero de cápsulas** y el **Cronómetro Maestro**.
- Se aparece en la plaza, frente a la salida. Cuando tienes plot, al reaparecer vas delante de él.
- Para que quepa la media luna, el mapa se ensancha a 260 studs de ancho y la base llega hasta Z = −205.
