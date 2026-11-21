# 💡 RECOMENDACIONES Y PREGUNTAS DE CLAUDE

> Archivo creado el **2026-11-21** a pedido de Jhonn: mientras él no está, Claude trabaja **sin preguntar** y anota aquí sus dudas, supuestos y propuestas. Cuando Jhonn vuelva, abre este archivo, contesta cada punto y Claude hace los cambios.
>
> **Cómo usarlo:** cada punto tiene un ID (R-001…). Contesta debajo de «**Respuesta de Jhonn:**» y cambia el estado a «Respondida». Lo que dice «Supuesto aplicado» ya está en el juego; si no te gusta, se revierte.
>
> Relacionado: [[Registro-de-Decisiones]] · [[Backlog]] · [[PROMPT_PIEZAS_RELOJ_ZADIEL]]

---

## A. Velocidad, zonas y mejoras (DEV-020, DEV-021)

### R-001 — Con 8 niveles de caminadora no se llega a las zonas altas (importante)

- **Estado:** Abierta. **Prioridad:** Alta.
- **Situación:** pediste las 12 zonas hasta 99,9T (DEC-024) y, después, máximo 8 niveles de caminadora (DEC-026). Con 8 niveles la caminadora entrena ×256.
- **Cálculo (sin pagar):** 0,5 × 256 = 128 de velocidad por segundo. Con 3 mascotas legendarias (×2,8) y la mejora de velocidad al máximo (×3), la velocidad final es unas 8,4 veces lo entrenado.
  - Zona 5 (1M): unos **15 minutos** entrenando. ✅
  - Zona 7 (200M): unos **2 días** sin parar. ❌
  - Zona 12 (99,9T): **siglos**. ❌ Ni con el pase ×512 + Turbo (≈ 3 años).
- **Propuestas (elige una):**
  1. **Renacer** (ya aprobado para después): cada renacimiento multiplica el entrenamiento (por ejemplo ×2, ×3, ×5…). Es lo que usan los simuladores populares para llegar a cifras enormes. **← Recomendada.**
  2. Subir el máximo de la caminadora cuando se añadan zonas (8 ahora y +8 por cada mundo).
  3. Bajar los requisitos de las zonas 6 a 12.
- **Supuesto aplicado:** dejé los 8 niveles como pediste. Hoy un jugador llega con facilidad hasta la zona 5-6 y se atasca ahí hasta que exista el Renacer.
- **Respuesta de Jhonn:**

### R-002 — Las mejoras son muy baratas frente a las monedas de las zonas altas

- **Estado:** Abierta. **Prioridad:** Media.
- **Situación:** con 100 monedas y ×1,5, el nivel 8 cuesta unas 1.700 monedas y todas las mejoras al máximo suman unas 30.000. Pero una sola pieza robada en la zona 5 ya trae 40.960 monedas (DEC-024), así que al llegar a la zona 3 o 4 se puede comprar todo de golpe.
- **Propuesta:** está bien para el arranque (el jugador siente progreso rápido). Cuando exista el Renacer, cada renacimiento podría reiniciar las mejoras y subir el precio base (×10 por renacimiento).
- **Supuesto aplicado:** precios exactamente como pediste (100 y ×1,5).
- **Respuesta de Jhonn:**

### R-003 — ¿«Todas las mejoras» o solo plot, caminadora y carga?

- **Estado:** Abierta. **Prioridad:** Baja.
- **Duda:** dijiste «cada mejora empezará en 100 monedas… límite de 8 mejoras (tanto plot como caminadora; llevar más objetos solo 3)».
- **Supuesto aplicado:** lo apliqué a **todas**: mochila, velocidad, salto, suerte, vitrinas y caminadora, con 8 niveles; la carga, 3. Para que 8 niveles no rompan nada:
  - **Vitrinas:** +1 por nivel (antes +2). Con 8 niveles = 11 vitrinas; el plot solo tiene sitio para 15.
  - **Salto:** +1 por nivel (antes +1,5), para no saltar por encima de los muros.
- **Respuesta de Jhonn:**

### R-004 — El puesto «Mochila y Carga»

- **Estado:** Hecho (revisar). **Prioridad:** Baja.
- **Supuesto aplicado:** en lugar de crear un puesto nuevo, el **Puesto de Carga** pasó a llamarse **«Mochila y Carga»** y ahora vende las dos mejoras: más espacio en la mochila (+10 por nivel) y más objetos por viaje (de 1 a 4). La mochila ya no está en la Tienda. Así no se añade otro edificio al mapa (mejor para el renderizado).
- **Pendiente menor:** el título del menú todavía dice «Puesto de Carga — Capacidad por viaje». Está en `Ui.luau`, que dejé libre para que Zadiel termine ART-016; se cambia en la próxima tarea que toque la interfaz.
- **Respuesta de Jhonn:**

