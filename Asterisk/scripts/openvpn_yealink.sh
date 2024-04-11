#!/bin/bash

# Script: openvpn_yealink.sh
# Author: Celso Annes
# Contact: celso@finti.com.br
# Date: 2024-03-21

# Função para substituir o valor no arquivo vpn.cnf
substituir_valor() {
    local chave="$1"
    local valor="$2"
    sed -i "s/$chave/$valor/g" /etc/openvpn/client/vpn.cnf
}

# Verifica se foi passado o ramal como argumento
if [ -z "$1" ]; then
    echo "Por favor, especifique o número do ramal como argumento."
    exit 1
fi

# O número do ramal é passado como argumento para o script
RAMAL=$1

# Verifica a existência e solicitação de HOST e PORTA
if grep -q "HOST" /etc/openvpn/client/vpn.cnf; then
    echo "Informe o IP para HOST:"
    read HOST
    substituir_valor "HOST" "$HOST"
fi

if grep -q "PORTA" /etc/openvpn/client/vpn.cnf; then
    echo "Informe o valor da porta:"
    read PORTA
    substituir_valor "PORTA" "$PORTA"
fi

# Navega para o diretório especificado
cd /etc/openvpn/easy-rsa/

# Carrega as variáveis
. ./vars

# Executa o pkitool com o número do ramal
./pkitool $RAMAL

# Cria o diretório para as chaves do ramal
mkdir -p /etc/openvpn/client/$RAMAL/keys

# Define permissões
chmod -R 700 /etc/openvpn/client/$RAMAL &> /dev/null

# Copia as chaves para o diretório do ramal
cp /etc/openvpn/easy-rsa/keys/{$RAMAL.crt,$RAMAL.key,ca.crt} /etc/openvpn/client/$RAMAL/keys

# Copia e substitui o arquivo de configuração
cp /etc/openvpn/client/vpn.cnf /etc/openvpn/client/$RAMAL/vpn.cnf &> /dev/null
sed -i "s/RAMAL/$RAMAL/g" /etc/openvpn/client/$RAMAL/vpn.cnf &> /dev/null

# Cria o arquivo tar
cd /etc/openvpn/client/$RAMAL/
tar -cf /etc/openvpn/client/yealink_vpn_$RAMAL.tar * &> /dev/null

echo "Processo concluído com sucesso."
echo -e "O arquivo yealink_vpn_$RAMAL.tar foi criado em: \e[32m/etc/openvpn/client/yealink_vpn_$RAMAL.tar\e[0m"