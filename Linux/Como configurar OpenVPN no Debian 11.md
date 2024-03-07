# Como configurar OpenVPN no Debian 11

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
set_var EASYRSA_REQ_COUNTRY    "BR"
set_var EASYRSA_REQ_PROVINCE   "Rio Grande do Sul"
set_var EASYRSA_REQ_CITY       "Novo Hamburgo"
set_var EASYRSA_REQ_ORG        "3WM"
set_var EASYRSA_REQ_EMAIL      "admin@example.com"
set_var EASYRSA_REQ_OU         "Proxmox"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512" 
````

Para criar o par de chaves pública e privada raiz para a sua Autoridade de Certificação, execute novamente o comando `./easy-rsa`, desta vez com a opção `build-ca`:

````shell
./easyrsa build-ca
````

Na saída, você verá algumas linhas sobre a versão do OpenSSL e será solicitado a digitar uma frase secreta para o seu par de chaves. Certifique-se de escolher uma frase secreta forte e anote-a em um local seguro. Você precisará inserir a frase secreta sempre que precisar interagir com a sua CA, por exemplo, para assinar ou revogar um certificado.

Também será solicitado que você confirme o Nome Comum (CN) para a sua Autoridade de Certificação. O CN é o nome usado para se referir a esta máquina no contexto da Autoridade de Certificação. Você pode digitar qualquer sequência de caracteres para o Nome Comum da CA, mas por simplicidade, pressione **ENTER** para aceitar o nome padrão.

````shell
...
Enter New CA Key Passphrase:
Re-Enter New CA Key Passphrase:
...
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/pki/ca.crt
````
>Nota: Se você não quiser ser solicitado a digitar uma senha sempre que interagir com a sua CA, você pode executar o comando build-ca com a opção nopass, da seguinte maneira:
> ```shell
> ./easyrsa build-ca nopass
> ```

Agora você possui dois arquivos importantes — `/etc/openvpn/easy-rsa/pki/ca.crt` e `/etc/openvpn/easy-rsa/pki/private/ca.key` — que compõem os componentes públicos e privados de uma Autoridade de Certificação.

* `ca.crt` é o arquivo de certificado público da CA. Usuários, servidores e clientes usarão este certificado para verificar que fazem parte da mesma rede de confiança. Todos os usuários e servidores que usam a sua CA precisarão ter uma cópia deste arquivo. Todas as partes dependerão do certificado público para garantir que alguém não esteja se passando por um sistema e realizando um ataque **Man-in-the-middle**.
* `ca.key` é a chave privada que a CA usa para assinar certificados para servidores e clientes. Se um invasor ganhar acesso à sua CA e, por consequência, ao seu arquivo `ca.key`, você precisará destruir sua CA. É por isso que seu arquivo `ca.key` deve estar **apenas** na sua máquina da CA e por que, idealmente, sua máquina da CA deve ficar offline quando não estiver assinando solicitações de certificado, como medida de segurança adicional.

Com isso, a sua CA está configurada e pronta para ser usada para assinar solicitações de certificado e revogar certificados.


## 4. Criando o Certificado do Servidor, Chave e Arquivos de Criptografia

Mude para o diretório `/etc/openvpn/easy-rsa/` e execute o script `easyrsa` com a opção `gen-req`, seguida por um nome comum para a máquina. Isso pode ser qualquer coisa que você deseje, mas pode ser útil escolher algo descritivo. Ao longo deste tutorial, o nome comum do servidor OpenVPN será simplesmente "server". Certifique-se de incluir também a opção `nopass`. Não fazer isso irá proteger o arquivo de solicitação com uma senha, o que poderia causar problemas de permissão mais tarde:

> Nota: Se você escolher um nome diferente de "server" aqui, será necessário ajustar algumas das instruções a seguir. Por exemplo, ao copiar os arquivos gerados para o diretório `/etc/openvpn`, você terá que substituir os nomes corretos. Você também terá que modificar o arquivo `/etc/openvpn/server.conf` posteriormente para apontar para os arquivos `.crt` e `.key` corretos.

````shell
cd /etc/openvpn/easy-rsa/
./easyrsa gen-req server nopass
````

O script irá solicitar o nome comum que você deseja que apareça na solicitação de assinatura do certificado (CSR). Por padrão, ele mostrará o nome que você passou para o comando `./easyrsa gen-req` (por exemplo, `server`). Pressione ENTER para aceitar o nome padrão ou insira um nome diferente.

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

