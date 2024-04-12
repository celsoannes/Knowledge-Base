Claro, posso ajudar a melhorar a formatação do seu tutorial em Markdown. Aqui está uma versão revisada:


# Configurando OpenVPN para Yealink no Debian 11

As versões mais recentes do Openvpn e do Easy-rsa possuem exigências de criptografia que impedem que versões mais antigas dos telefones Yealink funcionem. Por isso, é necessário utilizar uma versão mais antiga do `easy-rsa`.

## Instalação do OpenVPN e EasyRSA

1. Atualize o índice de pacotes e instale o OpenVPN:

    ```shell
    apt-get update
    apt install openvpn
    ```

2. Baixe e instale a versão mais antiga do EasyRSA que será usada para construir o Certificado de Autoridade (CA):

    ```shell
    wget -P /usr/src http://archive.debian.org/debian/pool/main/e/easy-rsa/easy-rsa_2.2.2-2_all.deb
    dpkg -i /usr/src/easy-rsa_2.2.2-2_all.deb
    ```

## Habilitação do Encaminhamento de Pacotes

Nesta seção, iremos informar ao kernel do servidor para encaminhar o tráfego do cliente de fora para a internet. Caso contrário, o tráfego irá parar no servidor.

1. Habilite o encaminhamento de pacotes durante a execução rodando este comando:

    ```shell
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ```

2. Em seguida, precisamos tornar essa configuração permanente para que ela seja mantida após o servidor ser reiniciado. Abra o arquivo de configuração do sysctl:

    ```shell
    vi /etc/sysctl.conf
    ```

3. Próximo ao topo do arquivo sysctl, você verá:

    ```shell
    # Uncomment the next line to enable packet forwarding for IPv4
    #net.ipv4.ip_forward=1
    ```

4. Descomente `net.ipv4.ip_forward`. Ele deve ficar assim quando finalizado:

    ```shell
    # Uncomment the next line to enable packet forwarding for IPv4
    net.ipv4.ip_forward=1
    ```

## Configuração e Criação do Certificado de Autoridade

O OpenVPN usa certificados para criptografar o tráfego.

1. Copie o gerador de scripts Easy-RSA:

    ```shell
    cp -vr /usr/share/easy-rsa/ /etc/openvpn
    ```

2. Crie a pasta que irá abrigar as chaves OpenVPN:

    ```shell
    mkdir -vp /etc/openvpn/easy-rsa/keys
    ```

3. Configure os parâmetros para o nosso certificado. Abra o arquivo de variáveis:

    ```shell
    vi /etc/openvpn/easy-rsa/vars
    ```

4. As variáveis entre aspas podem ser alteradas de acordo com a sua preferência:

    ```shell
    export KEY_COUNTRY="BR"
    export KEY_PROVINCE="Nome do Estado"
    export KEY_CITY="Nome da Cidade"
    export KEY_ORG="Nome da Empresa"
    export KEY_EMAIL="seu@email.com"
    export KEY_OU="Yealink"
    ```

5. Crie a pasta que irá abrigar as chaves do servidor OpenVPN:

    ```shell
    mkdir -vp /etc/openvpn/server/keys
    ```

6. Agora será gerado os parâmetros Diffie-Helman usando a ferramenta construtora OpenSSL chamada `dhparam`; isso pode demorar alguns minutos. O sinal `-out` especifica onde salvar os novos parâmetros:

    ```shell
    openssl dhparam -out /etc/openvpn/server/keys/dh2048.pem 2048
    ```

7. Rode o comando abaixo para criar o arquivo `openssl.cnf` necessário para o `easy-rsa`:

    ```shell
    cp -v /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
    ```

8. Altere o chiper de `sha256` para `sha1`, para ter compatibilidade com os telefones yealink mais antigos com o comando abaixo:

    ```shell
    sed -i '/default_md/s/sha256/sha1/g' /etc/openvpn/easy-rsa/openssl.cnf
    ```
   