### R-005 — Cinemática antes del tutorial

- **Estado:** Verificada por código; falta verla con un jugador nuevo.
- **Situación:** la cinemática (abandono a los 18 años, cámara a la plaza y pieza del legado) existe desde DEV-011. El servidor no muestra el tutorial hasta que el jugador termina la introducción (`introDone`). Tu cuenta ya la vio, y desde las herramientas no puedo crear un jugador nuevo.
- **Cómo comprobarla (1 minuto):** en Studio → pestaña **Test** → **Clients and Servers** con 1 jugador (usa una cuenta de prueba nueva), o en el juego: Ajustes → «Ver historia».
- **Respuesta de Jhonn:**

### R-006 — Datos de tu cuenta de desarrollo

- **Estado:** Informativa.
- **Situación:** Studio tiene acceso a DataStore, así que las pruebas guardan progreso real en tu cuenta. Además, como creador de la experiencia tienes **todos los pases**, incluido Entrenamiento ×512, y por eso tu velocidad y tu entrenamiento son muy altos.
- **Propuesta:** si quieres jugar «como un jugador normal», hay que probar con otra cuenta. Si quieres que reinicie tus datos, dímelo.
- **Respuesta de Jhonn:**

---

## B. Piezas de reloj, mesa de armado y animaciones (ART-017)

Detalle completo en [[PROMPT_PIEZAS_RELOJ_ZADIEL]]. Son cambios grandes del sistema de piezas; necesito tu visto bueno antes de programarlos (tarea DEV aparte).

### R-007 — Reemplazar las piezas actuales por Caja, Calibre, Esfera y Manecillas

- **Estado:** Abierta. **Prioridad:** Alta.
- **Situación:** hoy se roban 7 piezas genéricas (engranaje, resorte, tornillo, cristal, correa, rubí, diamante) y los relojes piden cantidades de ellas.
- **Propuesta:** cada pieza robada pasa a ser una de **4 clases** (Caja, Calibre, Esfera, Manecillas) **de un reloj concreto** y con **rareza** (Común → Divino). Un reloj se arma con 1 de cada clase. Las 7 piezas antiguas se convierten en monedas al cargar los datos (no se pierde valor).
- **Pregunta:** ¿conservo las piezas antiguas como «materiales» para otra cosa, o se eliminan?
- **Respuesta de Jhonn:**

### R-008 — Fórmula de penalización si una pieza no es de ese reloj

- **Estado:** Abierta. **Prioridad:** Alta.
- **Propuesta:** cada pieza «ajena» baja **un nivel de rareza** el reloj resultante y resta un **25 %** a su valor, al ingreso pasivo y a la suerte (2 ajenas: −50 %; 3: −75 %; 4: el reloj queda «Genérico», con −90 %). Una pieza de **mayor** rareza que el reloj no penaliza el valor, pero tampoco lo sube.
- **Respuesta de Jhonn:**

### R-009 — Tipos de calibre (cuarzo, mecánico y automático)

- **Estado:** Abierta. **Prioridad:** Media.
- **Propuesta:** el tipo de calibre cambia un detalle de juego, no solo el aspecto:
  - **Cuarzo:** fácil de encontrar.
  - **Mecánico:** +10 % de valor.
  - **Automático:** +20 % de valor y +2 % de suerte exhibido.
- **Respuesta de Jhonn:**

### R-010 — ¿Cuántos relojes distintos y de qué rarezas?

- **Estado:** Abierta. **Prioridad:** Media.
- **Propuesta:** empezar con los **6 relojes actuales** (bolsillo, pulsera, cronógrafo, real, millonario y legado) más **6 nuevos** para las zonas 6 a 12, uno por rareza. Cada zona da sobre todo piezas de 1 o 2 relojes.
- **Respuesta de Jhonn:**

---

## C. Pendiente acordado (sin preguntas)

- **DEV-022 — Pase Dinero ×2 (249 R$) y ventajas VIP:** menos espera en los premios por tiempo, etiqueta [VIP] en el chat y más tiempo de ganancia offline (hay que crear la ganancia offline: hoy el plot solo paga con el jugador conectado). Propuesta de cifras:
  - Premios por tiempo: el VIP los cumple en un 30 % menos de tiempo.
  - Ganancia offline: hasta 2 h para todos; 8 h con VIP; al 50 % del ingreso del plot.
- **Renacer:** después de DEV-022, con cifras propuestas para que encaje con R-001.
