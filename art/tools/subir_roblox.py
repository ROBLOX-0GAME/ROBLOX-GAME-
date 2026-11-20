"""
subir_roblox.py — sube a Roblox (Open Cloud, Assets API) los mapas PBR y los modelos PBR (ART-011).

    python art/tools/subir_roblox.py --usuario 2311077683            # sube lo que falte
    python art/tools/subir_roblox.py --usuario 2311077683 --prueba   # no sube nada: lista y valida
    python art/tools/subir_roblox.py --grupo 123456 --solo imagenes  # a nombre de un grupo

Qué sube:
- Los mapas art/texturas/export/tex_<material>_{color,normal,rugosidad,metalico}.png de los
  materiales que usan los modelos PBR, como **Image** (el ID sirve en SurfaceAppearance).
- Los FBX art/export/modelos/mdl_{reloj,pieza,legado,capsula}_*.fbx como **Model**.

Qué escribe (y se sube a Git, no son secretos):
- art/tools/ids_roblox.json: nombre → ID de asset. Si se corta, al repetir solo sube lo que falta.
- art/tools/montar_assets.luau: script para la barra de comandos de Studio que carga los modelos en
  ReplicatedStorage/Assets y les monta los SurfaceAppearance con estos IDs.

La API key se lee de la variable de entorno ROBLOX_API_KEY y NUNCA se escribe en ningún archivo.
Permisos de la clave: Assets API con lectura y escritura. Solo usa la biblioteca estándar de Python.
"""

import argparse
import glob
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid

AQUI = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(AQUI, "..", ".."))
TEXTURAS = os.path.join(REPO, "art", "texturas", "export")
MODELOS = os.path.join(REPO, "art", "export", "modelos")
IDS_JSON = os.path.join(AQUI, "ids_roblox.json")
LUAU = os.path.join(AQUI, "montar_assets.luau")

API = "https://apis.roblox.com/assets/v1"
PREFIJOS_PBR = ("mdl_reloj_", "mdl_pieza_", "mdl_legado_", "mdl_capsula_")
MAPAS = ("color", "normal", "rugosidad", "metalico")
DESCRIPCION = "BUILD A WATCH! — asset del juego (ART-011)"


# ---------------------------------------------------------------------------
# Archivos a subir
# ---------------------------------------------------------------------------

def modelos_pbr():
    return sorted(f for f in glob.glob(os.path.join(MODELOS, "*.fbx"))
                  if os.path.basename(f).startswith(PREFIJOS_PBR))


def materiales():
    """Materiales con sus 4 mapas en art/texturas/export."""
    nombres = sorted({os.path.basename(f)[4:-len("_color.png")]
                      for f in glob.glob(os.path.join(TEXTURAS, "tex_*_color.png"))})
    return [n for n in nombres if all(os.path.isfile(os.path.join(TEXTURAS, f"tex_{n}_{m}.png")) for m in MAPAS)]


# ---------------------------------------------------------------------------
# Open Cloud
# ---------------------------------------------------------------------------

def _peticion(metodo, url, clave, cuerpo=None, tipo=None, intentos=6):
    for intento in range(intentos):
        req = urllib.request.Request(url, data=cuerpo, method=metodo)
        req.add_header("x-api-key", clave)
        if tipo:
            req.add_header("Content-Type", tipo)
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return json.loads(r.read().decode("utf-8") or "{}")
        except urllib.error.HTTPError as e:
            texto = e.read().decode("utf-8", "replace")[:500]
            if e.code in (429, 500, 502, 503, 504) and intento < intentos - 1:
                espera = int(e.headers.get("Retry-After") or 0) or 2 ** (intento + 1)
                print(f"    {e.code}: reintento en {espera} s")
                time.sleep(espera)
                continue
            raise SystemExit(f"Error {e.code} en {metodo} {url}: {texto}")
        except urllib.error.URLError as e:
            if intento < intentos - 1:
                time.sleep(2 ** (intento + 1))
                continue
            raise SystemExit(f"Sin conexión con {url}: {e}")


def _multipart(campos):
    """campos: lista de (nombre, valor_bytes, nombre_archivo|None, tipo|None)."""
    limite = "----bawatch" + uuid.uuid4().hex
    partes = []
    for nombre, valor, archivo, tipo in campos:
        cabecera = f'--{limite}\r\nContent-Disposition: form-data; name="{nombre}"'
        if archivo:
            cabecera += f'; filename="{archivo}"'
        cabecera += "\r\n"
        if tipo:
            cabecera += f"Content-Type: {tipo}\r\n"
        partes.append(cabecera.encode() + b"\r\n" + valor + b"\r\n")
    return b"".join(partes) + f"--{limite}--\r\n".encode(), f"multipart/form-data; boundary={limite}"