Request subject, to be signed as a server certificate for 825 days:

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
````

Se você criptografou a chave da sua AC enquanto seguia o tutorial listado nos pré-requisitos, você será solicitado a digitar sua frase secreta neste ponto.

O seu servidor **OpenVPN** precisa do arquivo `ca.crt` para saber que pode confiar na entidade que assinou o arquivo `server.crt`.

Em seguida, copie os arquivos `server.key`, `server.crt` e `ca.crt` para o diretório `/etc/openvpn/keys`, mas como `keys` ainda não existe, vamos crial-lo primeiro:

````shell
mkdir /etc/openvpn/keys
cp /etc/openvpn/easy-rsa/pki/private/server.key /etc/openvpn/keys
cp /etc/openvpn/easy-rsa/pki/issued/server.crt /etc/openvpn/keys
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/keys
````

Volte para o diretório `/etc/openvpn/easy-rsa`:

A partir daí, crie uma chave Diffie-Hellman forte para usar durante a troca de chaves, digitando:

````shell
./easyrsa gen-dh
````

Isso pode levar alguns minutos para ser concluído. Assim que terminar, gere uma assinatura HMAC para fortalecer as capacidades de verificação de integridade TLS do servidor:

````shell
openvpn --genkey secret ta.key
````

Quando o comando terminar, copie os dois novos arquivos para o seu diretório `/etc/openvpn/keys`:

````shell
cp /etc/openvpn/easy-rsa/ta.key /etc/openvpn/keys
cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/keys
````

Com isso, todos os arquivos de certificado e chave necessários para o seu servidor foram gerados. Você está pronto para criar os certificados e chaves correspondentes que sua máquina cliente usará para acessar o seu servidor OpenVPN.


## 5. Gerando um Par de Certificado e Chave para Cliente

Embora você possa gerar uma chave privada e uma solicitação de certificado em sua máquina cliente e, em seguida, enviá-la para a CA para ser assinada, este guia apresenta um processo para gerar a solicitação de certificado no servidor VPN. A vantagem disso é que podemos criar um script do servidor que irá gerar automaticamente arquivos de configuração do cliente que contêm todas as chaves, certificados e opções de configuração necessárias em um único arquivo. Normalmente, o arquivo de configuração principal do cliente especificaria os nomes de arquivos separados para chaves e certificados, e você teria que distribuir vários arquivos para cada cliente. Mas é muito melhor incluir todo o corpo das chaves e do certificado dentro do próprio arquivo de configuração principal para simplificar o processo de conexão à VPN. Você gerará esse único arquivo de configuração do cliente no Passo 8.

Neste passo, você primeiro irá gerar o par de chave e certificado para o cliente. Se você tiver mais de um cliente, pode repetir esse processo para cada um. No entanto, observe que você precisará passar um valor de nome exclusivo para o script para cada cliente. Ao longo deste tutorial, o primeiro par de certificado/chave é chamado de `cliente1`.

Comece criando uma estrutura de diretórios dentro do seu diretório home para armazenar os arquivos de certificado e chave do cliente:

````shell
mkdir -p /etc/openvpn/client/keys
````

Como você irá armazenar os pares de certificado/chave e os arquivos de configuração dos seus clientes neste diretório, você deve restringir as permissões agora como medida de segurança:

````shell
chmod -R 700 /etc/openvpn/client/keys
````
Em seguida, volte para o diretório `easy-rsa` e execute o script `easyrsa` com as opções `gen-req` e `nopass`, juntamente com o nome comum do cliente:

````shell
cd /etc/openvpn/easy-rsa
./easyrsa gen-req client1 nopass
````

Pressione **ENTER** para confirmar o nome comum.

Em seguida, assine a solicitação como fez para o servidor no passo anterior. Desta vez, no entanto, certifique-se de especificar o tipo de solicitação do cliente:

````shell
./easyrsa sign-req client client1
````

Na prompt, digite `yes` para confirmar que você pretende assinar a solicitação de certificado e que ela veio de uma fonte confiável:

````shell
subject=
    commonName                = client1


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
````

Novamente, se você criptografou a chave da sua AC, será solicitado a digitar sua frase secreta aqui.

Isso criará um arquivo de certificado de cliente chamado `client1.crt`.

Copie o certificado do cliente para o diretório `/etc/openvpn/client/keys`:

