#!/bin/bash

# Script: openvpn_yealink.sh
# Author: Celso Annes
# Contact: celso@finti.com.br
# Date: 2024-03-21

# Função para substituir o valor no arquivo vpn.cnf
substituir_valor() {
    local chave="$1"
    local valor="$2"
    sed -i "s/$chave/$valor/g" /etc/openvpn/client/$RAMAL/vpn.cnf
}

# Verifica se foi passado o ramal como argumento
if [ -z "$1" ]; then
    echo "Por favor, especifique o número do ramal como argumento."
    exit 1
fi

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

# Cria diretório e define permissões
mkdir -p /etc/openvpn/client &> /dev/null
chmod -R 700 /etc/openvpn/client &> /dev/null
cd /etc/openvpn/easy-rsa &> /dev/null

# Gera o certificado sem necessidade de senha
echo | ./easyrsa gen-req $RAMAL nopass &> /dev/null

# Assina o certificado sem precisar digitar "yes"
echo "yes" | ./easyrsa --days=3650 sign-req client $RAMAL &> /dev/null

# Cria diretório para as chaves
mkdir -p /etc/openvpn/client/$RAMAL/keys &> /dev/null

# Copia os arquivos necessários
cp /etc/openvpn/easy-rsa/pki/issued/$RAMAL.crt /etc/openvpn/client/$RAMAL/keys/ &> /dev/null
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client/$RAMAL/keys/ &> /dev/null
cp /etc/openvpn/easy-rsa/pki/private/$RAMAL.key /etc/openvpn/client/$RAMAL/keys/ &> /dev/null

# Copia e substitui o arquivo de configuração
cp /etc/openvpn/client/vpn.cnf /etc/openvpn/client/$RAMAL/vpn.cnf &> /dev/null
sed -i "s/RAMAL/$RAMAL/g" /etc/openvpn/client/$RAMAL/vpn.cnf &> /dev/null

# Cria o arquivo tar
tar -cf /etc/openvpn/client/yealink_vpn_$RAMAL.tar /etc/openvpn/client/$RAMAL/* &> /dev/null

echo "Processo concluído com sucesso."
echo -e "O arquivo yealink_vpn_$RAMAL.tar foi criado em: \e[32m/etc/openvpn/client/yealink_vpn_$RAMAL.tar\e[0m"