def subir(clave, creador, ruta, tipo_asset, tipo_mime):
    nombre = os.path.splitext(os.path.basename(ruta))[0]
    solicitud = {"assetType": tipo_asset, "displayName": nombre[:50], "description": DESCRIPCION,
                 "creationContext": {"creator": creador}}
    with open(ruta, "rb") as f:
        contenido = f.read()
    cuerpo, tipo = _multipart([("request", json.dumps(solicitud).encode(), None, None),
                               ("fileContent", contenido, os.path.basename(ruta), tipo_mime)])
    op = _peticion("POST", f"{API}/assets", clave, cuerpo, tipo)
    # La operación puede tardar: se consulta hasta que termine
    ruta_op = op.get("path") or ("operations/" + op.get("operationId", ""))
    for _ in range(90):
        if op.get("done"):
            break
        time.sleep(2)
        op = _peticion("GET", f"{API}/{ruta_op}", clave)
    if not op.get("done"):
        raise SystemExit(f"La subida de {nombre} no terminó a tiempo ({ruta_op}). Vuelve a ejecutar el script.")
    if "error" in op:
        raise SystemExit(f"Roblox rechazó {nombre}: {op['error']}")
    respuesta = op.get("response", {})
    asset_id = respuesta.get("assetId") or respuesta.get("path", "").split("/")[-1]
    if not str(asset_id).isdigit():
        raise SystemExit(f"Respuesta inesperada al subir {nombre}: {json.dumps(op)[:500]}")
    return int(asset_id)


# ---------------------------------------------------------------------------
# Resultados
# ---------------------------------------------------------------------------

def leer_ids():
    if os.path.isfile(IDS_JSON):
        with open(IDS_JSON, encoding="utf-8") as f:
            return json.load(f)
    return {"imagenes": {}, "modelos": {}}


def guardar_ids(ids):
    with open(IDS_JSON, "w", encoding="utf-8", newline="\n") as f:
        json.dump(ids, f, indent=2, ensure_ascii=False, sort_keys=True)
        f.write("\n")


def escribir_luau(ids):
    mats = sorted({k.rsplit("_", 1)[0] for k in ids["imagenes"]})
    lineas = []
    for m in mats:
        v = [ids["imagenes"].get(f"{m}_{mapa}", 0) for mapa in MAPAS]
        lineas.append(f"\t{m} = {{ {', '.join(str(x) for x in v)} }},")
    modelos = [f"\t{n} = {i}," for n, i in sorted(ids["modelos"].items())]
    texto = f"""-- montar_assets.luau — GENERADO por art/tools/subir_roblox.py (ART-011). No editar a mano.
-- Barra de comandos de Roblox Studio, con la place oficial abierta. No es código del juego.
-- 1) Carga cada modelo subido en ReplicatedStorage/Assets con su nombre (sustituye el anterior).
-- 2) Monta un SurfaceAppearance en cada MeshPart según su nombre de material.

local IDS = {{ -- material = {{ color, normal, rugosidad, metalico }}
{chr(10).join(lineas)}
}}
local MODELOS = {{
{chr(10).join(modelos)}
}}

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage:FindFirstChild("Assets") or Instance.new("Folder")
assets.Name = "Assets"
assets.Parent = ReplicatedStorage

local function id(n) return "rbxassetid://" .. n end
local cargados, fallos = 0, {{}}
for nombre, assetId in MODELOS do
	local ok, contenedor = pcall(InsertService.LoadAsset, InsertService, assetId)
	if not ok then
		table.insert(fallos, nombre .. " (" .. tostring(contenedor) .. ")")
		continue
	end
	-- LoadAsset devuelve un Model contenedor; si dentro hay un único Model, se usa ese
	local hijos = contenedor:GetChildren()
	local modelo = (#hijos == 1 and hijos[1]:IsA("Model")) and hijos[1] or contenedor
	modelo.Name = nombre
	local viejo = assets:FindFirstChild(nombre)
	if viejo then viejo:Destroy() end
	modelo.Parent = assets
	if modelo ~= contenedor then contenedor:Destroy() end
	cargados += 1
end

local montados, avisos = 0, {{}}
for _, modelo in assets:GetChildren() do
	if MODELOS[modelo.Name] then
		for _, parte in modelo:GetDescendants() do
			if parte:IsA("MeshPart") then
				local m = IDS[parte.Name]
				if not m or m[1] == 0 then
					table.insert(avisos, modelo.Name .. "/" .. parte.Name)
				else
					local sa = parte:FindFirstChildOfClass("SurfaceAppearance")
					if sa then sa:Destroy() end
					parte.TextureID = ""
					sa = Instance.new("SurfaceAppearance")
					sa.ColorMap, sa.NormalMap, sa.RoughnessMap, sa.MetalnessMap = id(m[1]), id(m[2]), id(m[3]), id(m[4])
					sa.Parent = parte
					if parte.Name == "cristal_zafiro" then
						parte.Transparency = modelo.Name == "mdl_pieza_cristal" and 0.3 or 0.85
					end
					montados += 1
				end
			end
		end
	end
end
print(("Modelos cargados: %d · SurfaceAppearance montados: %d (esperados 78)"):format(cargados, montados))
if #fallos > 0 then warn("No se pudieron cargar: " .. table.concat(fallos, ", ")) end
if #avisos > 0 then warn("MeshParts sin material reconocido: " .. table.concat(avisos, ", ")) end
"""
    with open(LUAU, "w", encoding="utf-8", newline="\n") as f:
        f.write(texto)


