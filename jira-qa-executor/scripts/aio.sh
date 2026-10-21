#!/usr/bin/env bash
# Chamada à API REST do AIO Tests sem expor o token.
# Uso:  aio.sh <METODO> <caminho> [<json-inline> | @arquivo.json]       corpo JSON
#       aio.sh <METODO> <caminho> -F campo=@arquivo [-F ...]            multipart (anexos)
# Lê AIO_TESTS_ACCESS_TOKEN do ambiente; AIO_BASE sobrescreve a URL base.
# O token vai para um arquivo temporário (curl -K): não aparece em argumento de processo,
# em log nem na saída. Corpo da resposta -> stdout; HTTP != 2xx -> exit 1 com o código em stderr.
set -euo pipefail
: "${AIO_TESTS_ACCESS_TOKEN:?defina AIO_TESTS_ACCESS_TOKEN no ambiente (nunca peça o token no chat)}"
[ $# -ge 2 ] || { echo "uso: $0 <METODO> <caminho> [json|@arquivo.json | -F campo=@arquivo ...]" >&2; exit 2; }
base="${AIO_BASE:-https://tcms.aiojiraapps.com/aio-tcms/api/v1}"
method="$1"; path="$2"; shift 2

cfg=$(mktemp); out=$(mktemp); trap 'rm -f "$cfg" "$out"' EXIT
chmod 600 "$cfg"
printf 'header = "Authorization: AioAuth %s"\n' "$AIO_TESTS_ACCESS_TOKEN" > "$cfg"

# curl mingw64 do Git Bash no Windows exige caminho Windows (curl: (26) com /c/...)
winpath() { if command -v cygpath >/dev/null; then cygpath -m "$1"; else printf '%s' "$1"; fi; }

args=()
if [ "${1:-}" = "-F" ]; then
  while [ $# -gt 0 ]; do
    [ "$1" = "-F" ] && [ $# -ge 2 ] || { echo "multipart: esperado -F campo=@arquivo" >&2; exit 2; }
    field="${2%%=*}"; val="${2#*=}"
    case "$val" in @*) val="@$(winpath "${val#@}")";; esac
    args+=(-F "$field=$val"); shift 2
  done
elif [ $# -ge 1 ]; then
  body="$1"
  case "$body" in @*) body="@$(winpath "${body#@}")";; esac
  args+=(-H "Content-Type: application/json" --data-binary "$body")
fi

code=$(curl -sS -o "$out" -w '%{http_code}' -K "$cfg" -X "$method" "${args[@]}" "$base/${path#/}") \
  || { echo "falha de rede/curl (sem detalhes sensíveis acima)" >&2; exit 1; }
cat "$out"; echo
[ "${code:0:1}" = 2 ] || { echo "HTTP $code" >&2; exit 1; }
