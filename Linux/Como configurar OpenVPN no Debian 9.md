# Como configurar OpenVPN no Debian 9

## 1. Instalando OpenVPN e EasyRSA

Para começar atualize o indice de pacotes e instale o OpenVPN.

```bash
apt-get update
apt install openvpn
```

Baixe a ultima versão do EasyRSA que será usado para construir o Certificado de Autoridade (CA).

```bash
wget -P /etc/openvpn/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz
```

Comece navegando até o diretório EasyRSA no seu servidor OpenVPN:
```bash
cd /etc/openvpn/
```

Então extraia o pacote ``tar``:

```bash
tar xvf EasyRSA-unix-v3.0.6.tgz
```


## 2. Configurando as Variáveis EasyRSA e Construindo o CA

EasyRSA vem instalado com um arquivo de configuração que você pode editar para definir diversas variáveis para o CA.

Acesse a pasta do EasyRSA.

```bash
cd EasyRSA-v3.0.6
```

Dentro deste diretório existe um arquivo chamado ``vars.example``. Faça uma cópia deste arquivo com o nome ``vars``.

```bash
cp vars.example vars
```

Abra o arquivo ``vars`` recém-criado e encontre as configurações que definem os padrões de campo para novos certificados. Ele irá ser parecido com o seguinte:

```bash
#set_var EASYRSA_REQ_COUNTRY    "US"
#set_var EASYRSA_REQ_PROVINCE   "California"
#set_var EASYRSA_REQ_CITY       "San Francisco"
#set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co"
#set_var EASYRSA_REQ_EMAIL      "me@example.net"
#set_var EASYRSA_REQ_OU         "My Organizational Unit"
```

Descomente as linhas e atualize os campos para os de sua preferencia, mas não os deixe em branco:

```bash
set_var EASYRSA_REQ_COUNTRY    "BR"
set_var EASYRSA_REQ_PROVINCE   "Rio Grande do Sul"
set_var EASYRSA_REQ_CITY       "Novo Hamburgo"
set_var EASYRSA_REQ_ORG        "3WM"
set_var EASYRSA_REQ_EMAIL      "admin@example.net"
set_var EASYRSA_REQ_OU         "Knowledge-Base"
```

Caso deseje alterar o tempo de expiração do certificado remova o comentário de ``set_var EASYRSA_CERT_EXPIRE`` e altere o seu valor padrão ``1080`` para o valor desejado:

```bash
#set_var EASYRSA_CERT_EXPIRE     1080
```


Dentro da pasta EasyRSA existe um script chamado ``easyrsa`` que é chamado para executar uma variedade de tarefas envolvidas na criação e gerenciamento da CA. Rode esse script com a opção ``init-pki`` para iniciar a infraestrutura de chave pública no servidor CA.

```bash
./easyrsa init-pki
```

```bash
Note: using Easy-RSA configuration from: ./vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/EasyRSA-v3.0.6/pki
```

Depois disto, execute o ``easyrsa`` novamente com a opção ``build-ca``. Isto irá construir o CA e criar dois arquivos importantes o ``ca.crt`` e o ``ca.key`` que compõem os lados público e privado de um certificado SSL.

* ``ca.crt`` é o arquivo CA de certificado público, no contexto do OpenVPN, o servidor e o cliente usam para informar um ao outro que eles fazem parte da mesma rede de confiança e não alguem executando um ataque man-in-the-midle. Por esta razão, o seu servidor e todos os seus clientes precisarão de uma cópia do arquivo ``ca.crt``.
* ``ca.key`` é a chave privada que a máquina CA usa para assinar chaves e certificados para servidores e clientes. Se um invasor obtiver acesso à sua CA e por sua vez ao seu arquivo ca.key, ele poderá assinar solicitações de certificado e obter acesso à sua VPN, impedindo sua segurança. É por isso que seu arquivo ca.key deve estar apenas em sua máquina CA e, idealmente, sua máquina CA deve ficar offline quando não estiver assinando solicitações de certificado como uma medida de segurança extra.

Se você não quiser receber uma solicitação de senha toda vez que interagir com sua autoridade de certificação, poderá executar o comando ``build-ca`` com a opção ``nopass``, assim:

```bash
./easyrsa build-ca nopass
```

Na saída, você será solicitado a confirmar o nome comum da sua autoridade de certificação CA:

```bash
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:
```