9. O nosso certificado foi gerado, agora é hora de gerar a chave. Vá para a pasta easy-rsa:

    ```shell
    cd /etc/openvpn/easy-rsa
    ```

10. Agora podemos começar a configurar o CA em si. Primeiramente inicialize a infraestrutura de chave pública (Public Key Infrastructure - PKI). Preste atenção no ponto (.) e no espaço em frente ao ./vars. Isso significa o diretório de trabalho atual (fonte):

    ```shell
    . ./vars
    ```

    > **NOTA**: O seguinte alerta será mostrado. Não se preocupe, o diretório especificado no alerta está vazio. NOTE: If you run ./clean-all, I will be doing a rm -rf on /etc/openvpn/easy-rsa/keys.

11. Em seguida nos iremos limpar todas as outras chaves que podem interferir no processo da nossa instalação.

    ```shell
    ./clean-all
    ```

12. Finalmente nos iremos construir o CA usando um comando OpenSSL. Este comando irá solicitar a você uma confirmação de _**Nome Distinto**_ (Distinguished Name) variáveis que foram inseridas anteriormente. Pressione `ENTER` para aceitar os valores existentes.

    ```shell
    ./build-ca
    ```
    
    Agora o Certificado de Autoridade (CA) esta configurado.


## Gerando o Certificado e a Chave para o Servidor
Nesta parte, nos iremos configurar e iniciar nosso servidor OpenVPN.

Continue trabalhando a partir de `/etc/openvpn/easy-rsa`, construa a sua chave com o nome do servidor. Isto foi espeficicado mais cedo como `KEY_NAME` no seu arquivo de configuração. O padrão para este tutorial é server.

```shell
./build-key-server server
```

Será solicitado novamente a confirmação do Nome Distinto. Pressione `ENTER` para aceitar os valores padrões definido. Desta vez terá duas solicitações adicionais.

```shell
...
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
...
```

Ambos devem ser deixados em **branco**, então apensa pressione `ENTER` para passar por cada uma.

Ao final duas consultas adicionais solicitam uma resposta positiva (`y`).

```shell
...
Certificate is to be certified until Apr  6 14:35:06 2034 GMT (3650 days)
Sign the certificate? [y/n]:y
...
```

Digite `y` aqui também:

```shell
...
Sign the certificate? [y/n]
1 out of 1 certificate requests certified, commit? [y/n]
...
```
Então será apresentado a você uma indicação de sucesso.

```shell
Write out database with 1 new entries
Data Base Updated
```

## Mova os Certificados e as Chaves do Servidor
Agora nos iremos copiar o certificado e a chave para `/etc/openvpn/server/keys`, conforme o OpenVPN irá buscar nesta pasta o certificado CA e a chave do servidor.

```shell
cp -v /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn/server/keys
```

Crie o arquivo `openvpn_yealink.conf` com o comando abaixo:

```shell
touch /etc/openvpn/openvpn_yealink.conf
```

Agora abra ele com o seu editor de preferência:

```shell
vi /etc/openvpn/openvpn_yealink.conf
```

Adicione o seguinte conteúdo ao arquivo `openvpn_yealink.conf`:

```shell
port 1194
proto udp
dev tun
ca /etc/openvpn/server/keys/ca.crt
cert /etc/openvpn/server/keys/server.crt
key /etc/openvpn/server/keys/server.key  # This file should be kept secret
dh /etc/openvpn/server/keys/dh2048.pem
server 10.8.0.0 255.255.255.0
client-config-dir /etc/openvpn/staticclients
keepalive 10 120
comp-lzo
persist-key
persist-tun
verb 3
log-append /var/log/openvpn/openvpn.log
```

Ajuste as entradas abaixo conforme a sua necessidade:

- `port`: Porta utilizada para se comunicar com o servidor OpenVPN
- `server`: Faixa de rede em qual será distribuida o ip para os Telefones IP.

Inicie o servidor OpenVPN e verifique o seu status:

