# Script de Ensaios Funcionais em TV-Box

## Descrição

Este script em shell foi desenvolvido para automatizar a coleta de dados de dispositivos TV-Box baseados em Android, com foco na conformidade com o ATO 9281/2016 da Agência Nacional de Telecomunicações (Anatel). 

Ele executa verificações essenciais para procedimentos de ensaio (seção 5.2), incluindo listagem de softwares, propriedades do sistema, configurações de rede e verificações específicas de segurança cibernética. Os dados são organizados em relatórios Markdown estruturados, facilitando auditorias e submissões à Anatel.

O script gera dois arquivos principais:

- `relatorio_tvbox.md`: Relatório consolidado com propriedades, estado do dispositivo e verificações do ATO 9281.
- `aplicativos_tvbox.md`: Detalhamento tabular dos aplicativos instalados (sistema e terceiros).

**Nota**: Verificações manuais são necessárias para itens como comparação com listas de irregulares da Anatel e análise de funcionalidades ilícitas.

## Pré-requisitos

- **Sistema Operacional**: Linux, macOS ou Windows (com WSL ou Git Bash).
- **ADB (Android Debug Bridge)**: Instalado e configurado. Baixe do [site oficial do Android](https://developer.android.com/studio/command-line/adb).
- **Dispositivo TV-Box**: Conectado via USB, com depuração USB habilitada e autorizada no dispositivo.
- **Permissões**: Execute o script com privilégios adequados (ex.: `chmod +x tvbox_script.sh`). O dispositivo deve estar na configuração de mercado, conforme exigido pelo ATO 9281 (5.2.1).

## Instalação

1. Baixe ou clone o repositório contendo o script.
2. Torne o script executável:

   ```bash
   chmod +x tvbox_script.sh
   ```

3. Certifique-se de que o ADB está no PATH do sistema. Teste com:

   ```bash
   adb version
   ```

## Uso

1. Conecte o TV-Box ao computador via USB.
2. Execute o script:

   ```bash
   ./tvbox_script.sh
   ```

3. Insira o protocolo e orçamento da amostra quando solicitado.
4. Aguarde a execução (aproximadamente 1-2 minutos, dependendo do dispositivo).
5. Os arquivos `relatorio_tvbox.md` e `aplicativos_tvbox.md` serão gerados no diretório atual.

### Exemplo de Execução

```bash
$ ./tvbox_script.sh
==== VSW ====
==== TV-BOX ====
Digite o protocolo da amostra: 12345
Digite o orçamento da amostra: 7890
[INFO]: Script finalizado. Relatórios em relatorio_tvbox.md e aplicativos_tvbox.md
```

### Tratamento de Erros

- Se o ADB não detectar o dispositivo, verifique a conexão USB e habilite a depuração.
- Em caso de falha em comandos ADB (ex.: dispositivo não rootado), o script registra "Erro" ou "NÃO detectado" e continua.
- Para dispositivos com restrições (ex.: sem root), algumas verificações podem requerer análise manual.

## Funcionalidades

- **Coleta Automatizada**:
  - Propriedades do sistema (modelo, versão Android, kernel).
  - Listagem de aplicativos (sistema e terceiros) em tabelas Markdown.
  - Informações de rede (Netstat, conectividade, Wi-Fi, telefone).
  - Estado do dispositivo (dumpsys de pacotes e rede).

- **Verificações do ATO 9281 (Seção 5.2)**:
  - *5.2.1*: Confirmação de configuração de mercado.
  - *5.2.2.1-5.2.2.2*: Listagem de apps para verificação de irregulares e acesso ilícito (análise manual necessária).
  - *5.2.2.3*: Detecção de modo root.
  - *5.2.2.4*: Verificação de instalação de apps de terceiros.
  - *5.2.2.5*: Listagem de portas abertas para comparação com documentação.
  - *5.2.3*: Registro de resultados no relatório.


## Estrutura dos Arquivos

- `tvbox_script.sh`: Script principal.
- `relatorio_tvbox.md`: Relatório consolidado com seções do ATO 9281.
- `aplicativos_tvbox.md`: Tabelas detalhadas de aplicativos.



