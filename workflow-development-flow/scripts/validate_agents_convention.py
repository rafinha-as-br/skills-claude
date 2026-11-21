#!/usr/bin/env python3
"""Valida a descoberta hierárquica definida em references/agents-md.md.

Uso: python validate_agents_convention.py <workspace> <caminho-afetado> [...]
Sem argumentos, executa cenários controlados temporários em tests/ e os remove.
"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path


def applicable_agents(workspace: Path, target: Path) -> list[Path]:
    workspace = workspace.resolve()
    target = target.resolve()
    if target != workspace and workspace not in target.parents:
        raise ValueError(f"alvo fora do workspace: {target}")
    current = target if target.is_dir() else target.parent
    chain: list[Path] = []
    while True:
        candidate = current / "AGENTS.md"
        if candidate.is_file():
            chain.append(candidate.relative_to(workspace))
        if current == workspace:
            return list(reversed(chain))
        current = current.parent


def self_test() -> int:
    fixture_parent = Path(__file__).resolve().parents[1] / "tests"
    with tempfile.TemporaryDirectory(dir=fixture_parent) as temporary:
        root = Path(temporary)
        for relative in ("AGENTS.md", "repo-a/AGENTS.md", "repo-a/lib/auth/AGENTS.md"):
            path = root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("# fixture\n", encoding="utf-8")
        target = root / "repo-a/lib/auth/token.py"
        target.write_text("", encoding="utf-8")
        expected = [Path("AGENTS.md"), Path("repo-a/AGENTS.md"), Path("repo-a/lib/auth/AGENTS.md")]
        observed = applicable_agents(root, target)
        if observed != expected:
            print(f"FALHOU: esperado {expected}; obtido {observed}")
            return 1
        absent = root / "repo-b/lib/empty.py"
        absent.parent.mkdir(parents=True)
        absent.write_text("", encoding="utf-8")
        if applicable_agents(root, absent) != [Path("AGENTS.md")]:
            print("FALHOU: ausência opcional não foi tratada")
            return 1
    print("OK: monorepo, multi-repo hierárquico e ausência opcional")
    return 0


def main(arguments: list[str]) -> int:
    if not arguments:
        return self_test()
    if len(arguments) < 2:
        print("uso: validate_agents_convention.py <workspace> <caminho-afetado> [...]")
        return 2
    workspace = Path(arguments[0])
    for raw_target in arguments[1:]:
        files = applicable_agents(workspace, Path(raw_target))
        print(f"{raw_target}: {', '.join(map(str, files)) or '(nenhum)'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
