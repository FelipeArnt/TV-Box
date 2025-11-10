#!/usr/bin/env sh
# LABELO / VSW – TV-BOX / ATO 9281 (ANATEL)
set -e

echo '==== VSW ===='
read -p "Protocolo: " protocolo_tvbox
read -p "Orçamento: " orcamento_tvbox

RELATORIO="relatorio_tvbox.md"
APPS_FILE="aplicativos_tvbox.md"

# ---------- relatório principal ----------
cat > "$RELATORIO" <<EOF
# Relatório TV-Box – ATO 9281
Protocolo: ${protocolo_tvbox}  
Orçamento: ${orcamento_tvbox}

> Consolidado para avaliação de conformidade.  
> Detalhes de apps em \`$APPS_FILE\`.

EOF

# ---------- aplicativos ----------
cat > "$APPS_FILE" <<EOF
# Apps TV-Box – ATO 9281
Protocolo: ${protocolo_tvbox}  
Orçamento: ${orcamento_tvbox}

## Apps do Sistema (habilitados)
\`\`\`
$(adb shell pm list packages -s -e | sed 's/package://')
\`\`\`

## Apps de Terceiros
\`\`\`
$(adb shell pm list packages -3 | sed 's/package://')
\`\`\`
EOF

# ---------- identificação do produto ----------
{
  echo "## Identificação do Produto"
  echo "- Modelo: $(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
  echo "- Android: $(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')"
  echo "- Build ID: $(adb shell getprop ro.build.display.id 2>/dev/null | tr -d '\r')"
  echo "- Kernel: $(adb shell uname -r 2>/dev/null | tr -d '\r')"
  echo
} >> "$RELATORIO"

# ---------- portas abertas (apenas LISTEN) ----------
{
  echo "## Portas/Serviços (LISTEN)"
  adb shell netstat -tul 2>/dev/null | grep LISTEN | awk '{print "- " $4}' | sort -u
  echo
} >> "$RELATORIO"

# ---------- root ----------
ROOT_ID=$(adb shell id 2>/dev/null | grep -q 'uid=0' && echo SIM || echo NÃO)
echo "## Root" >> "$RELATORIO"
echo "- Modo root detectado: **$ROOT_ID**" >> "$RELATORIO"
echo >> "$RELATORIO"

# ---------- fontes desconhecidas ----------
UNK=$(adb shell settings get secure install_non_market_apps 2>/dev/null || echo 0)
echo "## Instalação de Apps de Terceiros" >> "$RELATORIO"
echo "- Fontes desconhecidas: **$([ "$UNK" = 1 ] && echo HABILITADA || echo DESABILITADA)**" >> "$RELATORIO"
echo >> "$RELATORIO"

# ---------- check-list manual ----------
cat >> "$RELATORIO" <<EOF
## Itens para Análise Manual (§5.2.2)

1. **5.2.2.1** – Comparar apps da lista com lista de irregulares da Anatel.  
2. **5.2.2.2** – Identificar apps que possibilitem acesso ilícito a conteúdo audiovisual.  
3. **5.2.2.5** – Conferir portas/serviços acima com documentação do fabricante (§5.1.5).

EOF

echo "[INFO] Coleta essencial concluída – $RELATORIO | $APPS_FILE"