O nome comum é o nome usado para se referir a essa máquina no contexto da autoridade de certificação. Você pode inserir qualquer string de caracteres para o nome comum da CA, mas, para simplificar, pressione ``ENTER`` para aceitar o nome padrão.

Com isso, sua CA está no lugar e está pronta para começar a assinar solicitações de certificado.


## 3. Criando o Certificado do Servidor, Chave e Arquivos de Criptografia

Agora que você tem uma CA pronta para ser usada, você pode gerar uma chave privada e uma solicitação de certificado de seu servidor e, em seguida, transferi-la para sua CA para ser assinada, criando o certificado necessário. Você também pode criar alguns arquivos adicionais usados durante o processo de criptografia.

Em seguida, chame o script ``easyrsa`` novamente, desta vez com a opção ``gen-req`` seguida de um nome comum para a máquina. Novamente, isso pode ser qualquer coisa que você goste, mas pode ser útil fazer algo descritivo. Ao longo deste tutorial, o nome comum do servidor OpenVPN será simplesmente ``server``. Certifique-se de incluir também a opção ``nopass``. Caso contrário, o arquivo de solicitação será protegido por senha, o que poderá levar a problemas de permissão mais tarde:

```bash
./easyrsa gen-req server nopass
```

Isso criará uma chave privada para o servidor e um arquivo de solicitação de certificado chamado ``server.req``. Copie a chave do servidor para o diretório ``/etc/openvpn/``:

```bash
 cp /etc/openvpn/EasyRSA-v3.0.6/pki/private/server.key /etc/openvpn
```

Em seguida, assine o pedido executando o script ``easyrsa`` com a opção ``sign-req``, seguida do tipo de solicitação e do nome comum. O tipo de solicitação pode ser ``client`` ou ``server``, portanto, para a solicitação de certificado do servidor OpenVPN, certifique-se de usar o tipo de solicitação do ``server``:

```bash
./easyrsa sign-req server server
```

Na saída, você será solicitado a confirmar se a solicitação vem de uma fonte confiável. Digite ``yes`` e pressione ``ENTER`` para confirmar:

```bash
You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /etc/openvpn/EasyRSA-v3.0.6/pki/safessl-easyrsa.cnf
Can't open /etc/openvpn/EasyRSA-v3.0.6/pki/index.txt.attr for reading, No such file or directory
139743383085120:error:02001002:system library:fopen:No such file or directory:../crypto/bio/bss_file.c:74:fopen('/etc/openvpn/EasyRSA-v3.0.6/pki/index.txt.attr','r')
139743383085120:error:2006D080:BIO routines:BIO_new_file:no such file:../crypto/bio/bss_file.c:81:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until May 27 14:59:44 2029 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/EasyRSA-v3.0.6/pki/issued/server.crt
```

