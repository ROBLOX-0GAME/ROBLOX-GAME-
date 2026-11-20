"""
relojes_detallados.py — los 6 relojes con materiales PBR (ART-006).

Cada reloj se exporta como VARIAS mallas, una por material. En Roblox, el FBX se
importa como un Model con un MeshPart por material, y cada MeshPart lleva un
SurfaceAppearance con los 4 mapas de su material:

    MeshPart «metal_oro_pulido» → tex_metal_oro_pulido_{color,normal,rugosidad,metalico}.png

Mismos nombres de archivo que los relojes base (mdl_reloj_bolsillo.fbx…), mismas
medidas (≈ 1,4 studs) y el frente mirando a −Y, así que el juego los usa sin
tocar código (AssetLibrary acepta Models).

Requisito: haber generado antes los mapas con materiales_pbr.py.

Uso (desde la raíz del repositorio):
    macOS:   /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup \
                 --python art/blender/scripts/relojes_detallados.py [-- mdl_reloj_bolsillo ...]
    Windows: "C:\\Program Files\\Blender Foundation\\Blender 5.3\\blender.exe" --background --factory-startup ^
                 --python art/blender/scripts/relojes_detallados.py
Después, vista_previa.py renderiza estos .blend con EEVEE (ven los materiales).
"""

import math
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(__file__))
import arte_comun as A  # noqa: E402

FRENTE = (math.pi / 2, 0, 0)  # gira discos para que su cara mire a −Y
TEXTURAS = os.path.join(A.ART, "texturas", "export")
LIMITE_TRIANGULOS = 3000

# Profundidades (Y) de cada capa del frente del reloj, de atrás hacia delante
Y_ESFERA, Y_INDICES, Y_AGUJAS, Y_CRISTAL = -0.135, -0.15, -0.165, -0.19


# ---------------------------------------------------------------------------
# Materiales
# ---------------------------------------------------------------------------

def material_pbr(nombre):
    """Material de Blender con los 4 mapas PBR de art/texturas/export (rutas relativas al .blend)."""
    material = bpy.data.materials.get(nombre)
    if material:
        return material
    material = bpy.data.materials.new(nombre)
    material.use_nodes = True
    arbol = material.node_tree
    bsdf = arbol.nodes.get("Principled BSDF")

    def textura(sufijo, no_color):
        ruta = os.path.join(TEXTURAS, f"tex_{nombre}_{sufijo}.png")
        if not os.path.isfile(ruta):
            raise SystemExit(f"Falta {ruta}: ejecuta antes materiales_pbr.py")
        nodo = arbol.nodes.new("ShaderNodeTexImage")
        nodo.image = bpy.data.images.load(ruta, check_existing=True)
        # Ruta relativa a art/blender/fuentes/ para que el .blend funcione en cualquier equipo
        nodo.image.filepath = "//../../texturas/export/" + os.path.basename(ruta)
        if no_color:
            nodo.image.colorspace_settings.name = "Non-Color"
        return nodo

    arbol.links.new(textura("color", False).outputs["Color"], bsdf.inputs["Base Color"])
    arbol.links.new(textura("rugosidad", True).outputs["Color"], bsdf.inputs["Roughness"])
    arbol.links.new(textura("metalico", True).outputs["Color"], bsdf.inputs["Metallic"])
    mapa_normal = arbol.nodes.new("ShaderNodeNormalMap")
    arbol.links.new(textura("normal", True).outputs["Color"], mapa_normal.inputs["Color"])
    arbol.links.new(mapa_normal.outputs["Normal"], bsdf.inputs["Normal"])
    if nombre.startswith("cristal"):  # en el render se ve a través; en Roblox: Transparency del MeshPart
        bsdf.inputs["Alpha"].default_value = 0.06
        material.surface_render_method = "BLENDED"
    return material


# ---------------------------------------------------------------------------
# Piezas (cada una devuelve (objeto, material))
# ---------------------------------------------------------------------------

