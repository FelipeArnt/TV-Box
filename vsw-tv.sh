#!/usr/bin/env sh

set -e

echo '==== VSW ===='
echo '==== TV-BOX ===='

read -p "Digite o protocolo da amostra: " protocolo_tvbox
read -p "Digite o orçamento da amostra: " orcamento_tvbox

# Definir os arquivos de relatório
RELATORIO="relatorio_tvbox.md"
APPS_FILE="aplicativos_tvbox.md"

# Iniciar o arquivo de relatório principal
echo "# Relatório TV-Box (ANATEL ATO 9281)" > "$RELATORIO"
echo "" >> "$RELATORIO"
echo "## Protocolo: $protocolo_tvbox" >> "$RELATORIO"
echo "## Orçamento: $orcamento_tvbox" >> "$RELATORIO"
echo "" >> "$RELATORIO"
echo "**Nota**: Este relatório consolida informações para avaliação de conformidade com o ATO 9281 da ANATEL. Detalhes de aplicativos estão em '$APPS_FILE'. Verificações de 5.2 estão na seção dedicada." >> "$RELATORIO"
echo "" >> "$RELATORIO"

# Iniciar o arquivo de aplicativos
echo "# Aplicativos TV-Box (Detalhamento para ATO 9281)" > "$APPS_FILE"
echo "" >> "$APPS_FILE"
echo "## Protocolo: $protocolo_tvbox" >> "$APPS_FILE"
echo "## Orçamento: $orcamento_tvbox" >> "$APPS_FILE"
echo "" >> "$APPS_FILE"

# Netstat (5.2.2.5)
echo "## Informações de Rede (Netstat)" >> "$RELATORIO"
adb shell netstat -tulnp 2>/dev/null >> "$RELATORIO"
echo "" >> "$RELATORIO"

# Aplicativos do Sistema (5.2.2.1/5.2.2.2)
echo "## Aplicativos do Sistema" >> "$APPS_FILE"
echo "| Caminho | Pacote |" >> "$APPS_FILE"
echo "|---------|--------|" >> "$APPS_FILE"
adb shell pm list packages -s -e -f | sed 's/package://' | awk -F'=' '{print "| " $1 " | " $2 " |"}' >> "$APPS_FILE"
echo "" >> "$APPS_FILE"

# Aplicativos Terceiros (5.2.2.1/5.2.2.2)
echo "## Aplicativos Terceiros" >> "$APPS_FILE"
echo "| Pacote |" >> "$APPS_FILE"
echo "|--------|" >> "$APPS_FILE"
adb shell pm list packages -3 | sed 's/package://' | awk '{print "| " $1 " |"}' >> "$APPS_FILE"
echo "" >> "$APPS_FILE"

# Propriedades do Sistema (5.2.2)
echo "## Propriedades do Sistema (Identificação do Produto - ATO 9281)" >> "$RELATORIO"
echo "### Modelo do Produto" >> "$RELATORIO"
adb shell getprop ro.product.model >> "$RELATORIO"
echo "### Versão do Android" >> "$RELATORIO"
adb shell getprop ro.build.version.release >> "$RELATORIO"
echo "### ID da Build" >> "$RELATORIO"
adb shell getprop ro.build.display.id >> "$RELATORIO"
echo "### Versão do Kernel" >> "$RELATORIO"
adb shell getprop ro.kernel.version >> "$RELATORIO"
echo "" >> "$RELATORIO"

# Informações de Estado (detalhes de pacotes)
echo "## Informações de Estado (Dumpsys - ATO 9281)" >> "$RELATORIO"
echo "### Pacotes (Dumpsys Package)" >> "$RELATORIO"
adb shell dumpsys package >> "$RELATORIO"
echo "" >> "$RELATORIO"

# Rede/Conexões (5.2.2.5)
echo "## Rede e Conexões (Dumpsys - ATO 9281)" >> "$RELATORIO"
echo "### Conectividade" >> "$RELATORIO"
adb shell dumpsys connectivity >> "$RELATORIO"
echo "" >> "$RELATORIO"
echo "### Wi-Fi" >> "$RELATORIO"
adb shell dumpsys wifi >> "$RELATORIO"
echo "" >> "$RELATORIO"
echo "### Telefone" >> "$RELATORIO"
adb shell dumpsys telephony.registry >> "$RELATORIO"
echo "" >> "$RELATORIO"

# Seção de Procedimentos de Ensaio (ATO 9281 - 5.2)
echo "## Procedimentos de Ensaio (ATO 9281 - 5.2)" >> "$RELATORIO"
echo "### 5.2.1 - Disponibilização da Amostra" >> "$RELATORIO"
echo "Amostra recebida na configuração de mercado, incluindo softwares, firmwares, middlewares e aplicativos. Versões registradas acima." >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "### 5.2.2 - Habilitação e Verificações" >> "$RELATORIO"
echo "#### 5.2.2.1 - Verificação de Software/Aplicativo Irregular (Lista Anatel)" >> "$RELATORIO"
echo "Lista de aplicativos coletada (ver '$APPS_FILE'). **Pendente de Análise Manual**: Compare com a lista de equipamentos/softwares irregulares publicada pela Anatel (disponível em anatel.gov.br). Registre se há correspondências." >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "#### 5.2.2.2 - Verificação de Acesso Ilícito a Conteúdo Audiovisual" >> "$RELATORIO"
echo "Aplicativos listados (ver '$APPS_FILE'). **Pendente de Análise Manual**: Verifique se há softwares/aplicativos/funcionalidades que permitam acesso ilícito (ex.: apps de streaming pirata). Registre evidências." >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "#### 5.2.2.3 - Verificação de Modo Root Habilitado" >> "$RELATORIO"
ROOT_CHECK=$(adb shell whoami 2>/dev/null || echo "Erro")
if [ "$ROOT_CHECK" = "root" ]; then
    echo "Resultado: Modo root DETECTADO (privilégios elevados ativos)." >> "$RELATORIO"
else
    echo "Resultado: Modo root NÃO detectado (baseado em checagem ADB)." >> "$RELATORIO"
fi
echo "**É necessário confirmar manualmente se o SO permite root!" >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "#### 5.2.2.4 - Verificação de Instalação de Apps de Terceiros Não da Loja Oficial" >> "$RELATORIO"
UNKNOWN_SOURCES=$(adb shell settings get secure install_non_market_apps 2>/dev/null || echo "Erro")
if [ "$UNKNOWN_SOURCES" = "1" ]; then
    echo "Resultado: Instalação de apps de terceiros HABILITADA por padrão." >> "$RELATORIO"
else
    echo "Resultado: Instalação de apps de terceiros DESABILITADA por padrão." >> "$RELATORIO"
fi
echo "Verifique configurações do dispositivo para confirmação." >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "#### 5.2.2.5 - Verificação de Portas/Serviços Não Documentados" >> "$RELATORIO"
echo "Portas abertas (de Netstat acima):" >> "$RELATORIO"
adb shell netstat -tulnp 2>/dev/null | grep LISTEN >> "$RELATORIO"
echo "**Pendente de Análise Manual**: Compare com documentação do fabricante (itens 5.1.5 b) e c) de Segurança Cibernética). Registre se há portas/serviços não documentados." >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "### 5.2.3 - Registro de Resultados" >> "$RELATORIO"
echo "Resultados das verificações acima registrados neste relatório para apreciação do agente de conformidade." >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo "### 5.2.4 - Outros Ensaios" >> "$RELATORIO"
echo "" >> "$RELATORIO"

echo '[INFO]: Script finalizado com sucesso. Relatórios salvos em relatorio_tvbox.md e aplicativos_tvbox.md'