Copie os arquivos ``server.crt`` and ``ca.crt`` para a pasta ``/etc/openvpn/```:

```bash
cp /etc/openvpn/EasyRSA-v3.0.6/pki/issued/server.crt /etc/openvpn
cp /etc/openvpn/EasyRSA-v3.0.6/pki/ca.crt /etc/openvpn
```

Em seguida, navegue para o seu diretório EasyRSA:

```bash
cd /etc/openvpn/EasyRSA-v3.0.6
```

A partir daí, crie uma chave Diffie-Hellman forte para usar durante a troca de chaves digitando:

```bash
./easyrsa gen-dh
```

Isso pode levar alguns minutos para ser concluído. Depois disso, gere uma assinatura HMAC para fortalecer os recursos de verificação de integridade de TLS do servidor:

```bash
openvpn --genkey --secret ta.key
```

Quando o comando terminar, copie os dois novos arquivos para o diretório ``/etc/openvpn/``:

```bash
cp /etc/openvpn/EasyRSA-v3.0.6/ta.key /etc/openvpn/
cp /etc/openvpn/EasyRSA-v3.0.6/pki/dh.pem /etc/openvpn/
```

Com isso, todos os arquivos de certificados e chaves necessários ao seu servidor foram gerados. Você está pronto para criar os certificados e chaves correspondentes que sua máquina cliente usará para acessar seu servidor OpenVPN.


## 4. Gerando um Certificado de Cliente e um Par de Chaves

Iremos gerar um único par de chave e certificado de cliente para este guia. Se você tiver mais de um cliente, poderá repetir esse processo para cada um. Observe, no entanto, que você precisará passar um valor de nome exclusivo para o script de cada cliente. Ao longo deste tutorial, o primeiro (certificado/par de chaves) é referido como ``client1``.

Comece criando uma estrutura de diretório em seu diretório inicial, caso não exista, para armazenar o certificado do cliente e os arquivos de chave:

```bash
mkdir -p /etc/openvpn/client/keys
```

Como você armazenará os pares de certificados/chaves e os arquivos de configuração do seu cliente nesse diretório, deverá bloquear suas permissões agora como uma medida de segurança:

```bash
chmod -R 700 /etc/openvpn/client/keys
```
Em seguida, volte para a pasta EasyRSA e execute o script ``easyrsa`` com as opções ``gen-req`` e ``nopass``, junto com o nome comum para o cliente:

```bash
cd /etc/openvpn/EasyRSA-v3.0.6
./easyrsa gen-req client1 nopass
```

Pressione ``ENTER`` para confirmar o nome comum. Em seguida, copie o arquivo ``client1.key`` para a pasta ``/etc/openvpn/client/keys`` que você criou anteriormente:

```bash
cp /etc/openvpn/EasyRSA-v3.0.6/pki/private/client1.key /etc/openvpn/client/keys 
```

Em seguida, assine a solicitação como você fez para o servidor na etapa anterior. No entanto, desta vez, não se esqueça de especificar o tipo de pedido do cliente:

```bash
./easyrsa sign-req client client1
```

No prompt, insira ``yes`` para confirmar que você pretende assinar a solicitação de certificado e que ela veio de uma fonte confiável:

```bash
Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
```

Isso criará um arquivo de certificado de cliente chamado ``client1.crt``, copie o certificado do cliente para o diretório ``/etc/openvpn/client/keys``.

```bash
cp /etc/openvpn/EasyRSA-v3.0.6/pki/issued/client1.crt /etc/openvpn/client/keys
```

Em seguida, copie também os arquivos ``ca.crt`` e ``ta.key`` para o diretório ``/etc/openvpn/client/keys``:

```bash
 cp /etc/openvpn/EasyRSA-v3.0.6/ta.key /etc/openvpn/client/keys
 cp /etc/openvpn/EasyRSA-v3.0.6/pki/ca.crt /etc/openvpn/client/keys