def disco(nombre, radio, grosor, y, z, mat, lados=32):
    return A.cilindro(nombre, radio, grosor, (0, y, z), "gris", lados=lados, rot=FRENTE), mat


def aro(nombre, radio, grosor, y, z, mat, lados=32):
    return A.anillo(nombre, radio, grosor, (0, y, z), "gris", lados=lados, rot=FRENTE), mat


def barra(nombre, ancho, alto, pos, angulo, mat, fondo=0.012):
    """Caja fina en el plano del frente (XZ), girada «angulo» radianes alrededor de Y."""
    objeto = A.caja(nombre, (ancho, fondo, alto), (0, 0, 0), "gris")
    objeto.rotation_euler = (0, angulo, 0)
    objeto.location = pos
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action="DESELECT")
    objeto.select_set(True)
    bpy.context.view_layer.objects.active = objeto
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    return objeto, mat


def gema(nombre, radio, pos, mat):
    """Talla brillante low-poly: corona (tabla) hacia −Y y pabellón en punta hacia atrás."""
    x, y, z = pos
    corona = A.cono(nombre + "_corona", radio, radio * 0.6, radio * 0.45, (x, y - radio * 0.22, z), "gris", lados=8,
                    rot=(-math.pi / 2, 0, 0))
    pabellon = A.cono(nombre + "_pabellon", radio, 0, radio * 0.8, (x, y + radio * 0.4, z), "gris", lados=8,
                      rot=(math.pi / 2, 0, 0))
    return [(corona, mat), (pabellon, mat)]


# Números romanos con trazos: I = palo; V y X = dos palos inclinados
ROMANOS = ["XII", "I", "II", "III", "IIII", "V", "VI", "VII", "VIII", "IX", "X", "XI"]


def numeral(texto, centro_x, centro_z, angulo, alto, mat):
    """Dibuja un número romano orientado hacia el centro de la esfera."""
    piezas, grosor, ancho_letra = [], alto * 0.16, alto * 0.42
    total = len(texto) * ancho_letra
    for i, letra in enumerate(texto):
        dx = -total / 2 + ancho_letra * (i + 0.5)
        # posición local (dx, 0) girada con el número
        px = centro_x + dx * math.cos(angulo)
        pz = centro_z - dx * math.sin(angulo)
        if letra == "I":
            piezas.append(barra("rom_I", grosor, alto, (px, Y_INDICES, pz), angulo, mat))
        else:
            inclinacion = 0.38 if letra == "V" else 0.5
            for signo in (-1, 1):
                if letra == "V":
                    ox, oz = signo * ancho_letra * 0.2, 0
                else:
                    ox, oz = 0, 0
                qx = px + ox * math.cos(angulo)
                qz = pz - ox * math.sin(angulo)
                piezas.append(barra("rom_" + letra, grosor, alto * (1.02 if letra == "V" else 1.1),
                                    (qx, Y_INDICES, qz), angulo + signo * inclinacion, mat))
    return piezas


