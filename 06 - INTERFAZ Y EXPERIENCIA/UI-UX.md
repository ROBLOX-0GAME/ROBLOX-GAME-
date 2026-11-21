
# 🎨 INTERFAZ Y EXPERIENCIA DE USUARIO (UI/UX)

## 1. Propósito

Documentar el diseño de la interfaz, la experiencia del jugador, la navegación y la interacción con los sistemas del juego.

## 2. Principios de diseño

- Interfaz intuitiva.
- Información fácil de comprender.
- Navegación sencilla.
- Diseño visual coherente.
- Buena experiencia en PC, móvil y consola.
- Accesibilidad y legibilidad.
- Evitar elementos visuales innecesarios.

## 3. HUD (Head-Up Display)

El HUD mostrará la información importante durante la partida.

Elementos pendientes de definir:

- Barra de vida.
- Energía o recursos.
- Nivel del jugador.
- Experiencia.
- Habilidades disponibles.
- Objetivos activos.
- Monedas.
- Indicadores de combate.

## 4. Menús principales

### Menú principal
- Entrada al juego.
- Configuración.
- Información del jugador.

### Menú de personaje
- Estadísticas.
- Equipamiento.
- Apariencia.
- Progresión.

### Menú de inventario
- Objetos.
- Armas.
- Armaduras.
- Recursos.
- Organización de objetos.

### Menú de habilidades
- Habilidades disponibles.
- Mejoras.
- Enfriamientos.
- Descripciones.

## 5. Interfaz de misiones

- Nombre de la misión.
- Descripción.
- Objetivos.
- Progreso.
- Recompensas.
- Indicadores de ubicación.

## 6. Interfaz de combate

- Indicadores de daño.
- Estados del personaje.
- Indicadores de habilidades.
- Información de enemigos.
- Alertas de ataques.
- Información de jefes.

## 7. Notificaciones

- Recompensas obtenidas.
- Objetos adquiridos.
- Subida de nivel.
- Misiones completadas.
- Eventos importantes.
- Alertas del sistema.

## 8. Experiencia multiplataforma

### PC
Diseño adaptado a teclado y ratón.

### Móvil
Controles táctiles y elementos adaptados a pantallas pequeñas.

### Consola
Navegación compatible con mando.

Los diseños definitivos están pendientes de aprobación.

## 9. Accesibilidad

- Tamaño de texto legible.
- Contraste adecuado.
- Indicadores visuales claros.
- Controles configurables cuando sea viable.
- Evitar depender únicamente del color para transmitir información.

## 10. Rendimiento de interfaz

- Evitar interfaces innecesariamente complejas.
- Reducir actualizaciones visuales redundantes.
- Controlar la cantidad de elementos activos.
- Optimizar animaciones y transiciones.

## 12. Propuesta ART-014 — presentación visual (Bloque A, pendiente de código)

> **Estado (ART-015, 2026-11-20):** aplicado en `game/src` (commit `0b92ac5`) como propuesta DEC-025. **Completado en ART-016 (2026-11-21):** carteles de vitrina y de mascota solo propios, rótulo de puerta solo si falta velocidad, aro de rareza en las vitrinas, ajuste «Efectos visuales» y panel de estado plegable. Solo queda sin hacer el `SurfaceGui` del arco de salida: el rótulo va encima del arco y ya no se superpone.
>
> **Propuesta** (DEC-025), escrita el 2026-11-20 en ART-014. Se aplica en `game/src` cuando DEV-019 libere la ruta (tarea ART-015). Solo cambia la presentación: no toca etiquetas de CollectionService, atributos, prompts, colisiones, posiciones funcionales, economía, guardado ni red. Todo efecto nuevo corre **en el cliente** y se apaga si falta un asset.

### 12.1 Carteles (`BillboardGui`) por contexto

Hoy todos se ven a la vez hasta 120–220 studs y en la salida se superponen tres rótulos y el modelo `mdl_cartel_salida`.

| Cartel (llamada actual) | Ahora | Propuesta |
|---|---|---|
| Estación (`WorldService.buildStation`, `makeSign(base, …, 10)`) | 140 studs | 70 studs. Título con icono `ico_est_*` y la acción solo a menos de 25 studs. |
| Vitrina (`PlotService:225`) | 140 studs, una por vitrina | 30 studs y solo en el plot propio. Fuera de ese radio, nada. |
| Plot (`PlotService:65`) | 160 | 90. |
| Casa (`HouseService:200`) | 120 | 60. |
| Zona (`WorldService:225`) | 140 (por defecto) | 120, y **se quita en la zona 1**, cuyo nombre ya va en el arco de salida. |
| Puerta de velocidad (`WorldService:263`) | 220 | 120. Solo se muestra si al jugador le falta velocidad (filtro en el cliente). |
| BASE SEGURA (`WorldService:302`) | 200 | 80, más abajo y a un lado de la abertura. |
| SALIDA (`WorldService:337`) | 220 | Se sustituye por un `SurfaceGui` en la cara del `mdl_cartel_salida` cuando el modelo existe. Si falta, queda el `BillboardGui` actual. |
| Mascota (`PetService:42`) | 60 | 30 y solo las del jugador. |

`makeSign` gana dos parámetros opcionales (`LightInfluence = 0` y `MaxDistance` por tipo). Su firma actual no cambia.

### 12.2 Efectos solo en el cliente (`Client/Vfx.luau`, módulo nuevo)

- **Punto de entrada:** `Ui.request` llama a `Vfx.onAction(action, result)` cuando `result.ok`. La subida de nivel se detecta en `updateHud` cuando `state.level` aumenta. No hay eventos nuevos en `Net` ni lógica nueva en el servidor.
- **Efectos**, una sola vez por acción, con `Debris` y sin bucles por frame:

