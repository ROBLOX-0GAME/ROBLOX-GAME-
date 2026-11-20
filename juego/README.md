# BUILD A WATCH! — código del juego

Código fuente Luau del juego (tarea DEV-001). Todo vive en texto para poder versionarlo con Git.

## Abrir el juego en Roblox Studio

### Opción A — Place compilada (no requiere instalar nada más que Python)

1. En una terminal, desde la raíz del repositorio:
   ```
   python juego/build.py
   ```
2. Abre `juego/build/BuildAWatch.rbxlx` en Roblox Studio (File → Open from File).
3. Pulsa **Play**. En la ventana **Output** deben aparecer:
   - `[BUILD A WATCH!] Servidor iniciado.`
   - `[Pruebas] N correctas, 0 fallidas`

`juego/build/` está en `.gitignore`: es un archivo generado; se vuelve a crear con el comando.
Si cambias algo dentro de Studio, **cópialo a `juego/src/`**; si no, se pierde al recompilar.

### Opción B — Rojo (sincronización en vivo, recomendado a futuro)

Con Rojo 7 y su plugin de Studio instalados: `rojo serve juego/default.project.json` y conecta desde el plugin.
Así puedes usar `Proyecto Roblox Studio.rbxl` como place base.

### Guardado de datos en Studio

Para probar el guardado real: Game Settings → Security → **Enable Studio Access to API Services**.
Sin esa opción el juego funciona con datos temporales y avisa “Modo de prueba: tu progreso no se guardará”.

## Estructura

```
juego/
  default.project.json   mapa de carpetas → servicios de Roblox (formato Rojo)
  build.py               revisión estática + compilación a .rbxlx
  src/shared/            ReplicatedStorage.Shared (cliente y servidor)
    Config.luau          números técnicos y de balance (PROPUESTA)
    GameData.luau        piezas, relojes y mejoras (PROPUESTA)
    PlayerLogic.luau     reglas puras del juego (probadas)
  src/server/            ServerScriptService.Server
    Main.server.luau     arranque de servicios
    Services/            Datos, mundo, casas y dueños, acciones, museo, jefe, mascotas, personaje, remotos
    Tests/               pruebas que corren al pulsar Play en Studio
  src/client/            StarterPlayerScripts.Client
    Main.client.luau     conecta remotos con la interfaz
    Ui.luau              HUD, notificaciones y menús
```

## Bucle de juego (propuesta; detalle en el GDD §15)

1. Sal de la **base segura** y corre a una zona. Hay 5 zonas cada vez más ricas y para entrar a cada una necesitas velocidad.
2. Entra a una casa y **roba** piezas. Al salir, **el dueño te persigue**: llega a la base para guardar el botín; si te atrapa, lo pierdes.
3. Fabrica **relojes** en el **Taller** y **véndelos** en la **Tienda** o **exhíbelos** en el **Museo**.
4. Compra **mejoras** en la Tienda y **huevos de mascota** en el **Criadero**; las mascotas multiplican la velocidad.
5. Cuando el **Cronómetro Maestro** se averíe, entrégale piezas junto a todo el servidor para ganar monedas y huevos.

Controles: E / botón X del mando / tocar para estaciones y robos · B / botón Y / botón «Mochila» para la mochila · botón B del mando o «X» para cerrar menús.

## Reglas para editar

- El servidor decide todo: el cliente solo pide acciones por `Remotes.Action`.
- Las reglas nuevas van en `PlayerLogic.luau` con su prueba en `Tests/`.
- Antes de subir cambios: `python juego/build.py --check`.
- Registra cada paso en `09 - TAREAS Y DESARROLLO/Changelog.md`.