def esfera_reloj(radio, z, caja, esfera, marcas, agujas, romanos=False, bisel=None, lados=32):
    """Caja redonda, bisel, esfera, índices (o romanos), agujas y cristal, mirando a −Y."""
    p = [
        disco("caja", radio, 0.25, 0, z, caja, lados),
        disco("tapa", radio * 0.9, 0.04, 0.14, z, caja, lados),
        aro("bisel", radio * 0.93, 0.05, -0.12, z, bisel or caja, lados),
        disco("esfera", radio * 0.86, 0.02, Y_ESFERA, z, esfera, lados),
        disco("cristal", radio * 0.88, 0.02, Y_CRISTAL, z, "cristal_zafiro", lados),
        disco("eje", 0.035, 0.04, Y_AGUJAS - 0.01, z, agujas, 10),
    ]
    r_marcas = radio * 0.68
    for h in range(12):
        angulo = 2 * math.pi * h / 12  # 0 = las 12, sentido horario visto desde el frente (−Y)
        mx, mz = math.sin(angulo) * r_marcas, z + math.cos(angulo) * r_marcas
        if romanos:
            p += numeral(ROMANOS[h], mx, mz, -angulo, radio * 0.16, marcas)
        else:
            largo = radio * (0.16 if h % 3 == 0 else 0.1)
            p.append(barra("indice", radio * 0.04, largo, (mx, Y_INDICES, mz), -angulo, marcas))
    # Agujas a las 10:10 (pose clásica de escaparate)
    for nombre, largo, ancho, horas in (("aguja_h", 0.5, 0.06, 10 + 10 / 60), ("aguja_m", 0.72, 0.045, 2)):
        angulo = 2 * math.pi * horas / 12
        largo *= radio
        centro = (math.sin(angulo) * largo * 0.4, Y_AGUJAS, z + math.cos(angulo) * largo * 0.4)
        p.append(barra(nombre, radio * ancho, largo, centro, -angulo, agujas, fondo=0.015))
    angulo = 2 * math.pi * 7 / 12
    largo = radio * 0.8
    p.append(barra("aguja_s", radio * 0.015, largo, (math.sin(angulo) * largo * 0.35, Y_AGUJAS - 0.005,
                                                     z + math.cos(angulo) * largo * 0.35), -angulo, agujas, fondo=0.01))
    return p


def corona(z_tope, radio, mat, lados=12):
    return [
        (A.cilindro("tija", radio * 0.45, 0.1, (0, 0, z_tope + 0.05), "gris", lados=8), mat),
        (A.cilindro("corona", radio, 0.14, (0, 0, z_tope + 0.15), "gris", lados=lados), mat),
    ]


def biselar(objeto, ancho=0.03, segmentos=2):
    bpy.ops.object.select_all(action="DESELECT")
    objeto.select_set(True)
    bpy.context.view_layer.objects.active = objeto
    modificador = objeto.modifiers.new("bisel", "BEVEL")
    modificador.width = ancho
    modificador.segments = segmentos
    bpy.ops.object.modifier_apply(modifier=modificador.name)
    return objeto


# ---------------------------------------------------------------------------
# Los 6 relojes (diseños ficticios, sin marcas reales)
# ---------------------------------------------------------------------------

def reloj_bolsillo():
    p = esfera_reloj(0.55, 0.65, "metal_oro_pulido", "esmalte_blanco", "esmalte_negro", "esmalte_azul", romanos=True,
                     bisel="metal_oro_cepillado")
    p += corona(1.2, 0.1, "metal_oro_pulido")
    p.append(aro("aro", 0.16, 0.035, 0, 1.55, "metal_oro_pulido", 16))
    return p


def reloj_pulsera():
    z = 0.7
    caja = biselar(A.caja("caja", (0.8, 0.25, 0.8), (0, 0, z), "gris"), 0.06, 3)
    p = [
        (caja, "metal_acero"),
        (biselar(A.caja("esfera", (0.64, 0.02, 0.64), (0, Y_ESFERA, z), "gris"), 0.02, 2), "esmalte_azul"),
        (biselar(A.caja("cristal", (0.68, 0.02, 0.68), (0, Y_CRISTAL, z), "gris"), 0.02, 2), "cristal_zafiro"),
        disco("eje", 0.03, 0.04, Y_AGUJAS - 0.01, z, "metal_acero", 10),
    ]
    for h in range(12):
        angulo = 2 * math.pi * h / 12
        r = 0.25 / max(abs(math.sin(angulo)), abs(math.cos(angulo)))  # índices sobre un cuadrado
        p.append(barra("indice", 0.025, 0.07 if h % 3 else 0.1, (math.sin(angulo) * r, Y_INDICES, z + math.cos(angulo) * r),
                       -angulo, "metal_acero"))
    for nombre, largo, horas in (("aguja_h", 0.2, 10 + 10 / 60), ("aguja_m", 0.28, 2)):
        angulo = 2 * math.pi * horas / 12
        p.append(barra(nombre, 0.03, largo, (math.sin(angulo) * largo * 0.4, Y_AGUJAS, z + math.cos(angulo) * largo * 0.4),
                       -angulo, "metal_acero", fondo=0.015))
    # Correa de cuero con costura lisa y hebilla de acero
    for nombre, zc in (("correa_arriba", 1.35), ("correa_abajo", 0.05)):
        p.append((biselar(A.caja(nombre, (0.5, 0.18, 0.55), (0, 0.03, zc), "gris"), 0.04, 2), "cuero_correa"))
    p.append((biselar(A.caja("hebilla", (0.56, 0.06, 0.08), (0, -0.03, -0.12), "gris"), 0.02, 1), "metal_acero"))
    for dx in (-0.36, 0.36):  # asas que unen la caja con la correa
        p.append((A.caja("asa", (0.08, 0.16, 0.18), (dx, 0, z + 0.45), "gris"), "metal_acero"))
        p.append((A.caja("asa", (0.08, 0.16, 0.18), (dx, 0, z - 0.45), "gris"), "metal_acero"))
    # La corona va al lado, a las 3 (eje X)
    p.append((A.cilindro("corona", 0.07, 0.14, (0.47, 0, z), "gris", lados=12, rot=(0, math.pi / 2, 0)), "metal_acero"))
    return p


