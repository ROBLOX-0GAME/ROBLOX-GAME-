"""
build.py — revisión estática del código Luau de game/src y compilación local
de una place de Roblox (.rbxlx) sin necesidad de instalar Rojo.

El control oficial de GitHub es `rojo build` (Rojo 7.7.1, ver game/rokit.toml).
Este script es una ayuda local que además detecta errores comunes de Luau.

Uso (desde cualquier carpeta):
    python game/tools/build.py            # revisa y genera game/build/ROBLOX-GAME.rbxlx
    python game/tools/build.py --check    # solo revisa el código

Sigue las mismas reglas de nombres que Rojo (default.project.json):
    Nombre.server.luau -> Script
    Nombre.client.luau -> LocalScript
    Nombre.luau        -> ModuleScript
    carpeta            -> Folder

Revisiones estáticas (no sustituyen probar en Studio):
    1. Bloques balanceados (function/if/do/repeat frente a end/until).
    2. Cada require(...) apunta a un módulo que existe.
    3. Los campos usados de módulos propios (Config.X, PlayerLogic.Y, ...) existen.

Solo usa la biblioteca estándar de Python 3.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent.parent  # carpeta game/
PROJECT_FILE = ROOT / "default.project.json"
OUTPUT_FILE = ROOT / "build" / "ROBLOX-GAME.rbxlx"  # game/build/ está en .gitignore

SERVICE_CLASSES = {
    "ReplicatedStorage",
    "ServerScriptService",
    "StarterPlayer",
    "StarterPlayerScripts",
    "Workspace",
    "ServerStorage",
    "StarterGui",
}


# ---------------------------------------------------------------------------
# Árbol de instancias
# ---------------------------------------------------------------------------

class Node:
    def __init__(self, name, class_name, source=None, path=None):
        self.name = name
        self.class_name = class_name
        self.source = source
        self.path = path
        self.children = []
        self.parent = None

    def add(self, child):
        child.parent = self
        self.children.append(child)
        return child

    def child(self, name):
        for c in self.children:
            if c.name == name:
                return c
        return None

    def walk(self):
        yield self
        for c in self.children:
            yield from c.walk()


SCRIPT_SUFFIXES = ((".server.luau", "Script"), (".client.luau", "LocalScript"), (".luau", "ModuleScript"))


def node_from_fs(path, forced_name=None):
    if path.is_dir():
        node = Node(forced_name or path.name, "Folder", path=path)
        for entry in sorted(path.iterdir(), key=lambda p: p.name):
            if entry.name.startswith("."):
                continue
            child = node_from_fs(entry)
            if child:
                node.add(child)
        return node
    for suffix, class_name in SCRIPT_SUFFIXES:
        if path.name.endswith(suffix):
            name = forced_name or path.name[: -len(suffix)]
            return Node(name, class_name, source=path.read_text(encoding="utf-8"), path=path)
    return None


def build_tree():
    project = json.loads(PROJECT_FILE.read_text(encoding="utf-8"))

    def convert(name, spec):
        if "$path" in spec:
            node = node_from_fs(ROOT / spec["$path"], forced_name=name)
            # Un servicio con $path (p. ej. ReplicatedStorage) sigue siendo el servicio.
            if spec.get("$className") or name in SERVICE_CLASSES:
                node.class_name = spec.get("$className") or name
        else:
            class_name = spec.get("$className") or (name if name in SERVICE_CLASSES else "Folder")
            node = Node(name, class_name)
        for key, value in spec.items():
            if not key.startswith("$"):
                node.add(convert(key, value))
        return node

    return convert("DataModel", project["tree"])


def rel(node):
    return str(node.path.relative_to(ROOT)) if node.path else node.name


# ---------------------------------------------------------------------------
# Revisiones estáticas
# ---------------------------------------------------------------------------

LONG_OPEN = re.compile(r"\[(=*)\[")


UNCLOSED_STRINGS = []  # líneas con cadenas sin cerrar del último strip_code (DEV-015)


def strip_code(source):
    """Reemplaza comentarios y textos por espacios, conservando los saltos de línea."""
    out = []
    i, n = 0, len(source)

    def blank(text):
        return "".join("\n" if ch == "\n" else " " for ch in text)

    while i < n:
        ch = source[i]
        if source.startswith("--", i):
            m = LONG_OPEN.match(source, i + 2)
            if m:
                close = "]" + m.group(1) + "]"
                end = source.find(close, m.end())
                end = n if end == -1 else end + len(close)
            else:
                end = source.find("\n", i)
                end = n if end == -1 else end
            out.append(blank(source[i:end]))
            i = end
            continue
        m = LONG_OPEN.match(source, i) if ch == "[" else None
        if m:
            close = "]" + m.group(1) + "]"
            end = source.find(close, m.end())
            end = n if end == -1 else end + len(close)
            out.append('""' + blank(source[i + 2 : end - 2]) + "  ")
            i = end
            continue
        if ch in "\"'`":
            j = i + 1
            while j < n and source[j] != ch and source[j] != "\n":
                if source[j] == "\\":
                    j += 1
                j += 1
            if j >= n or source[j] == "\n":
                # Cadena sin cerrar en su línea: en Luau es «Malformed string» (DEV-015)
                UNCLOSED_STRINGS.append(source.count("\n", 0, i) + 1)
            out.append(ch + blank(source[i + 1 : j]) + ch)
            i = j + 1
            continue
        out.append(ch)
        i += 1
    return "".join(out)


KEYWORD_RE = re.compile(r"(?<![\w.:])(function|if|do|end|repeat|until)(?!\w)")


def check_blocks(node, code, errors):
    stack = []
    for m in KEYWORD_RE.finditer(code):
        word = m.group(1)
        line = code.count("\n", 0, m.start()) + 1
        if word in ("function", "if", "do", "repeat"):
            stack.append((word, line))
        elif word == "end":
            if not stack or stack[-1][0] == "repeat":
                errors.append(f"{rel(node)}:{line}: 'end' sin bloque que cerrar")
                return
            stack.pop()
        elif word == "until":
            if not stack or stack[-1][0] != "repeat":
                errors.append(f"{rel(node)}:{line}: 'until' sin 'repeat'")
                return
            stack.pop()
    for word, line in stack:
        errors.append(f"{rel(node)}:{line}: '{word}' sin cerrar")


LOCAL_DECL_RE = re.compile(r"^\s*local\s+function\s+(\w+)|^\s*local\s+(\w+)\s*=", re.M)


def check_use_before_local(node, code, errors):
    """Un local usado antes de declararse se resuelve como global (nil) en Luau."""
    seen = {}
    for m in LOCAL_DECL_RE.finditer(code):
        name = m.group(1) or m.group(2)
        line = code.count("\n", 0, m.start()) + 1
        seen.setdefault(name, line)
    for name, line in seen.items():
        prefix = "\n".join(code.split("\n")[: line - 1])
        if re.search(rf"(?<![\w.:]){re.escape(name)}\s*\(", prefix) and not re.search(
            rf"^\s*local\s+{re.escape(name)}\b|^\s*local\s+function\s+{re.escape(name)}\b|function\s+{re.escape(name)}\s*\(",
            prefix,
            re.M,
        ):
            errors.append(f"{rel(node)}:{line}: '{name}' se usa antes de declararse como local")


REQUIRE_RE = re.compile(r"require\(([^()]*(?:\([^()]*\)[^()]*)*)\)")
TOKEN_RE = re.compile(r'[.:]WaitForChild\("([^"]+)"[^)]*\)|\.(\w+)|^(\w+)')


def resolve(node, expr, aliases, tree):
    """Devuelve (instancia, reconocido)."""
    tokens = [a or b or c for a, b, c in TOKEN_RE.findall(expr.strip())]
    if not tokens:
        return None, False
    head, rest = tokens[0], tokens[1:]
    if head == "script":
        current = node
    elif head in aliases:
        current = aliases[head]
    elif head == "ReplicatedStorage":
        current = tree.child("ReplicatedStorage")
    else:
        return None, False
    for token in rest:
        if current is None:
            return None, True
        current = current.parent if token == "Parent" else current.child(token)
    return current, True


def module_fields(module):
    code = strip_code(module.source or "")
    name_match = re.search(r"^return\s+(\w+)\s*$", code, re.M)
    if not name_match:
        return set()
    var = name_match.group(1)
    fields = set(re.findall(rf"^\s*(?:function\s+)?{var}\.(\w+)", code, re.M))
    literal = re.search(rf"local\s+{var}\s*=\s*\{{(.*?)^\}}", code, re.S | re.M)
    if literal:
        fields |= set(re.findall(r"^\t(\w+)\s*=", literal.group(1), re.M))
    return fields


ALIAS_RE = re.compile(r"^\s*local\s+(\w+)\s*=\s*((?:script|ReplicatedStorage)[\w.:()\"]*)\s*$", re.M)


def check_requires_and_fields(tree, errors, warnings):
    count = 0
    for node in tree.walk():
        if node.source is None:
            continue
        code = strip_code(node.source)
        lines = node.source.splitlines()
        aliases = {}
        for var, expr in ALIAS_RE.findall(node.source):
            target, known = resolve(node, expr, aliases, tree)
            if known and target is not None and target.class_name == "Folder":
                aliases[var] = target
        for m in REQUIRE_RE.finditer(code):
            line = code.count("\n", 0, m.start()) + 1
            original = REQUIRE_RE.search(lines[line - 1])
            expr = original.group(1) if original else m.group(1)
            if expr.strip() == "child":
                continue
            target, known = resolve(node, expr, aliases, tree)
            if not known:
                warnings.append(f"{rel(node)}:{line}: require no verificado: {expr}")
                continue
            count += 1
            if target is None or target.class_name != "ModuleScript":
                errors.append(f"{rel(node)}:{line}: require apunta a un módulo inexistente: {expr}")
                continue
            var_match = re.match(r"\s*local\s+(\w+)\s*=\s*require", lines[line - 1])
            if not var_match:
                continue
            var = var_match.group(1)
            fields = module_fields(target)
            if not fields:
                continue
            for used in sorted(set(re.findall(rf"(?<![\w.]){var}\.(\w+)", code))):
                if used not in fields:
                    errors.append(f"{rel(node)}: {var}.{used} no existe en {rel(target)}")
    return count


# ---------------------------------------------------------------------------
# Escritura .rbxlx
# ---------------------------------------------------------------------------

def cdata(text):
    return "<![CDATA[" + text.replace("]]>", "]]]]><![CDATA[>") + "]]>"


def write_rbxlx(tree):
    counter = [0]
    out = [
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
        "\t<External>null</External>",
        "\t<External>nil</External>",
    ]

    def emit(node, depth):
        counter[0] += 1
        indent = "\t" * depth
        out.append(f'{indent}<Item class="{node.class_name}" referent="RBX{counter[0]:08X}">')
        out.append(f"{indent}\t<Properties>")
        out.append(f'{indent}\t\t<string name="Name">{escape(node.name)}</string>')
        if node.source is not None:
            out.append(f'{indent}\t\t<ProtectedString name="Source">{cdata(node.source)}</ProtectedString>')
        out.append(f"{indent}\t</Properties>")
        for child in node.children:
            emit(child, depth + 1)
        out.append(f"{indent}</Item>")

    for service in tree.children:
        emit(service, 1)
    out.append("</roblox>")
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text("\n".join(out) + "\n", encoding="utf-8")


def main():
    check_only = "--check" in sys.argv
    tree = build_tree()
    scripts = [n for n in tree.walk() if n.source is not None]
    errors, warnings = [], []
    for node in scripts:
        UNCLOSED_STRINGS.clear()
        code = strip_code(node.source)
        for line in UNCLOSED_STRINGS:
            errors.append(f"{rel(node)}:{line}: cadena sin cerrar (salto de línea dentro de comillas; usa \\n)")
        check_blocks(node, code, errors)
        check_use_before_local(node, code, errors)
    requires = check_requires_and_fields(tree, errors, warnings)

    print(f"Scripts encontrados: {len(scripts)}")
    for node in scripts:
        print(f"  {node.class_name:<12} {rel(node)}")
    print(f"require verificados: {requires}")
    for w in warnings:
        print("AVISO:", w)
    if errors:
        for e in errors:
            print("ERROR:", e)
        print(f"Revisión fallida: {len(errors)} error(es).")
        return 1
    print("Revisión estática: sin errores.")
    if not check_only:
        write_rbxlx(tree)
        print(f"Place generada: {OUTPUT_FILE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