| Acción | Efecto | Coste |
|---|---|---|
| Fabricar reloj | Ráfaga de chispas latón y cian en el taller (`ParticleEmitter:Emit(24)`) y `Highlight` latón de 0,6 s sobre el reloj nuevo | 1 emisor, 1 Highlight |
| Vender | Monedas que suben del mostrador (`Emit(12)`, textura de `ico_monedas`) | 1 emisor |
| Subir de nivel | Anillo cian que se expande a los pies (tween de un `Part` Neon de 0,4 s) y destello del HUD | 1 parte temporal |
| Abrir cápsula | Sacudida de 0,4 s de la cápsula (tween de CFrame) y destello del color de la rareza | 1 emisor y 1 luz breve |
| Recompensa Rara o mejor | `PointLight` de 1 s con el color de `GameData.RarityColors` y chispas extra | 1 luz |
| Tutorial | `Beam` cian del jugador al objetivo del paso actual, que se quita al cumplirlo | 1 Beam |
| Carrera (persecución) | `Trail` cian en el personaje mientras lleva botín. Se quita al guardar o al ser atrapado | 1 Trail |

- **Límites:** máximo 3 efectos activos a la vez, `ParticleEmitter.Rate = 0` (solo `Emit`) y sin efectos permanentes. En móvil (`TouchEnabled` y `QualityLevel` bajo), las partículas se reducen a la mitad. Un ajuste «Efectos: sí/no» va en el menú de Ajustes.

### 12.3 Rarezas (colección)

- Pieza robable: ahora el modelo de `AssetLibrary` oculta la bola Neon y solo queda la `PointLight`. **Propuesta:** el cliente añade un `Highlight` con `FillTransparency = 0,85` del color de la rareza solo a las piezas Rara, Legendaria y Herencia que estén a menos de 40 studs (como mucho 6 a la vez). Las Comunes y Poco comunes no cambian.
- Relojes en las vitrinas: un aro fino del color de su rareza en la base de la vitrina, con una ligera rotación de 20 s por vuelta (`TweenService` en bucle con `RepeatCount = -1`, sin `RenderStepped`). Solo en el plot propio.
- Cápsulas: el color de la rareza en la luz breve de apertura (12.2).

### 12.4 HUD (paleta «taller fantástico»)

- **Paneles:** carbón `#1E1F26` al 85 % de opacidad, con borde latón `#C27B3A` de 2 px (`UIStroke`) y radio de 10 px. Texto marfil `#F2F0EA` y valores destacados en oro `#F2C14E`.
- **Botones laterales:** pasan de 5 bloques azules anchos a botones cuadrados de 64 px con icono (`ico_mochila`, `ico_premios`, `ico_ruleta`, `ico_robux` e `ico_ajustes`) y la tecla en una esquina, solo con teclado. El acento cian `#5BD5E0` marca el botón seleccionado con mando.
- **Tipografía:** `GothamBold` para los títulos y `GothamMedium` para los valores (ya están en el juego). Mínimo 14 px reales en móvil, con el `UIScale` actual.
- **Menos saturación:** el panel de velocidad se pliega a una línea («16 · Barrio Humilde») y se despliega al tocarlo. Las notificaciones (toasts) pasan de 4 a 3 como máximo.

### 12.5 Mundo (ubicación de los modelos nuevos)

- **Torre de reloj** (`mdl_torre_reloj`, 9 × 26,6 × 9): centro de la plaza `WorldService.PlazaCenter` (0, 0, −70), con `AssetLibrary.place`. Las bancas actuales quedan alrededor. Antes hay que comprobar en Studio que no tape el aparecido ni los plots.
- **Identidad por zona.** `WorldService` elige la decoración por `zoneIndex` (hoy cicla árbol, arbusto y roca en todas):

| Zona | Vegetación | Detalles | Valla |
|---|---|---|---|
| 1 Barrio Humilde | `mdl_arbol`, `mdl_arbusto` | `mdl_z1_tendedero`, `mdl_caja_madera` | `mdl_valla` |
| 2 Barrio Obrero | `mdl_z2_alamo`, `mdl_roca` | `mdl_z2_barriles` | `mdl_valla` |
| 3 Zona Residencial | `mdl_z3_arbol_redondo`, `mdl_arbusto` | `mdl_z3_buzon` | `mdl_z3_seto` |
| 4 Mansiones | `mdl_z4_cipres`, `mdl_z4_topiario` | `mdl_z4_fuente` (una por zona) | `mdl_z3_seto` |
| 5 Colina de los Millonarios | `mdl_z5_palmera` | `mdl_z5_estatua_reloj` (una), `mdl_z5_farol_dorado` | `mdl_z3_seto` |

  Si falta un modelo de la zona, se usa el genérico actual (`mdl_arbol`, `mdl_arbusto`, `mdl_roca` o `mdl_valla`), así que jugar nunca depende de ellos.
- **Estaciones:** icono `ico_est_*` en el cartel (12.1). Las siluetas de los mostradores se rehacen en una tarea de arte posterior, con el mismo `STATION_ASSETS`.

### 12.6 Iluminación

DEC-022 se queda igual: no se sube el bloom ni la saturación. Solo falta comprobar en Studio que `Technology = Future` está puesto.

## 11. Documentos relacionados

- [[Dashboard]]
- [[Vision-General]]
- [[GDD]]
- [[Lista-de-Sistemas]]
- [[Diseño-del-Mundo]]
- [[Economia-y-Progresion]]
- [[Multiplayer]]
- [[Arquitectura-General]]
- [[Backlog]]

---

**Estado:** Borrador inicial  
**Aprobación:** Pendiente del equipo