````shell
cp /etc/openvpn/easy-rsa/pki/issued/client1.crt /etc/openvpn/client/keys
````

Em seguida, copie os arquivos `ca.crt` e `ta.key` para o diretório `/etc/openvpn/client/keys` também:

````shell
cp /etc/openvpn/easy-rsa/ta.key /etc/openvpn/client/keys
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client/keys
````

Com isso, os certificados e chaves do seu servidor e cliente foram todos gerados e estão armazenados nos diretórios apropriados no seu servidor. Ainda há algumas ações que precisam ser realizadas com esses arquivos. Por enquanto, você pode prosseguir para configurar o OpenVPN no seu servidor.

## 6. Passo 4 — Configurando o Serviço OpenVPN

Agora que tanto os certificados e chaves do cliente quanto do servidor foram gerados, você pode começar a configurar o serviço OpenVPN para usar essas credenciais.

Comece copiando um arquivo de configuração de exemplo do OpenVPN para o diretório de configuração para usar como base para a sua configuração:

````shell
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
````

Abra o arquivo de configuração do servidor no seu editor de texto preferido:

````shell
vi /etc/openvpn/server.conf
````

Localize a seção HMAC procurando pela diretiva `tls-auth`. Essa linha já deve estar descomentada, mas se não estiver, remova o ";" para descomentá-la.

````shell
tls-auth ta.key 0 # This file is secret
````
Para:
````shell
tls-auth /etc/openvpn/keys/ta.key 0 # This file is secret
````

A seguir, altere o valor da cifra criptográfica procurando as linhas de cifra. O valor padrão está definido como `AES-256-CBC`. Comente o valor padrão e adicione outra linha com a criptografia `AES-256-GCM`, que oferece um melhor nível de criptografia e desempenho, como mostrado abaixo.

````shell
;cipher AES-256-CBC
cipher AES-256-GCM
````

Abaixo disso, adicione uma diretiva "auth" para selecionar o algoritmo de resumo de mensagem HMAC. Para isso, SHA256 é uma boa escolha:

````shell
auth SHA256
````

Em seguida, encontre a linha que contém a diretiva `dh` que define os parâmetros Diffie-Hellman. Devido a algumas mudanças recentes feitas no Easy-RSA, o nome do arquivo para a chave Diffie-Hellman pode ser diferente do que está listado no exemplo de arquivo de configuração do servidor. Se necessário, altere o nome do arquivo listado aqui removendo o `2048` para que ele corresponda à chave que você gerou no passo anterior:

````shell
dh /etc/openvpn/keys/dh.pem
````

Por fim, encontre as configurações de `user` e `group` e remova o ";" no início de cada linha para descomentá-las:

````shell
user nobody
group nogroup
````

As alterações que você fez no arquivo `server.conf` de exemplo até este ponto são necessárias para que o OpenVPN funcione. As alterações descritas abaixo são opcionais, embora também sejam necessárias para muitos casos de uso comuns.

### Enviar Alterações de DNS para Redirecionar Todo o Tráfego Através da VPN (Opcional)
As configurações acima criarão a conexão VPN entre as duas máquinas, mas não forçarão que nenhuma conexão utilize o túnel. Se você deseja usar a VPN para rotear todo o seu tráfego, provavelmente desejará enviar as configurações de DNS para os computadores clientes.

Existem algumas diretivas no arquivo `server.conf` que você deve alterar para habilitar essa funcionalidade. Encontre a seção `redirect-gateway` e remova o ponto e vírgula ";" no início da linha `redirect-gateway` para descomentá-la:

````shell
push "redirect-gateway def1 bypass-dhcp"
````

Logo abaixo disso, encontre a seção `dhcp-option`. Novamente, remova o ";" na frente de ambas as linhas para descomentá-las:

````shell
push "dhcp-option DNS 208.67.222.222"
push "dhcp-option DNS 208.67.220.220"
````

Isso ajudará os clientes a reconfigurar suas configurações de DNS para usar o túnel VPN como o gateway padrão.

### Ajuste a Porta e o Protocolo (Opcional)
Por padrão, o servidor OpenVPN utiliza a porta `1194` e o protocolo UDP para aceitar conexões de clientes. Se você precisar usar uma porta diferente devido a ambientes de rede restritivos em que seus clientes podem estar, você pode alterar a opção `port`. Se você não estiver hospedando conteúdo da web no seu servidor OpenVPN, a porta `443` é uma escolha popular, pois geralmente é permitida pelas regras do firewall.