```shell
systemctl start openvpn
systemctl status openvpn
```

O comando status irá retornar algo selelhante ao seguinte:

```shell
● openvpn.service - OpenVPN service
     Loaded: loaded (/lib/systemd/system/openvpn.service; enabled; vendor preset: enabled)
     Active: active (exited) since Mon 2024-04-08 13:36:18 -03; 36min ago
    Process: 27542 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 27542 (code=exited, status=0/SUCCESS)
        CPU: 2ms

abr 08 13:36:18 debian systemd[1]: Starting OpenVPN service...
abr 08 13:36:18 debian systemd[1]: Finished OpenVPN service.
```

## Gerando Certificados e Chaves para os Clientes
Você deve continuar trabalhando na pasta `/etc/openvpn/easy-rsa`:

No exemplo abaixo vamos criar os arquivos necessários para o ramal `2000`

```
./build-key 2000
```

Novamente você será perguntado para confirmar ou alterar as variaves do Nome Distinto (Distinguished Name) e as seguintes solicitações devem ser deixadas em branco. Pessione `ENTER` para aceitar os padrões:

```shell
...
A challenge password []:
An optional company name []:
...
```

Como anteriormente, estas duas confirmações ao final do processo de contrução exige uma resposta (`y`).

```shell
Sign the certificate? [y/n]
1 out of 1 certificate requests certified, commit? [y/n]
```

Então você terá a seguinte saida confirmando o sucesso na contrução da chave.

```shell
Write out database with 1 new entries.
Data Base Updated
```


## Configurando o arquivo de Cliente para Yealink
O OpenVPN requer o uso de certificados para ajudar a estabelecer a autenticidade da conexão dos clientes a um servidor OpenVPN. Você precisa obter os arquivos `ca.crt`, `client.crt`, `client.key` e `vpn.cnf` do sistema e então compactar eles no formato `TAR`.

Crie uma nova pasta chamada `2000` para guardar as chaves para o ramal:

```shell
mkdir -vp /etc/openvpn/client/2000/keys
```

Copie os arquivos de certificado necessário para a pasta do cliente criado anteriormente.

```shell
cp /etc/openvpn/easy-rsa/keys/{client.crt,client.key,ca.crt} /etc/openvpn/client/2000/keys
```

Crie um novo arquivo chamado `vpn.cnf` com o seu editor de preferência

```shell
vi /etc/openvpn/client/2000/vpn.cnf
```

E adicione o sequinte conteúdo dentro do arquivo `vpn.cnf` do ramal `2000`

```shell
client
setenv SERVER_Poll_TIMEOUT 4
nobind
proto udp
remote <IP do Servidor> <porta>
dev tun
dev-type tun
persist-tun
persist-key
ns-cert-type server
ca /config/openvpn/keys/ca.crt
cert /config/openvpn/keys/2000.crt
key /config/openvpn/keys/2000.key
comp-lzo
```

Compactando em formato TAR

```shell
cd /etc/openvpn/client/2000
tar -cvpf openvpn.tar *
```

## Pegando um Atalho

Agora que você ja entendeu como funciona, vamos facilitar o processo de criação dos proximos pacotes de vpn para os próximos ramais.

Baixe o arquivo [vpn.cnf](./scripts/vpn.cnf) com o comando abaixo:

````shell
wget https://raw.githubusercontent.com/celsoannes/Knowledge-Base/master/Asterisk/scripts/vpn.cnf -P /etc/openvpn/client/
````

Baixe também o script `openvpn_yealink.sh`:

````shell
wget https://raw.githubusercontent.com/celsoannes/Knowledge-Base/master/Asterisk/scripts/openvpn_yealink.sh -P /etc/openvpn/client/
````

De permissão de execução:

````shell
chmod +x /etc/openvpn/client/openvpn_yealink.sh
````

Agora execute o script informe o ramal e veja a mágica acontecer:

````shell
env DEBUG=1 ./openvpn_yealink.sh 2001
````
