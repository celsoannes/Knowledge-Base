# Como configurar OpenVPN para Yealink no Debian 11

## Sobre VPN

VPN (Virtual Private Network) é uma rede que usa uma infraestrutura publica de telecomunicação, como a internet, para prover escritórios remoto ou usuários em deslocamento um acesso seguro a rede da empresa. VPN da a empresa a vantagem de criar canais seguros de comunicação ,enquanto ao mesmo tempo reduz custos, melhorando a segurança e aumentando o desempenho.

Existem dois tipos de acesso VPN: **remote-access** e **site-to-site**.

## Tipos de Acesso VPN

* **Remote-Acess VPN**: também chamado de rede virtual privada discada (virtual private dial-up network - VPDN), é uma usuário-para-LAN (user-to-LAN) conexão usada por uma empresa que possui funcionários que necessitam se conectar a rede privada a partir de vários locais remotos.
* **Site-to-site VPN**: conecta redes inteiras umas as outras, isto significa, site-to-site VPN (local-para-local) pode ser usada para conectar uma filial ou escritório remoto a rede da matriz da empresa. Cada local é equipado com um acesso VPN, tal como um roteador, firewall, concentrador VPN ou ferramenta de segurança.
 

## 1. Instalando OpenVPN e EasyRSA

Para começar atualize o indice de pacotes e instale o OpenVPN.

```shell
apt-get update
apt install openvpn
```

Instale o EasyRSA que será usado para construir o Certificado de Autoridade (CA):

```shell
apt update
apt install easy-rsa
```

## 2. Preparando um Diretório de Infraestrutura de Chave Pública

Agora que você instalou o easy-rsa, é hora de criar uma estrutura básica da Infraestrutura de Chave Pública (PKI) no servidor da Autoridade de Certificação (CA).

```shell
cd /etc/openvpn
mkdir /etc/openvpn/easy-rsa
```

Crie um link simbólico com o comando `ln`:

```shell
ln -s /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
```

Para restringir o acesso ao seu novo diretório PKI, assegure-se de que apenas o proprietário possa acessá-lo utilizando o comando `chmod`:

```shell
chmod 700 /etc/openvpn/easy-rsa/
```

Finalmente, inicialize a PKI dentro do diretório easy-rsa:

```shell
cd /etc/openvpn/easy-rsa/
./easyrsa init-pki
```

Você verá a seguinte mensagem:

```shell
init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/pki
```

Após completar esta seção, você terá um diretório que contém todos os arquivos necessários para criar uma Autoridade de Certificação. Na próxima seção, você criará a chave privada e o certificado público para a sua CA.

## 3. Criando uma Autoridade de Certificação

Antes de criar a chave privada e o certificado da sua CA, você precisa criar e preencher um arquivo chamado `vars` com alguns valores padrão. Primeiro, você irá navegar para o diretório `easy-rsa` e, em seguida, criará e editará o arquivo `vars` com o `vi` ou o seu editor de texto preferido:

````shell
cd /etc/openvpn/easy-rsa/
vi vars
````

Assim que o arquivo for aberto, cole as seguintes linhas e edite cada valor destacado para refletir as informações da sua própria organização. A parte importante aqui é garantir que você não deixe nenhum dos valores em branco:

````shell
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "California"
set_var EASYRSA_REQ_CITY       "San Francisco"
set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co"
set_var EASYRSA_REQ_EMAIL      "me@example.net"
set_var EASYRSA_REQ_OU         "Yealink"
set_var EASYRSA_DIGEST         "sha1" 
````