````shell
# Optional!
port 443
````

Muitas vezes, o protocolo também é restrito a essa porta. Se for esse o caso, altere `proto` de UDP para TCP:

````shell
# Optional!
proto tcp
````

Se você mudar o protocolo para TCP, você precisará alterar o valor da diretiva `explicit-exit-notify` de `1` para `0`, pois esta diretiva é usada apenas pelo UDP. Não fazer isso enquanto estiver usando TCP causará erros ao iniciar o serviço OpenVPN:

````shell
# Optional!
explicit-exit-notify 0
````

Se você não tem necessidade de usar uma porta e protocolo diferentes, é melhor deixar essas três configurações com seus valores padrão.


### Apontar para Credenciais Não-Padrão (Opcional)
Se você escolheu um nome diferente durante o comando `./easyrsa gen-req` para o certificado do servidor, modifique as linhas `cert` e `key` para apontar para os arquivos `.crt` e `.key` apropriados. Se você usou o nome padrão, "server", isso já está configurado corretamente:

````shell
cert server.crt
key server.key
````

Quando você terminar, salve e feche o arquivo.

Após revisar e fazer as alterações necessárias na configuração do OpenVPN do seu servidor de acordo com o seu caso de uso específico, você pode começar a fazer algumas alterações na rede do seu servidor.

### Ajustando a Configuração de Rede do Servidor
Existem alguns aspectos da configuração de rede do servidor que precisam ser ajustados para que o OpenVPN possa rotear corretamente o tráfego através da VPN. O primeiro deles é o encaminhamento de IP, um método para determinar para onde o tráfego IP deve ser roteado.

Ajuste a configuração padrão de encaminhamento de IP do seu servidor modificando o arquivo `/etc/sysctl.conf`:

````shell
vi /etc/sysctl.conf
````

Dentro do arquivo, procure a linha comentada que define `net.ipv4.ip_forward`. Remova o caractere "**#**" do início da linha para descomentar essa configuração:

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

O seu serviço OpenVPN agora está ativo e funcionando. No entanto, antes de começar a usá-lo, você precisa criar um arquivo de configuração para a máquina cliente. Este tutorial já explicou como criar pares de certificado/chave para os clientes, e o próximo passo irá demonstrar como criar uma infraestrutura que gerará arquivos de configuração do cliente.

## 8. Criando a Infraestrutura de Configuração do Cliente

Criar arquivos de configuração para clientes OpenVPN pode ser um processo um tanto complexo, já que cada cliente deve ter sua própria configuração que esteja alinhada com as configurações definidas no arquivo de configuração do servidor. Em vez de escrever um único arquivo de configuração que só possa ser usado em um cliente, este passo detalha um processo para construir uma infraestrutura de configuração de cliente que você pode usar para gerar arquivos de configuração sob demanda. Primeiro, você criará um arquivo de configuração "base" e, em seguida, executará um script que gerará arquivos de configuração de cliente exclusivos usando o arquivo de configuração base mais o certificado e as chaves exclusivas de um cliente.

Comece criando um novo diretório no seu servidor OpenVPN onde você armazenará os arquivos de configuração do cliente dentro do diretório `client` que você criou anteriormente:

````shell
mkdir -p /etc/openvpn/client/files
````
Em seguida, copie um arquivo de configuração de cliente de exemplo para o diretório `client` para usar como sua configuração base:

````shell
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/base.conf
````

Abra este novo arquivo no seu editor de texto:

````shell
vi /etc/openvpn/client/base.conf
````

Dentro do arquivo, localize a diretiva `remote`. Isso aponta o cliente para o endereço do seu servidor OpenVPN - o endereço IP público do seu servidor OpenVPN. Se você decidiu alterar a porta em que o servidor OpenVPN está ouvindo, também precisará alterar o `1194` para a porta que você selecionou:

````shell
# The hostname/IP and port of the server.
# You can have multiple remote entries
# to load balance between the servers.
remote my-server-1 1194
````

Certifique-se de que o protocolo corresponde ao valor que você está usando na configuração do servidor:

````shell
proto udp
````

Em seguida, descomente as diretivas `user` e `group` removendo o ";" no início de cada linha:

````shell
# Downgrade privileges after initialization (non-Windows only)
user nobody
group nogroup
````