def reloj_cronografo():
    z, r = 0.7, 0.6
    p = esfera_reloj(r, z, "metal_acero", "esmalte_azul", "metal_acero", "metal_acero", bisel="esmalte_negro")
    for dx, dz in ((-0.24, 0.0), (0.24, 0.0), (0, -0.27)):
        p.append(disco("subesfera", 0.11, 0.02, Y_ESFERA - 0.008, z + dz, "esmalte_blanco", 20))
        p.append(barra("aguja_sub", 0.015, 0.09, (dx, Y_INDICES - 0.004, z + dz + 0.035), 0.6, "esmalte_negro"))
        p[-2][0].location.x += dx
    for dx in (-0.33, 0.33):
        p.append((A.cilindro("pulsador", 0.05, 0.14, (dx, 0, z + 0.62), "gris", lados=10), "metal_acero"))
    p += corona(z + r - 0.02, 0.1, "metal_acero")
    return p


def reloj_legado():
    z, r = 0.7, 0.6
    p = esfera_reloj(r, z, "metal_oro_pulido", "esmalte_blanco", "esmalte_negro", "esmalte_azul", romanos=True,
                     bisel="metal_oro_cepillado")
    for i in range(4):
        angulo = math.pi / 2 * i + math.pi / 4
        p += gema("zafiro", 0.06, (math.sin(angulo) * r * 0.93, -0.17, z + math.cos(angulo) * r * 0.93), "gema_zafiro")
    p += corona(z + r - 0.02, 0.1, "metal_oro_pulido")
    p += gema("zafiro_corona", 0.05, (0, -0.07, z + r + 0.15), "gema_zafiro")
    return p


def reloj_real():
    z, r = 0.7, 0.6
    p = esfera_reloj(r, z, "metal_oro_pulido", "metal_oro_cepillado", "metal_oro_pulido", "esmalte_negro",
                     bisel="metal_oro_pulido")
    indices = [x for x in p if x[0].name.split(".")[0] == "indice"]  # los rubíes hacen de índices
    p = [x for x in p if x not in indices]
    for objeto, _ in indices:
        bpy.data.objects.remove(objeto, do_unlink=True)
    for h in range(12):
        angulo = 2 * math.pi * h / 12
        p += gema("rubi", 0.055 if h % 3 else 0.075, (math.sin(angulo) * r * 0.68, Y_INDICES, z + math.cos(angulo) * r * 0.68),
                  "gema_rubi")
    p.append((A.cono("corona_real", 0.18, 0.08, 0.2, (0, 0, z + r + 0.12), "gris", lados=8), "metal_oro_pulido"))
    for i in range(5):  # puntas de la corona real con un rubí cada una
        angulo = 2 * math.pi * i / 5
        p += gema("rubi_corona", 0.035, (math.cos(angulo) * 0.12, math.sin(angulo) * 0.12, z + r + 0.26), "gema_rubi")
    return p


