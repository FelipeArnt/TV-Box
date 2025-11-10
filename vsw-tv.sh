#!/usr/bin/env sh

set -e

echo '==== VSW ===='
echo '==== TV-BOX ===='

read -p "Digite o protocolo da amostra: " protocolo_tvbox
read -p "Digite o orçamento da amostra: " orcamento_tvbox

echo "Protocolo TV-Box: $protocolo_tvbox"
echo "Orçamento TV-Box: $orcamento_tvbox"

# Listar dispositivos
adb devices
adb shell netstat -tulnp 2>/dev/null

# Listar pacotes
adb shell pm list packages -s -e -f >total_aplicativos.md
adb shell pm list packages -3 >terceiros_aplicativos.md
#mv total_aplicativos.md terceiros_aplicativos.md $APP_DIR

#Lista as propriedades do sistema
adb shell getprop ro.product.model >Propriedades_Sistema.md
adb shell getprop ro.build.version.release >>Propriedades_Sistema.md
adb shell getprop ro.build.display.id >>Propriedades_Sistema.md
adb shell getprop ro.kernel.version >>Propriedades_Sistema.md

# Informações de estado
adb shell dumpsys package >dumpsysPkg.md
adb shell dumpsys cpuinfo >dumpsysCpu.md
adb shell dumpsys meminfo >dumpsysMem.md
#mv dumpsysCpu.md dumpsysPkg.md dumpsysMem.md $DUMP_DIR

# Rede/conexões
adb shell dumpsys connectivity >dumpsysConnectivity.md
adb shell dumpsys wifi >dumpsysWifi.md
adb shell dumpsys telephony.registry >dumpsysTelephony.md

echo '[INFO]: Script finalizado com sucesso...'