Encontre as diretivas que definem os arquivos `ca`, `cert` e `key`. Comente essas diretivas, já que você irá anexar o conteúdo completo dos arquivos de certificado e chave ao arquivo base em breve:

````shell
# SSL/TLS parms.
# See the server config file for more
# description.  It's best to use
# a separate .crt/.key file pair
# for each client.  A single ca
# file can be used for all clients.
#ca ca.crt
#cert client.crt
#key client.key
````

Da mesma forma, comente a diretiva `tls-auth`, já que você irá adicionar o arquivo `ta.key` diretamente no arquivo de configuração do cliente:

````shell
# If a tls-auth key is used on the server
# then every client must also have the key.
#tls-auth ta.key 1
````

Espelhe as configurações de cifra (`cipher`) e autenticação (`auth`) que você definiu no arquivo `/etc/openvpn/server.conf`:

````shell
cipher AES-256-CBC
auth SHA256
````

Em seguida, adicione a diretiva `key-direction` em algum lugar do arquivo. Você deve definir isso como "1" para que a VPN funcione corretamente na máquina cliente:

````shell
key-direction 1
````

Por fim, adicione algumas linhas comentadas. Embora você possa incluir essas diretivas em cada arquivo de configuração do cliente, você só precisa ativá-las para clientes Linux que tenham o arquivo `/etc/openvpn/update-resolv-conf`. Este script utiliza a ferramenta `resolvconf` para atualizar as informações de DNS para clientes Linux:

````shell
# script-security 2
# up /etc/openvpn/update-resolv-conf
# down /etc/openvpn/update-resolv-conf
````

Se o seu cliente estiver executando Linux e tiver um arquivo `/etc/openvpn/update-resolv-conf`, descomente essas linhas no arquivo de configuração do cliente depois que ele tiver sido gerado.

Salve e feche o arquivo quando terminar.

A seguir, crie um script simples que criará um novo arquivo de configuração contendo seu certificado, chave, arquivos de criptografia e a configuração base no diretório `/etc/openvpn/client/files`. Abra um novo arquivo chamado `make_config.sh` dentro do diretório `client`:

````shell
vi /etc/openvpn/client/make_config.sh
````

Dentro dele, adicione o seguinte conteúdo:

````shell
#!/bin/bash

# First argument: Client identifier

KEY_DIR=/etc/openvpn/client/keys
OUTPUT_DIR=/etc/openvpn/client/files
BASE_CONFIG=/etc/openvpn/client/base.conf

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
````

Salve e feche o arquivo quando terminar.

Antes de prosseguir, certifique-se de marcar este arquivo como executável digitando:

````shell
chmod 700 /etc/openvpn/client/make_config.sh
````

Este script fará uma cópia do arquivo `base.conf` que você criou, coletará todos os arquivos de certificado e chave que você criou para o cliente, extrairá o conteúdo deles, acrescentará ao arquivo de configuração base copiado e exportará todo esse conteúdo para um novo arquivo de configuração do cliente. Isso significa que, em vez de ter que gerenciar separadamente a configuração, os certificados e os arquivos de chave do cliente, todas as informações necessárias estão armazenadas em um só lugar. A vantagem disso é que, se você precisar adicionar um novo cliente no futuro, poderá simplesmente executar esse script a partir de um local central para criar rapidamente o arquivo de configuração que contém todas as informações necessárias em um único arquivo fácil de distribuir.

Por favor, note que sempre que você adicionar um novo cliente, precisará gerar novas chaves e certificados para ele antes de poder executar este script e gerar o arquivo de configuração. Você terá a oportunidade de praticar o uso desse script no próximo passo.


## 9. Gerando Configurações do Cliente
Se você seguiu o guia, você criou um certificado e chave de cliente chamados `client1.crt` e `client1.key`, respectivamente. Você pode gerar um arquivo de configuração para essas credenciais movendo-se para o diretório `client` e executando o script que você criou no final do passo anterior:

````shell
cd /etc/openvpn/client
sudo ./make_config.sh client1
````

Isso criará um arquivo chamado `client1.ovpn` no diretório `/etc/openvpn/client/files`:

````shell
ls /etc/openvpn/client/files
````

Fonte: [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-a-certificate-authority-ca-on-debian-11#step-2-preparing-a-public-key-infrastructure-directory), [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-debian-11)