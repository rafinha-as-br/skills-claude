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


MAIN_MARKER = "<!-- rafinha-workflow-agents: v1 -->"
MAIN_SECTIONS = (
    "## 1. Identidade do projeto",
    "## 2. Infraestrutura Atlassian",
    "## 3. Arquitetura e repositórios",
    "## 4. Estratégias específicas do produto",
    "## 5. Fontes de verdade",
    "## 6. Orientações para agentes",
)
MAIN_FIELDS = (
    "**Nome oficial:**",
    "**Site Atlassian oficial:**",
    "**Projetos Jira:**",
    "**Espaços Confluence:**",
    "**Topologia:**",
    "**Regras e requisitos:**",
)


def validate_main_agents(path: Path) -> list[str]:
    """Retorna violações do esquema mínimo do AGENTS principal v1."""
    text = path.read_text(encoding="utf-8")
    problems: list[str] = []
    if MAIN_MARKER not in text:
        problems.append("marcador de esquema v1 ausente")
    positions = [text.find(section) for section in MAIN_SECTIONS]
    if any(position < 0 for position in positions):
        problems.append("seções obrigatórias ausentes")
    elif positions != sorted(positions):
        problems.append("seções obrigatórias fora da ordem")
    for field in MAIN_FIELDS:
        if field not in text:
            problems.append(f"campo obrigatório ausente: {field}")
    if "**Site Atlassian oficial:**" in text:
        after = text.split("**Site Atlassian oficial:**", 1)[1].splitlines()[0]
        if "https://" not in after or ".atlassian.net" not in after:
            problems.append("URL do site Atlassian inválida ou não declarada")
    return problems


def self_test() -> int:
    fixture_parent = Path(__file__).resolve().parents[1] / "tests"
    with tempfile.TemporaryDirectory(dir=fixture_parent) as temporary:
        root = Path(temporary)
        main_agents = """<!-- rafinha-workflow-agents: v1 -->
# Produto de teste
## 1. Identidade do projeto
- **Nome oficial:** Produto de teste
## 2. Infraestrutura Atlassian
- **Site Atlassian oficial:** https://teste.atlassian.net
- **Projetos Jira:**
- **Espaços Confluence:**
## 3. Arquitetura e repositórios
- **Topologia:** multi-repo
## 4. Estratégias específicas do produto
- Nenhuma
## 5. Fontes de verdade
- **Regras e requisitos:** Controle de workflow por produto
## 6. Orientações para agentes
- Não usar fallback entre sites.
"""
        for relative in ("AGENTS.md", "repo-a/AGENTS.md", "repo-a/lib/auth/AGENTS.md"):
            path = root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(main_agents if relative == "AGENTS.md" else "# fixture\n", encoding="utf-8")
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
        violations = validate_main_agents(root / "AGENTS.md")
        if violations:
            print(f"FALHOU: AGENTS principal válido rejeitado: {violations}")
            return 1
        (root / "invalido.md").write_text(main_agents.replace("https://teste.atlassian.net", "indefinido"), encoding="utf-8")
        if not validate_main_agents(root / "invalido.md"):
            print("FALHOU: site Atlassian ausente foi aceito")
            return 1
    print("OK: hierarquia, ausência opcional e esquema Atlassian do AGENTS principal")
    return 0


def main(arguments: list[str]) -> int:
    if not arguments:
        return self_test()
    if len(arguments) < 2:
        print("uso: validate_agents_convention.py <workspace> <caminho-afetado> [...]")
        return 2
    workspace = Path(arguments[0])
    main = workspace / "AGENTS.md"
    if main.is_file():
        problems = validate_main_agents(main)
        if problems:
            print(f"AGENTS principal inválido: {'; '.join(problems)}")
            return 1
    for raw_target in arguments[1:]:
        files = applicable_agents(workspace, Path(raw_target))
        print(f"{raw_target}: {', '.join(map(str, files)) or '(nenhum)'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
