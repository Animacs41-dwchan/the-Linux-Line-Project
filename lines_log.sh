#!/bin/bash

# ==========================================================
# Script: lines_log.sh - Cartão Interativo com LOG
# Baseado no projeto de conscientização de saúde mental
# ==========================================================

# --- CONFIGURAÇÕES DE ARQUIVO ---
ARQUIVO_LOG="linhas_do_projeto.log"
DATA_HORA_GERACAO=$(date +"%Y-%m-%d %H:%M:%S")

# --- VARIÁVEIS DE COR ANSI E METADADOS ---
RESET='\e[0m'
VERDE_CLARO='\e[1;32m'
AMARELO='\e[1;33m'
AZUL_HEADER='\e[0;34m'
VERMELHO_FORTE='\e[1;31m'
BORDA_CHAR="${AZUL_HEADER}#${RESET}"

# Lista de Cores e Significados (Baseado na imagem de referência)
# Formato: "NOME|CODIGO_ANSI|SIGNIFICADO"
declare -a CORES=(
    "VERMELHO|\\e[1;31m|AUTOMUTILAÇÃO (Self Harm)"
    "LARANJA|\\e[0;33m|ANSIEDADE (Transtornos de Ansiedade)"
    "AMARELO|\\e[1;33m|TRANSTORNOS ALIMENTARES (Eating Disorders)"
    "VERDE|\\e[1;32m|SOFRENDO/SOFREU BULLYING"
    "CIANO|\\e[1;36m|ATAQUES DE PÂNICO/ANSIEDADE (Pânico Clínico)"
    "AZUL ESCURO|\\e[0;34m|DEPRESSÃO (Clínica)"
    "ROXO|\\e[1;35m|PENSAMENTOS SUICIDAS"
    "MAGENTA/ROSA CLARO|\\e[0;39m|LGBTQIA+" 
    "CINZA CLARO|\\e[1;37m|APOIO (Supporting/Aliado)"
    "CINZA ESCURO|\\e[0;37m|PERDA POR SUICÍDIO (Lost Someone to Suicide)"
    "PRETO|\\e[0;30m|TENTATIVA DE SUICÍDIO (Attempted Suicide)"
    "MARROM ESCURO|\\e[0;31m|OUTRAS CONDIÇÕES (Other Conditions)"
)

# --- FUNÇÃO PARA IMPRIMIR BORDA (APENAS PARA TELA) ---
imprimir_borda() {
    echo -e "${AZUL_HEADER}######################################################${RESET}"
}

# --- FUNÇÃO PARA GERAR O CONTEÚDO DO CARTÃO (PARA TELA E LOG) ---
gerar_cartao() {
    local formato=$1 # 'ansi' para cores na tela, 'texto' para log
    
    # Se o formato for 'texto', remove as cores ANSI do conteúdo
    if [ "$formato" == "texto" ]; then
        local AZUL_HASH="#"
        local HASH_LINE="######################################################"
        local HEADER_COLOR=""
        local TEXT_COLOR=""
        local LINHA_COR=""
    else # formato é 'ansi' (para a tela)
        local AZUL_HASH="${BORDA_CHAR}"
        local HASH_LINE
        imprimir_borda > /dev/null
        HASH_LINE="${AZUL_HEADER}######################################################${RESET}"
        local HEADER_COLOR="${AMARELO}"
        local TEXT_COLOR="${VERDE_CLARO}"
        local LINHA_COR="${COR_SIMBOLO}"
    fi

    # Monta o conteúdo do cartão
    CARTAO_OUTPUT="${HASH_LINE}
${AZUL_HASH} ${HEADER_COLOR}O PROJETO DAS LINHAS (CONSCIÊNCIA MENTAL)${RESET} ${AZUL_HASH}
${AZUL_HASH} --------------------------------------- ${AZUL_HASH}
${AZUL_HASH} ${TEXT_COLOR}DIA: ${DIA} - Gerado em: ${DATA_HORA_GERACAO}${RESET} ${AZUL_HASH}
${HASH_LINE}

${AZUL_HASH}
${AZUL_HASH} ${AZUL_HEADER}### A LINHA DE HOJE ###${RESET}
${AZUL_HASH}
${AZUL_HASH} ${AZUL_HEADER}  Sua linha representa: ${LINHA_COR}${SIGNIFICADO}${RESET}
${AZUL_HASH}
${AZUL_HASH} ${AZUL_HEADER}  A cor é: ${LINHA_COR}${COR_NOME}${RESET}
${AZUL_HASH} ${AZUL_HEADER}  Linha visual: ${LINHA_COR}■■■■■■■■■■■■■■■■■■■■${RESET}
${AZUL_HASH}
${HASH_LINE}
${AZUL_HASH} ${HEADER_COLOR}MENSAGEM DE FOCO:${RESET} ${AZUL_HASH}
${AZUL_HASH} ${LINHA_COR}    ${FOCO_DO_DIA}${RESET}
${HASH_LINE}"
    
    echo -e "$CARTAO_OUTPUT"
}

# --- FUNÇÃO PARA MOSTRAR MENU E OBTER ESCOLHA ---
mostrar_menu() {
    echo -e "\n${AMARELO}### ESCOLHA O TEMA DA SUA LINHA DO DIA (Mental Health) ###${RESET}"
    for i in "${!CORES[@]}"; do
        IFS='|' read -r NOME CODIGO SIGNIFICADO <<< "${CORES[i]}"
        echo -e "${BORDA_CHAR} [ $((i+1)) ] ${CODIGO}${NOME}${RESET} - ${SIGNIFICADO}"
    done
    echo -e "${BORDA_CHAR} ----------------------------------------------------"
    
    read -rp "Digite o número da linha (1-$((${#CORES[@]}))): " escolha_numero

    if ! [[ "$escolha_numero" =~ ^[0-9]+$ ]] || [ "$escolha_numero" -lt 1 ] || [ "$escolha_numero" -gt "${#CORES[@]}" ]; then
        echo -e "${VERMELHO_FORTE}Erro: Opção inválida. Saindo.${RESET}"
        exit 1
    fi
    
    escolha_indice=$((escolha_numero - 1))
    IFS='|' read -r COR_NOME COR_SIMBOLO SIGNIFICADO <<< "${CORES[escolha_indice]}"
    
    read -rp "Qual é o dia do seu projeto/desafio (ex: 01/100)? " DIA
    read -rp "Qual mensagem de foco você quer deixar hoje? " FOCO_DO_DIA
}

# --- EXECUÇÃO PRINCIPAL ---
mostrar_menu

# 1. IMPRESSÃO DO CARTÃO NA TELA (com cores ANSI)
echo -e "\n${AMARELO}--- CARTÃO GERADO ---\n${RESET}"
gerar_cartao "ansi"

# 2. SALVAMENTO NO ARQUIVO DE LOG (sem cores ANSI)
echo -e "\n\n=== Registro da Linha (Dia ${DIA}) - ${DATA_HORA_GERACAO} ===" >> "$ARQUIVO_LOG"
gerar_cartao "texto" >> "$ARQUIVO_LOG"
echo -e "\n\n" >> "$ARQUIVO_LOG"

echo -e "\n${VERDE_CLARO}SUCESSO!${RESET} O registro do dia ${DIA} foi salvo em: ${AMARELO}${ARQUIVO_LOG}${RESET}"
echo -e "Você pode visualizar o seu log com: ${AZUL_HEADER}cat ${ARQUIVO_LOG}${RESET}\n"