> NOTA:  Certifique-se de alterar `EASYRSA_DIGEST` para `sha1` caso contrário modelos mais antigos que entraram em [EoL](https://www.yealink.com/en/product-list/eol-products) até 2015 e que foram descontinuados não possuem suporte a `cipher` mais recentes como por exemplo `sha256` e `sha512`.

Para criar o par de chaves pública e privada raiz para a sua Autoridade de Certificação, execute novamente o comando `./easy-rsa`, desta vez com a opção `build-ca`:

````shell
./easyrsa --days=3650 build-ca nopass
````

* `--days=3650`: Esta opção define a validade do certificado da CA em dias. Neste caso, o certificado da CA será válido por `3650` dias, o que é equivalente a **10 anos**.
- `build-ca`: Esta é o subcomando do EasyRSA para construir uma autoridade de certificação (CA). Quando você executa `build-ca`, o EasyRSA guia você através do processo de criação de uma CA, incluindo a geração de chaves e certificados necessários.
- `nopass`: Esta opção indica que não será solicitada uma senha durante a criação da CA. Isso é útil em scripts ou quando você deseja automatizar o processo de criação da CA.

Na saída, você verá algumas linhas sobre a versão do OpenSSL, será solicitado que você confirme o _Nome Comum_ (CN) para a sua Autoridade de Certificação. O CN é o nome usado para se referir a esta máquina no contexto da Autoridade de Certificação. Você pode digitar qualquer sequência de caracteres para o Nome Comum da CA, mas por simplicidade, pressione **ENTER** para aceitar o nome padrão.

````shell
...
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/pki/ca.crt
````


Agora você possui dois arquivos importantes — `/etc/openvpn/easy-rsa/pki/ca.crt` e `/etc/openvpn/easy-rsa/pki/private/ca.key` — que compõem os componentes públicos e privados de uma Autoridade de Certificação.

* `ca.crt` é o arquivo de certificado público da CA. Usuários, servidores e clientes usarão este certificado para verificar que fazem parte da mesma rede de confiança. Todos os usuários e servidores que usam a sua CA precisarão ter uma cópia deste arquivo. Todas as partes dependerão do certificado público para garantir que alguém não esteja se passando por um sistema e realizando um ataque **Man-in-the-middle**.
* `ca.key` é a chave privada que a CA usa para assinar certificados para servidores e clientes. Se um invasor ganhar acesso à sua CA e, por consequência, ao seu arquivo `ca.key`, você precisará destruir sua CA. É por isso que seu arquivo `ca.key` deve estar **apenas** na sua máquina da CA e por que, idealmente, sua máquina da CA deve ficar offline quando não estiver assinando solicitações de certificado, como medida de segurança adicional.

Com isso, a sua CA está configurada e pronta para ser usada para assinar solicitações de certificado e revogar certificados.


## 4. Criando o Certificado do Servidor, Chave e Arquivos de Criptografia

Mude para o diretório `/etc/openvpn/easy-rsa/` e execute o script `easyrsa` com a opção `gen-req`, seguida por um nome comum para a máquina. Isso pode ser qualquer coisa que você deseje, mas pode ser útil escolher algo descritivo. Ao longo deste tutorial, o nome comum do servidor OpenVPN será simplesmente "server". Certifique-se de incluir também a opção `nopass`. Não fazer isso irá proteger o arquivo de solicitação com uma senha, o que poderia causar problemas de permissão mais tarde:

> Nota: Se você escolher um nome diferente de "server" aqui, será necessário ajustar algumas das instruções a seguir. Por exemplo, ao copiar os arquivos gerados para o diretório `/etc/openvpn`, você terá que substituir os nomes corretos. Você também terá que modificar o arquivo `/etc/openvpn/server.conf` posteriormente para apontar para os arquivos `.crt` e `.key` corretos.

````shell
cd /etc/openvpn/easy-rsa/
./easyrsa --days=3650 gen-req server nopass
````

* `gen-req`: Esta é a subcomando do EasyRSA para gerar uma solicitação de certificado (CSR). Ao executar `gen-req`, o EasyRSA solicitará informações necessárias para gerar a CSR, como nome do servidor, organização, localização, etc.
* `server`: Este é o nome do certificado que está sendo gerado. É comum usar "server" para identificar certificados de servidor, mas pode ser substituído por qualquer outra identificação útil.

O script irá solicitar o nome comum que você deseja que apareça na solicitação de assinatura do certificado (CSR). Por padrão, ele mostrará o nome que você passou para o comando `./easyrsa gen-req` (por exemplo, `server`). Pressione `ENTER` para aceitar o nome padrão ou insira um nome diferente.

Isso criará uma chave privada para o servidor e um arquivo de solicitação de certificado chamado `server.req`.

Em seguida, assine a solicitação executando o `easyrsa` com a opção `sign-req`, seguida pelo tipo de solicitação e pelo nome comum. O tipo de solicitação pode ser cliente (`client`) ou servidor (`server`), portanto, para a solicitação de certificado do servidor OpenVPN, certifique-se de usar o tipo de solicitação servidor (`server`):

````shell
./easyrsa sign-req server server
````

Na saída, você será solicitado a verificar se a solicitação vem de uma fonte confiável. Digite `yes` e pressione **ENTER** para confirmar isso:

````shell
You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
````

Se você criptografou a chave da sua AC enquanto seguia o tutorial listado nos pré-requisitos, você será solicitado a digitar sua frase secreta neste ponto.

O seu servidor **OpenVPN** precisa do arquivo `ca.crt` para saber que pode confiar na entidade que assinou o arquivo `server.crt`.

Em seguida, copie os arquivos `server.key`, `server.crt` e `ca.crt` para o diretório `/etc/openvpn/keys`, mas como `keys` ainda não existe, vamos crial-lo primeiro:

````shell
mkdir -v /etc/openvpn/server/keys
cp -v /etc/openvpn/easy-rsa/pki/private/server.key /etc/openvpn/server/keys
cp -v /etc/openvpn/easy-rsa/pki/issued/server.crt /etc/openvpn/server/keys
cp -v /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/server/keys
````

Volte para o diretório `/etc/openvpn/easy-rsa`:

````shell
cd /etc/openvpn/easy-rsa
````

A partir daí, crie uma chave Diffie-Hellman forte para usar durante a troca de chaves, digitando:

````shell
./easyrsa gen-dh
````

> NOTA: Isso pode levar alguns minutos para ser concluído.

Quando o comando terminar, copie o arquivo para o seu diretório `/etc/openvpn/server/keys`:

````shell
cp -v /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/server/keys
````

Com isso, todos os arquivos de certificado e chave necessários para o seu servidor foram gerados. Você está pronto para criar os certificados e chaves correspondentes que sua máquina cliente usará para acessar o seu servidor OpenVPN.


## 5. Gerando um Par de Certificado e Chave para Cliente

Neste passo, você primeiro irá gerar o par de chave e certificado para o ramal. Se você tiver mais de um ramal, pode repetir esse processo para cada um. No entanto, observe que você precisará passar um valor de nome exclusivo para o script para cada ramal. Ao longo deste tutorial, o primeiro par de certificado/chave é chamado de `2000`.

Comece criando uma estrutura de diretórios dentro do seu diretório home para armazenar os arquivos de certificado e chave do cliente:

````shell
mkdir -v -p /etc/openvpn/client
````

Como você irá armazenar os pares de certificado/chave e os arquivos de configuração dos seus clientes neste diretório, você deve restringir as permissões agora como medida de segurança:

````shell
chmod -R 700 /etc/openvpn/client
````
Em seguida, volte para o diretório `easy-rsa` e execute o script `easyrsa` com as opções `gen-req` e `nopass`, juntamente com o nome comum do ramal, para o exemplo usarei o número `2000`:

````shell
cd /etc/openvpn/easy-rsa
./easyrsa gen-req 2000 nopass
````

Pressione `ENTER` para confirmar o nome comum.

Em seguida, assine a solicitação como fez para o servidor no passo anterior. Desta vez, no entanto, certifique-se de especificar o tipo de solicitação do cliente:

````shell
./easyrsa --days=3650 sign-req client 2000
````

Na prompt, digite `yes` para confirmar que você pretende assinar a solicitação de certificado e que ela veio de uma fonte confiável:

````shell
Request subject, to be signed as a client certificate for 3650 days:

subject=
    commonName                = 2000


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
````

Isso criará um arquivo de certificado de cliente chamado `2000.crt`.

Crie uma pasta com o número do ramal e no mesmo comando ja será criado uma pasta para receber as chaves:

````shell
mkdir -v -p /etc/openvpn/client/2000/keys
````

````shell
mkdir: foi criado o diretório '/etc/openvpn/client/2000'
mkdir: foi criado o diretório '/etc/openvpn/client/2000/keys'
````

Copie as chaves do ramal para o diretório recém criado:


````shell
cp -v /etc/openvpn/easy-rsa/pki/issued/2000.crt /etc/openvpn/client/2000/keys/
````

Em seguida, copie os arquivos `ca.crt`, `2000.key` para o diretório do ramal também:

````shell
cp -v /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client/2280/keys/
cp -v /etc/openvpn/easy-rsa/pki/private/2000.key /etc/openvpn/client/2000/keys/
````

Com isso, os certificados e chaves do seu servidor e cliente foram todos gerados e estão armazenados nos diretórios apropriados no seu servidor. Ainda há algumas ações que precisam ser realizadas com esses arquivos. Por enquanto, você pode prosseguir para configurar o OpenVPN no seu servidor.

## 6. Passo 4 — Configurando o Serviço OpenVPN

Agora que tanto os certificados e chaves do cliente quanto do servidor foram gerados, você pode começar a configurar o serviço OpenVPN para usar essas credenciais.

Para você não ter que sofrer como eu sofi, vamos direto ao ponto de como você deve configurar o  arquivo `server.conf`:

````shell
port 1194
proto udp
dev tun
ca /etc/openvpn/server/keys/ca.crt
cert /etc/openvpn/server/keys/server.crt
key /etc/openvpn/server/keys/server.key
dh /etc/openvpn/server/keys/dh2048.pem
server 10.8.0.0 255.255.255.0
client-config-dir /etc/openvpn/staticclients
keepalive 10 120
comp-lzo
persist-key
persist-tun
status  /var/log/openvpn/openvpn-status.log
log /var/log/openvpn/openvpn.log
log-append  /var/log/openvpn/openvpn.log
verb 3
````

### Ajustando a Configuração de Rede do Servidor
Existem alguns aspectos da configuração de rede do servidor que precisam ser ajustados para que o OpenVPN possa rotear corretamente o tráfego através da VPN. O primeiro deles é o encaminhamento de IP, um método para determinar para onde o tráfego IP deve ser roteado.

Ajuste a configuração padrão de encaminhamento de IP do seu servidor modificando o arquivo `/etc/sysctl.conf`:

````shell
vi /etc/sysctl.conf
````

Dentro do arquivo, procure a linha comentada que define `net.ipv4.ip_forward`. Remova o caractere `#` do início da linha para descomentar essa configuração:

````shell
net.ipv4.ip_forward=1
````

Salve e feche o arquivo quando terminar.

Para ler o arquivo e ajustar os valores para a sessão atual, digite:

````shell
sudo sysctl -p
````

## 7. Iniciando e Habilitando o Serviço OpenVPN

Finalmente, você está pronto para iniciar o serviço OpenVPN no seu servidor. Isso é feito usando a ferramenta `systemd systemctl`:

````shell
systemctl start openvpn@server
````

Você também pode verificar se a interface OpenVPN tun0 está disponível digitando:

````shell
ip addr show tun0
````

Isso mostrará uma interface configurada:

````shell
3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::102c:8ef2:b44a:8f41/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
````

Após iniciar o serviço, habilite-o para que ele inicie automaticamente durante a inicialização:

````shell
sudo systemctl enable openvpn@server
````


## 8. Criando a Infraestrutura de Configuração do Ramal para o Yealink

Como as chaves e certificado já foram criados e copiados para o diretório do ramal `2000`, agora vamos criar o arquivo `vpn.cnf` com o seu editor de preferencia, no meu caso usarei o `vi`:

````shell
vi /etc/openvpn/client/2000/vpn.cnf
````

Em seguida, copie as configuração abaixo para o arquivo `vpn.cnf`:

````shell
client
setenv SERVER_Poll_TIMEOUT 4
nobind
proto udp
remote 192.168.0.1
dev tun
dev-type tun
persist-tun
persist-key
ns-cert-type server
ca /config/openvpn/keys/ca.crt
cert /config/openvpn/keys/2000.crt
key /config/openvpn/keys/2000.key
comp-lzo
````

Para finalizar, faça a compactação dos arquivos no formato 

````shell
cd /etc/openvpn/client/2000
tar -cvpf yealink_vpn_2000.tar *
````

## Pegando um Atalho

Agora que você ja entendeu como funciona, vamos facilitar o processo de criação dos proximos pacotes de vpn para os ramais.

Baixe o arquivo [vpn.cnf](./scripts/vpn.cnf) com o comando abaixo:

````shell
touch /etc/openvpn/client/vpn.cnf
````

Copie o conteúdo abaixo para o arquivo `vpn.cnf`

````shell

````

Crie um arquivo chamado `vpn_yealink.sh`:

````shell
touch /etc/openvpn/client/vpn_yealink.sh
````

De permissão de execução:

````shell
chmod +x /etc/openvpn/client/vpn_yealink.sh
````

Copie o conteudo abaixo para dentro do arquivo `vpn_yealink.sh`:

````shell
#!/bin/bash

# Script: openvpn_yealink.sh
# Author: Celso Annes
# Contact: celso@finti.com.br
# Date: 2024-03-21

# Verifica se foi passado o ramal como argumento
if [ -z "$1" ]; then
    echo "Por favor, especifique o número do ramal como argumento."
    exit 1
fi

RAMAL=$1

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
````

Agora execute o script informe o ramal e veja a mágica acontecer:

````shell
./openvpn_yealink.sh 2001
````