# ---------------------------------------------------------------------------

def main():
    for flujo in (sys.stdout, sys.stderr):  # la consola de Windows no siempre usa UTF-8
        try:
            flujo.reconfigure(encoding="utf-8")
        except (AttributeError, ValueError):
            pass
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    quien = p.add_mutually_exclusive_group(required=True)
    quien.add_argument("--usuario", help="ID del usuario dueño de la place (los assets quedan a su nombre)")
    quien.add_argument("--grupo", help="ID del grupo dueño de la place")
    p.add_argument("--solo", choices=["imagenes", "modelos"], help="subir solo una parte")
    p.add_argument("--prueba", action="store_true", help="no sube nada: lista lo pendiente y genera el .luau")
    a = p.parse_args()

    creador = {"userId": str(a.usuario)} if a.usuario else {"groupId": str(a.grupo)}
    ids = leer_ids()
    pendientes = []
    if a.solo != "modelos":
        for m in materiales():
            for mapa in MAPAS:
                clave_id = f"{m}_{mapa}"
                if clave_id not in ids["imagenes"]:
                    pendientes.append(("imagenes", clave_id, os.path.join(TEXTURAS, f"tex_{m}_{mapa}.png"), "Image", "image/png"))
    if a.solo != "imagenes":
        for ruta in modelos_pbr():
            nombre = os.path.splitext(os.path.basename(ruta))[0]
            if nombre not in ids["modelos"]:
                pendientes.append(("modelos", nombre, ruta, "Model", "model/fbx"))

    n_img = sum(1 for x in pendientes if x[0] == "imagenes")
    print(f"Materiales: {len(materiales())} · modelos PBR: {len(modelos_pbr())} · "
          f"ya subidos: {len(ids['imagenes'])} imágenes y {len(ids['modelos'])} modelos · "
          f"pendientes: {n_img} imágenes y {len(pendientes) - n_img} modelos")
    for p_ in pendientes:
        tam = os.path.getsize(p_[2]) / 1024
        if tam > 20 * 1024:
            raise SystemExit(f"{p_[2]} supera 20 MB, el límite de Open Cloud")
    if a.prueba:
        for tipo, nombre, ruta, *_ in pendientes:
            print(f"  [prueba] {tipo}: {nombre} ← {os.path.relpath(ruta, REPO)}")
        escribir_luau(ids)
        print(f"Generado {os.path.relpath(LUAU, REPO)} con los IDs actuales (modo prueba: nada subido).")
        return

    clave = os.environ.get("ROBLOX_API_KEY", "").strip()
    if not clave:
        raise SystemExit("Falta la variable de entorno ROBLOX_API_KEY (no la pongas en ningún archivo del repo).")
    for i, (tipo, nombre, ruta, tipo_asset, mime) in enumerate(pendientes, 1):
        print(f"[{i}/{len(pendientes)}] {tipo}: {nombre} …", flush=True)
        ids[tipo][nombre] = subir(clave, creador, ruta, tipo_asset, mime)
        guardar_ids(ids)  # se guarda tras cada subida para poder continuar si se corta
        print(f"    → {ids[tipo][nombre]}")
    escribir_luau(ids)
    print(f"Listo: {len(ids['imagenes'])} imágenes y {len(ids['modelos'])} modelos en "
          f"{os.path.relpath(IDS_JSON, REPO)}; script de Studio en {os.path.relpath(LUAU, REPO)}.")


if __name__ == "__main__":
    sys.exit(main())