```

Com isso, os certificados e as chaves do servidor e do cliente foram todos gerados e armazenados nos diretórios apropriados em seu servidor. Ainda há algumas ações que precisam ser executadas com esses arquivos, mas elas virão em uma etapa posterior. Por enquanto, você pode continuar configurando o OpenVPN no seu servidor.


## 5. Configurando o serviço OpenVPN

Agora que os certificados e as chaves do cliente e do servidor foram gerados, você pode começar a configurar o serviço OpenVPN para usar essas credenciais.

Comece copiando um arquivo de configuração OpenVPN de amostra no diretório de configuração e em seguida, extraia-o para usá-lo como base para sua configuração:

```bash
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/gzip -d /etc/openvpn/server.conf.gz
```

Abra o arquivo de configuração do servidor em seu editor de texto preferido:

```bash
vi /etc/openvpn/server.conf
```

Encontre a seção HMAC procurando pela diretiva tls-auth. Esta linha já deve estar descomentada, mas se não remova o ";" para descomentar. Abaixo dessa linha, adicione o parâmetro ``key-direction``, definido como ``0``:

```bash
tls-auth ta.key 0 # This file is secret
key-direction 0
```

Em seguida, encontre a seção sobre criptograma, procurando as linhas de ``cipher`` comentadas. O criptograma ``AES-256-CBC`` oferece um bom nível de criptografia e é bem suportada. Novamente, essa linha já deve estar descomentada, mas se não for, basta remover o ``;``:

```bash
cipher AES-256-CBC
```

Abaixo disso, adicione uma diretiva ``auth`` para selecionar o algoritmo de resumo de mensagem HMAC. Para isso, o ``SHA256`` é uma boa escolha:

```bash
auth SHA256
```

Em seguida, encontre a linha contendo uma diretiva ``dh`` que define os parâmetros Diffie-Hellman. Devido a algumas alterações recentes feitas no EasyRSA, o nome do arquivo para a chave Diffie-Hellman pode ser diferente do que está listado no arquivo de configuração do servidor de exemplo. Se necessário, altere o nome do arquivo listado aqui removendo o ``2048`` para que ele se alinhe com a chave gerada na etapa anterior:

```bash
dh dh.pem
```

Finalmente, encontre as configurações de ``user`` e ``group`` e remova o ``;`` no começo de cada um para descomentar estas linhas:

```bash
user nobody
group nogroup
```

As alterações que você fez no arquivo server.conf de amostra até este ponto são necessárias para que o OpenVPN funcione. As alterações descritas abaixo são opcionais, embora elas também sejam necessárias para muitos casos de uso comuns.

O arquivo ``server.conf`` deve ser semelhante ao abaixo:

```bash
port 1194
proto udp
dev tun
ca /etc/openvpn/server/keys/ca.crt
cert /etc/openvpn/server/keys/server.crt
key /etc/openvpn/server/keys/server.key
dh /etc/openvpn/server/keys/dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
tls-auth ta.key 0
key-direction 0
cipher AES-256-CBC
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
log-append /var/log/openvpn.log
```


## 6. Ajustando a Configuração de Rede do Servidor

Existem alguns aspectos da configuração de rede do servidor que precisam ser ajustados para que o OpenVPN possa rotear o tráfego corretamente através da VPN. O primeiro deles é o encaminhamento de IP, um método para determinar onde o tráfego IP deve ser roteado. Isso é essencial para a funcionalidade de VPN que seu servidor fornecerá.

Ajuste a configuração de encaminhamento de IP padrão do seu servidor, modificando o arquivo ```/etc/sysctl.conf```:

```bash
vi /etc/sysctl.conf
```

Dentro, procure a linha comentada que define ``net.ipv4.ip_forward``. Remova o caractere ``#`` do começo da linha para remover o comentário desta configuração:

```bash
net.ipv4.ip_forward=1
```

Para ler o arquivo e ajustar os valores da sessão atual, digite:

```bash
sysctl -p
```

## 7. Iniciando e Ativando o Serviço OpenVPN

Você está finalmente pronto para iniciar o serviço OpenVPN no seu servidor. Isso é feito usando o systemctl do utilitário ``systemd``.

Inicie o servidor OpenVPN especificando o nome do arquivo de configuração como uma variável de instância após o nome do arquivo da unidade systemd. O arquivo de configuração para o seu servidor é chamado ``/etc/openvpn/server.conf``, então adicione ``@server`` ao final do seu arquivo de unidade ao chamá-lo:

```bash
systemctl start openvpn@server
```

Verifique novamente se o serviço foi iniciado com sucesso, digitando:

```bash
systemctl status openvpn@server
```

Se tudo correu bem, sua saída será algo como isto:

```bash
● openvpn@server.service - OpenVPN connection to server
   Loaded: loaded (/lib/systemd/system/openvpn@.service; disabled; vendor preset: enabled)
   Active: active (running) since Thu 2019-05-30 16:11:13 -03; 7min ago
     Docs: man:openvpn(8)
           https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage
           https://community.openvpn.net/openvpn/wiki/HOWTO
  Process: 1932 ExecStart=/usr/sbin/openvpn --daemon ovpn-server --status /run/openvpn/server.status 10 --cd /etc/openvpn --config /etc/openvpn/server.conf --writepid /run/openvpn/server.pid (code=exited, status=0/SUCCESS)
 Main PID: 1933 (openvpn)
    Tasks: 1 (limit: 4915)
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─1933 /usr/sbin/openvpn --daemon ovpn-server --status /run/openvpn/server.status 10 --cd /etc/openvpn --config /etc/openvpn/server.conf --writepid /run/openvpn/server.pid
```

Você também pode verificar se a interface tun0 do OpenVPN está disponível digitando:

```bash
ip addr show tun0
```

Isto irá mostrar uma interface configurada:

```bash
3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::7db7:5314:c9e2:6a02/64 scope link flags 800
       valid_lft forever preferred_lft forever
