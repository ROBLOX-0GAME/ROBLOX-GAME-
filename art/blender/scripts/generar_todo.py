"""
generar_todo.py — genera todos los assets low-poly base (ART-001, ART-002 y ART-003).

    "C:\\Program Files\\Blender Foundation\\Blender 5.3\\blender.exe" --background --factory-startup ^
        --python art/blender/scripts/generar_todo.py

Cada modelo usa las medidas (en studs) de la pieza provisional que sustituirá en
el juego, para que encaje sin tocar el código. Al final imprime el conteo de
triángulos de cada uno.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

import arte_comun as A  # noqa: E402
import modelos_prioridad1 as P1  # noqa: E402
import modelos_prioridad2 as P2  # noqa: E402


def caminadora():
    """Sustituye a la pieza «Caminadora» del plot (5 × 8 × 1 studs)."""
    piezas = [
        A.caja("base", (5, 8, 0.6), (0, 0, 0.3), "gris_oscuro"),
        A.caja("cinta", (4, 7.2, 0.15), (0, 0, 0.67), "negro"),
        A.cilindro("rodillo_delante", 0.35, 4.2, (0, 3.6, 0.45), "gris", lados=8, rot=(0, 1.5708, 0)),
        A.cilindro("rodillo_detras", 0.35, 4.2, (0, -3.6, 0.45), "gris", lados=8, rot=(0, 1.5708, 0)),
        A.caja("poste_izq", (0.3, 0.3, 3.2), (-2.2, 3.4, 2.2), "gris"),
        A.caja("poste_der", (0.3, 0.3, 3.2), (2.2, 3.4, 2.2), "gris"),
        A.caja("baranda_izq", (0.25, 3.5, 0.25), (-2.2, 1.8, 3.6), "azul"),
        A.caja("baranda_der", (0.25, 3.5, 0.25), (2.2, 1.8, 3.6), "azul"),
        A.caja("consola", (4.6, 0.6, 1.2), (0, 3.55, 3.9), "azul_oscuro"),
        A.caja("pantalla", (2.2, 0.08, 0.7), (0, 3.22, 3.95), "cian"),
    ]
    return A.unir("mdl_caminadora", piezas)


def capsula(nombre, color):
    """Cápsula de mascota (≈ 2 × 2 × 3 studs): dos mitades y un anillo."""
    piezas = [
        A.esfera("arriba", 1, (0, 0, 1.9), color, segmentos=12, anillos=6, escala=(1, 1, 1.15)),
        A.esfera("abajo", 1, (0, 0, 1.1), "blanco", segmentos=12, anillos=6, escala=(1, 1, 1.0)),
        A.cilindro("anillo", 1.05, 0.25, (0, 0, 1.5), "dorado", lados=12),
        A.cilindro("pie", 0.7, 0.3, (0, 0, 0.15), "gris_oscuro", lados=12),
    ]
    return A.unir(nombre, piezas)


MODELOS = {
    "mdl_caminadora": caminadora,
    "mdl_capsula_laton": lambda: capsula("mdl_capsula_laton", "bronce"),
}
MODELOS.update(P1.MODELOS)
MODELOS.update(P2.MODELOS)


def main():
    # Opcional: generar solo algunos → ... --python generar_todo.py -- mdl_taller mdl_vitrina
    pedidos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else list(MODELOS)
    resultados = []
    for nombre in pedidos:
        A.limpiar_escena()
        A.crear_paleta()
        objeto = MODELOS[nombre]()
        ruta, tris = A.exportar(objeto, nombre)
        resultados.append((nombre, tris, ruta))
    print("=== Assets generados ===")
    for nombre, tris, ruta in resultados:
        print(f"{nombre}: {tris} triángulos -> {os.path.relpath(ruta, A.REPO)}")
    print(f"paleta -> {os.path.relpath(A.PALETA_PNG, A.REPO)}")


main()
