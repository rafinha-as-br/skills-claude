#!/usr/bin/env bash
# Anexa (ou substitui) um arquivo numa página do Confluence.
# Uso: anexar-print.sh <pageId> <arquivo> [<arquivo>...]
# Requer JIRA_API_EMAIL e JIRA_API_TOKEN. ATLASSIAN_SITE sobrescreve o site padrão.
set -euo pipefail

site="${ATLASSIAN_SITE:-rafinha84dev.atlassian.net}"
: "${JIRA_API_EMAIL:?defina JIRA_API_EMAIL}"
: "${JIRA_API_TOKEN:?defina JIRA_API_TOKEN}"
[ $# -ge 2 ] || { echo "uso: $0 <pageId> <arquivo> [<arquivo>...]" >&2; exit 2; }

page="$1"; shift
for f in "$@"; do
  [ -f "$f" ] || { echo "arquivo não encontrado: $f" >&2; exit 1; }
  # curl mingw64 do Git Bash no Windows exige caminho Windows (curl: (26) com /c/...)
  path="$f"; command -v cygpath >/dev/null && path="$(cygpath -m "$f")"
  # PUT cria ou substitui pelo nome — POST falha quando o nome já existe na página
  code=$(curl -s -o /dev/null -w '%{http_code}' -u "$JIRA_API_EMAIL:$JIRA_API_TOKEN" \
    -X PUT -H "X-Atlassian-Token: no-check" -F "file=@${path}" \
    "https://${site}/wiki/rest/api/content/${page}/child/attachment")
  [ "$code" = 200 ] || { echo "falhou ($code): $f" >&2; exit 1; }
  echo "anexado: $(basename "$f")"
done