```

Depois de iniciar o serviço, ative-o para que ele seja iniciado automaticamente na inicialização:

```bash
systemctl enable openvpn@server
```


## 8. Criando a Infra-estrutura de Configuração do Cliente

Comece criando um novo diretório onde você armazenará os arquivos de configuração do cliente no diretório ``/etc/openvpn/client/`` que você criou anteriormente:

```bash
mkdir -p /etc/openvpn/client/files
```

Copie um exemplo de arquivo de configuração do cliente no diretório ``client-configs`` para usar como sua configuração base:

```bash
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/
```

Abra este novo arquivo no seu editor de texto:

```bash
vi /etc/openvpn/client/client.conf
```

Dentro, localize a diretiva ``remote``. Isso aponta o cliente para o endereço do servidor OpenVPN - o endereço IP público do seu servidor OpenVPN. Se você decidiu alterar a porta na qual o servidor OpenVPN está escutando, você também precisará alterar ``1194`` para a porta selecionada:

```bash
remote ip-do-servidor 1194
```

Certifique-se de que o protocolo corresponda ao valor que você está usando na configuração do servidor:

```bash
proto udp
```

Em seguida, descomente as diretivas de ``user`` e ``group`` removendo o ``;`` no começo de cada linha:

```bash
user nobody
group nogroup
```

Encontre as diretivas que definem o ``ca``, o ``cert`` e a ``key``. Comente estas diretivas já que você adicionará os certs e chaves dentro do próprio arquivo:

```bash
# SSL/TLS parms.
# See the server config file for more
# description.  It's best to use
# a separate .crt/.key file pair
# for each client.  A single ca
# file can be used for all clients.
#ca ca.crt
#cert client.crt
#key client.key
```

Da mesma forma, comente a diretiva ``tls-auth``, pois você adicionará ``ta.key`` diretamente ao arquivo de configuração do cliente:

```bash
# If a tls-auth key is used on the server
# then every client must also have the key.
#tls-auth ta.key 1
```

Espelhe as configurações de criptografia e autenticação que você definiu no arquivo ``/etc/openvpn/server.conf``:

```bash
cipher AES-256-CBC
auth SHA256
```

Em seguida, adicione a diretiva ``key-direction`` em algum lugar no arquivo. Você **deve** definir isso para ``1`` para a VPN funcionar corretamente na máquina cliente:

```bash
key-direction 1
```

Por fim, adicione algumas linhas **comentadas**. Embora você possa incluir essas diretivas em cada arquivo de configuração do cliente, você só precisa habilitá-las para os clientes Linux fornecidos com um arquivo ``/etc/openvpn/update-resolv-conf``. Este script usa o utilitário ``resolvconf`` para atualizar as informações do DNS para clientes Linux.

```bash
# script-security 2
# up /etc/openvpn/update-resolv-conf
# down /etc/openvpn/update-resolv-conf
```

Se o seu cliente estiver executando  em um Linux e tiver um arquivo ``/etc/openvpn/update-resolv-conf``, remova o comentário dessas linhas do arquivo de configuração do cliente depois que ele for gerado.

Em seguida, crie um script simples que compile sua configuração básica com os arquivos relevantes de certificado, chave e criptografia e em seguida, coloque a configuração gerada no diretório ``/etc/openvpn/client/files``. Abra um novo arquivo chamado ``make_config.sh`` dentro do diretório ``/etc/openvpn/client``:

```bash
vi /etc/openvpn/make_config.sh
```


```bash
#!/bin/bash

# First argument: Client identifier