def reloj_millonario():
    z, r = 0.75, 0.65
    p = esfera_reloj(r, z, "metal_oro_pulido", "esmalte_negro", "gema_diamante", "metal_oro_pulido",
                     bisel="metal_oro_pulido")
    for i in range(24):
        angulo = 2 * math.pi * i / 24
        p += gema("diamante", 0.045, (math.sin(angulo) * r * 0.93, -0.16, z + math.cos(angulo) * r * 0.93), "gema_diamante")
    p += corona(z + r - 0.02, 0.12, "metal_oro_pulido")
    p += gema("diamante_corona", 0.06, (0, -0.09, z + r + 0.15), "gema_diamante")
    return p


RELOJES = {
    "mdl_reloj_bolsillo": reloj_bolsillo,
    "mdl_reloj_pulsera": reloj_pulsera,
    "mdl_reloj_cronografo": reloj_cronografo,
    "mdl_reloj_legado": reloj_legado,
    "mdl_reloj_real": reloj_real,
    "mdl_reloj_millonario": reloj_millonario,
}


# ---------------------------------------------------------------------------
# Unir por material, UV, exportar
# ---------------------------------------------------------------------------

def unir_por_material(piezas):
    """Une las piezas de cada material en una malla con el nombre del material y su UV (Smart UV Project)."""
    bpy.context.view_layer.update()
    grupos = {}
    for objeto, mat in piezas:
        grupos.setdefault(mat, []).append(objeto)
    mallas = []
    for mat, objetos in sorted(grupos.items()):
        malla = A.unir(mat, objetos)
        malla.data.name = mat
        malla.data.materials.clear()
        malla.data.materials.append(material_pbr(mat))
        for poligono in malla.data.polygons:
            poligono.use_smooth = False  # se mantiene el sombreado plano del estilo low-poly
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
        bpy.ops.object.mode_set(mode="OBJECT")
        mallas.append(malla)
    return mallas


def exportar(nombre, mallas):
    os.makedirs(A.EXPORT_MODELOS, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for malla in mallas:
        malla.select_set(True)
    bpy.context.view_layer.objects.active = mallas[0]
    ruta = os.path.join(A.EXPORT_MODELOS, nombre + ".fbx")
    bpy.ops.export_scene.fbx(filepath=ruta, use_selection=True, apply_unit_scale=True, global_scale=1.0,
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="STRIP",
                             bake_anim=False)
    bpy.context.scene["render_pbr"] = True  # vista_previa.py usará EEVEE para este modelo
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(A.FUENTES_BLEND, nombre + ".blend"))
    return ruta


def main():
    pedidos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else list(RELOJES)
    resultados = []
    for nombre in pedidos:
        A.limpiar_escena()
        mallas = unir_por_material(RELOJES[nombre]())
        # Quita el material de paleta que añaden los ayudantes de arte_comun
        for material in list(bpy.data.materials):
            if material.users == 0:
                bpy.data.materials.remove(material)
        for imagen in list(bpy.data.images):
            if imagen.users == 0:
                bpy.data.images.remove(imagen)
        ruta = exportar(nombre, mallas)
        total = sum(A.triangulos(m) for m in mallas)
        resultados.append((nombre, total, [(m.name, A.triangulos(m)) for m in mallas], ruta))
    print("=== Relojes detallados ===")
    for nombre, total, partes, ruta in resultados:
        aviso = "" if total <= LIMITE_TRIANGULOS else f"  ⚠️ supera {LIMITE_TRIANGULOS}"
        print(f"{nombre}: {total} triángulos{aviso} -> {os.path.relpath(ruta, A.REPO)}")
        print("    " + ", ".join(f"{n} ({t})" for n, t in partes))


if __name__ == "__main__":  # piezas_detalladas.py importa este módulo para reutilizar sus funciones (ART-009)
    main()
