#!/usr/bin/env python3
"""Cenários determinísticos da resolução Atlassian por produto.

Não acessa serviços Atlassian nem usa credenciais. Exercita apenas as regras:
site explícito, recurso explícito, conector no mesmo site e escrita autorizada.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Connector:
    site_url: str
    can_read: bool
    can_write: bool


def resolve_connector(
    site_url: str | None,
    resource_url: str | None,
    connectors: list[Connector],
    *,
    write: bool,
) -> Connector:
    if not site_url or not resource_url:
        raise ValueError("site ou recurso Atlassian não declarado")
    if not resource_url.startswith(site_url + "/"):
        raise ValueError("recurso não pertence ao site Atlassian declarado")
    matches = [connector for connector in connectors if connector.site_url == site_url]
    if not matches:
        raise ValueError("nenhum conector para o site declarado")
    connector = matches[0]
    if write and not connector.can_write:
        raise PermissionError("conector sem escrita no site declarado")
    if not write and not connector.can_read:
        raise PermissionError("conector sem leitura no site declarado")
    return connector


def expect_error(error: type[Exception], **arguments: object) -> None:
    try:
        resolve_connector(**arguments)
    except error:
        return
    raise AssertionError(f"esperava {error.__name__}")


def main() -> int:
    product_site = "https://produto.atlassian.net"
    other_site = "https://outro-produto.atlassian.net"
    resource = f"{product_site}/wiki/spaces/PROD"
    correct = Connector(product_site, can_read=True, can_write=True)
    readonly = Connector(product_site, can_read=True, can_write=False)
    wrong = Connector(other_site, can_read=True, can_write=True)

    assert resolve_connector(product_site, resource, [wrong, correct], write=True) == correct
    expect_error(ValueError, site_url=None, resource_url=resource, connectors=[correct], write=False)
    expect_error(ValueError, site_url=product_site, resource_url=None, connectors=[correct], write=False)
    expect_error(ValueError, site_url=product_site, resource_url=f"{other_site}/wiki/spaces/OUTRO", connectors=[correct], write=False)
    expect_error(ValueError, site_url=product_site, resource_url=resource, connectors=[wrong], write=False)
    expect_error(PermissionError, site_url=product_site, resource_url=resource, connectors=[readonly], write=True)
    print("OK: site explícito, conector correto, sem fallback e escrita negada")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
