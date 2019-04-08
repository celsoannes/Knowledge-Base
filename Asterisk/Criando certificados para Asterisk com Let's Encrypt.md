# Criando certificados para Asterisk com Let's Encrypt

## Instalação
Para evitar conflito de versões antes de fazer a instalação certifique-se de que não existe nenhuma versão pré instalada.

    sudo apt-get remove certbot

Faça o download da versão mais atual do _certbot-auto_ e de permisão de execução:

    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto

Rode o comando abaixo para instalar o certbot-auto:

    ./certbot-auto

## Gerando o certificado

    sudo ./certbot-auto certonly \
     --server https://acme-v02.api.letsencrypt.org/directory \
     --manual --preferred-challenges dns \
     -d *.domain.com -d domain.com

## Gerando certificados para Asterisk
Acesse a pasta onde os certificados foram gerados:

    cd /etc/letsencrypt/live/webrtc.webcall.digital/

Execute os comandos abaixo para copiar os certificados corretamente para a pasta do Asterisk:

    cat cert.pem > asterisk.pem && cat privkey.pem >> asterisk.pem
    mv asterisk.pem /etc/asterisk/keys/
    cp fullchain.pem /etc/asterisk/keys/asterisk.crt
    cp privkey.pem /etc/asterisk/keys/asterisk.key

## Renovação automatica:
Adicionar codigo a cron do root para renovacao automatica dos certificados

    * 3,15 * * * /home/deploy/certbot-auto -q renew  --renew-hook "/etc/init.d/nginx reload" >> /var/log/certbot-auto-renew