KEY_DIR=/etc/openvpn/client/keys
OUTPUT_DIR=/etc/openvpn/client/files
BASE_CONFIG=/etc/openvpn/client/client.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn
```

Antes de prosseguir, certifique-se de marcar este arquivo como executável digitando:

```bash
chmod 700 /etc/openvpn/make_config.sh
```

Este script fará uma cópia do arquivo ``client.conf`` que você fez, coletará todos os arquivos de certificados e chaves que você criou para o seu cliente, extrairá seu conteúdo, os anexará à cópia do arquivo de configuração base e exportará tudo isso em um novo arquivo de configuração de cliente. Isso significa que, em vez de precisar gerenciar a configuração do cliente, o certificado e os arquivos de chave separadamente, todas as informações necessárias são armazenadas em um único local. O benefício disso é que, se você precisar adicionar um cliente no futuro, basta executar esse script para criar rapidamente o arquivo de configuração e garantir que todas as informações importantes sejam armazenadas em um único local de fácil acesso.

> _**NOTA**_: Sempre que você adicionar um novo cliente, precisará gerar novas chaves e certificados para ele antes de poder executar esse script e gerar seu arquivo de configuração. Você terá alguma prática usando esse script na próxima etapa.

Ao final você deve ter um arquivo semelhante ao seguinte:

```bash
client
dev tun
proto udp
remote ip-do-servidor 1194
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
#ca ca.crt
#cert client.crt
#key client.key
remote-cert-tls server
#tls-auth ta.key 1
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
# script-security 2
# up /etc/openvpn/update-resolv-conf
# down /etc/openvpn/update-resolv-conf
```

## 9. Gerando Configurações de Cliente

Se você seguiu junto com o guia, você criou um certificado de cliente e uma chave chamada ``client1.crt`` e ``client1.key``, respectivamente, na Etapa 4. Você pode gerar um arquivo de configuração para essas credenciais, movendo-se para o diretório ``/etc/openvpn/client/`` e executando o script que você fez no final da etapa anterior:

```bash
/etc/openvpn/make_config.sh client1
```

Isto irá criar um arquivo chamado ``client1.ovpn`` no seu diretório ``/etc/openvpn/client/files``:

```bash
ls /etc/openvpn/client/files
```

```bash
client1.ovpn
```

## 10. Instalando a Configuração do Cliente

Se você estiver usando o Linux, há uma variedade de ferramentas que você pode usar dependendo da sua distribuição. Seu ambiente de área de trabalho ou gerenciador de janelas também pode incluir utilitários de conexão.

A maneira mais universal de conexão, no entanto, é apenas usar o software OpenVPN.

No Ubuntu ou Debian, você pode instalá-lo exatamente como no servidor digitando:

```bash
apt update
apt install openvpn
```

#### Configurando

Verifique se sua distribuição inclui um script ``/etc/openvpn/update-resolv-conf``,edite o arquivo de configuração do cliente OpenVPN:

```bash
vi /etc/openvpn/client1.ovpn
```

Se você conseguiu encontrar um arquivo ``update-resolv-conf``, descomente as três linhas adicionadas para ajustar as configurações de DNS:

```bash
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

Agora, você pode se conectar à VPN apenas apontando o comando ``openvpn`` para o arquivo de configuração do cliente:

```bash
openvpn --config client1.ovpn
```


## 11. Revogando Certificados de Cliente

Ocasionalmente, você pode precisar revogar um certificado de cliente para evitar acesso futuro ao servidor OpenVPN.

Para fazer isso, navegue até o diretório EasyRSA:

```bash
cd /etc/openvpn/EasyRSA-v3.0.6
```

Em seguida, execute o script ``easyrsa`` com a opção ``revoke``, seguida pelo nome do cliente que você deseja revogar:

```bash
./easyrsa revoke client2
```

Isso pedirá que você confirme a revogação digitando ``yes``:

```bash
Please confirm you wish to revoke the certificate with the following subject:

subject=
    commonName                = client1


Type the word 'yes' to continue, or any other input to abort.
  Continue with revocation: yes
```

Após confirmar a ação, o CA revogará totalmente o certificado do cliente. No entanto, seu servidor OpenVPN atualmente não tem como verificar se os certificados de algum cliente foram revogados e o cliente ainda terá acesso à VPN. Para corrigir isso, crie uma lista de revogação de certificado (CRL) em sua máquina CA:

```bash
./easyrsa gen-crl
```

Isso irá gerar um arquivo chamado ``crl.pem``:

```bash
An updated CRL has been created.
CRL file: /etc/openvpn/EasyRSA-v3.0.6/pki/crl.pem
```

Copie este arquivo em seu diretório ``/etc/openvpn/``:

```bash
cp /etc/openvpn/EasyRSA-v3.0.6/pki/crl.pem /etc/openvpn
```

Em seguida, abra o arquivo de configuração do servidor OpenVPN:

```bash
vi /etc/openvpn/server.conf
```

No final do arquivo, adicione a opção ``crl-verify``, que instruirá o servidor OpenVPN a verificar a lista de revogação de certificado que criamos sempre que uma tentativa de conexão é feita:

```bash
crl-verify crl.pem
```

Finalmente, reinicie o OpenVPN para implementar a revogação do certificado:

```bash
systemctl restart openvpn@server
```

O cliente não deve conseguir conectar-se com êxito ao servidor usando a credencial antiga.

Para revogar clientes adicionais, siga este processo:

1. Revogar o certificado com o comando ``./easyrsa revoke nome_do_cliente``

1. Gere uma nova CRL

1. Transfira o novo arquivo ``crl.pem`` para o seu servidor OpenVPN e copie-o para o diretório ``/etc/openvpn`` para sobrescrever a lista antiga.

1. Reinicie o serviço OpenVPN.

Você pode usar esse processo para revogar todos os certificados que você emitiu anteriormente para o seu servidor.


Fonte: [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-debian-9)