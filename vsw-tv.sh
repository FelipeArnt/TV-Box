#!/usr/bin/env bash
# |----|LABELO/VSW|----|@author:FelipeArnt|----|
# vsw-tv-box.sh – Script para Ensaios Funcionais em Android-TV via ADB
# Uso: ./vsw-tv-box.sh [-h] [-c]

set -euo pipefail 

# Configurações
VERSION="1.0.0"
OUTPUT_DIR="coleta_tvbox"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${OUTPUT_DIR}/${TIMESTAMP}_exec.log"

# Auxiliares
die(){ echo "[ERRO] $*" | tee -a "$LOGFILE"; exit 1; }
log(){ echo "[INFO] $*" | tee -a "$LOGFILE"; }

usage(){
  cat <<EOF
Uso: $0 [-h] [-c]

  -h  Mostra esta ajuda
  -c  Limpa coletas anteriores (${OUTPUT_DIR}) antes de rodar
EOF
  exit 0
}

# Validações
while getopts "hc" opt; do
  case $opt in
    h) usage ;;
    c) rm -rf "$OUTPUT_DIR" ;;
    *) usage ;;
  esac
done

command -v adb >/dev/null 2>&1 || die "ADB não encontrado. Instale o Android SDK Platform-Tools."

mkdir -p "$OUTPUT_DIR" || die "Não consegui criar ${OUTPUT_DIR}"

# Entradas
read -rp "Digite o protocolo da amostra: " PROTOCOLO
[[ -z "$PROTOCOLO" ]] && die "Protocolo não pode ser vazio."
read -rp "Digite o orçamento da amostra: " ORCAMENTO
[[ -z "$ORCAMENTO" ]] && die "Orçamento não pode ser vazio."

PREFIX="${TIMESTAMP}_${PROTOCOLO// /_}"


# Dispositivo
log "Verificando dispositivo ADB..."
adb wait-for-device || die "Nenhum dispositivo detectado. Verifique o cabo/USB-debug."
SERIAL=$(adb get-serialno)
log "Dispositivo detectado: ${SERIAL}"

# Coleta
log "Iniciando coleta..."

# 1) Pacotes
adb shell pm list packages -s -e -f > "${OUTPUT_DIR}/${PREFIX}_pkgs_sistema.txt"
adb shell pm list packages   -3      > "${OUTPUT_DIR}/${PREFIX}_pkgs_terceiros.txt"

# 2) Propriedades
{
  echo "# Propriedades do sistema"
  adb shell getprop
} > "${OUTPUT_DIR}/${PREFIX}_getprop.txt"

# 3) Dumpsys
for svc in package cpuinfo meminfo connectivity wifi telephony.registry; do
  adb shell dumpsys "$svc" > "${OUTPUT_DIR}/${PREFIX}_dumpsys_${svc}.txt"
done

# 4) Rede
adb shell netstat -tulpn > "${OUTPUT_DIR}/${PREFIX}_netstat.txt" 2>&1 || true

# 5) Resumo
cat <<EOF > "${OUTPUT_DIR}/${PREFIX}_resumo.json"
{
  "protocolo": "$PROTOCOLO",
  "orcamento": "$ORCAMENTO",
  "serial": "$SERIAL",
  "timestamp": "$TIMESTAMP",
  "android_versao": "$(adb shell getprop ro.build.version.release)",
  "modelo": "$(adb shell getprop ro.product.model)"
}
EOF

-------------
# Finalização
log "Coleta finalizada em ${OUTPUT_DIR}"
log "Arquivos salvos com prefixo: ${PREFIX}"
exit 0
