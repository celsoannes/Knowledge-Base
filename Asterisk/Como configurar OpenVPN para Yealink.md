# Como configurar OpenVPN para Yealink

## Sobre VPN

VPN (Virtual Private Network) é uma rede que usa uma infraestrutura publica de telecomunicação, como a internet, para prover escritórios remoto ou usuários em deslocamento um acesso seguro a rede da empresa. VPN da a empresa a vantagem de criar canais seguros de comunicação ,enquanto ao mesmo tempo reduz custos, melhorando a segurança e aumentando o desempenho.

Existem dois tipos de acesso VPN: **remote-access** e **site-to-site**.

## Tipos de Acesso VPN

* **Remote-Acess VPN**: também chamado de rede virtual privada discada (virtual private dial-up network - VPDN), é uma usuário-para-LAN (user-to-LAN) conexão usada por uma empresa que possui funcionários que necessitam se conectar a rede privada a partir de vários locais remotos.
* **Site-to-site VPN**: conecta redes inteiras umas as outras, isto significa, site-to-site VPN (local-para-local) pode ser usada para conectar uma filial ou escritório remoto a rede da matriz da empresa. Cada local é equipado com um acesso VPN, tal como um roteador, firewall, concentrador VPN ou ferramenta de segurança.
 

## Instalar OpenVPN

Antes de instalar qualquer pacote, atualize o indice de pacotes:

```bash
apt-get update
```

Agora podemos instalar o servidor OpenVPN juntamente com easy-RSA para criptografia.

```bash
apt-get install openvpn easy-rsa
```

## Configurar OpenVPN

O exemplo do arquivo de configuração do servidor VPN precisa ser extraído para ``/etc/openvpn`` para que possamos incorporar ele em nossa configuração.

```bash
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf
```

Uma vez extraído, abra o arquivo de configuração do servidor.

```bash
vi /etc/openvpn/server.conf
```

1. Assegure que o tamanho da chave RSA usada possui um tamanho compatível com o telefone Yealink:

    ```bash
    #Diffie hellman parameters.
    # Generate your own with:
    #   openssl dhparam -out dh1024.pem 1024
    # Substitute 2048 for 1024 if you are using
    # 2048 bit keys.
    dh dh1024.pem
    ```
    
    A chave RSA deve estar como ``dh1024.pem`` se não estiver mude para este valor.

1. Assegure que todo o tráfego será redirecionado para o local apropriado. Descomente ``push "redirect-gateway def1 bypass-dhcp"`` assim o servidor VPN transmite o trafego web do cliente para o seu destino. Ele deve se parecer assim quando finalizado:

    ```bash
    push "redirect-gateway def1 bypass-dhcp"
    ```

1. Nós iremos informar ao servidor para usar OpenDNS para resolução DNS quando possível. Isto pode ajudar a prevenir requisições DNS vazarem para fora da conexão VPN. Descomente ``push "dhcp-option DNS 208.67.222.222"`` e ``push "dhcp-option DNS 208.67.220.220"``. Ele deve se parecer assim quando finalizado:

    ```bash
    push "dhcp-option DNS 208.67.222.222"
    push "dhcp-option DNS 208.67.220.220"
    ```

## Habilitar Encaminhamento de Pacotes

Nesta sessão, nos iremos informar ao kernel do servidor para encaminhar o tráfego do cliente de fora para a internet. Caso contrário, o tráfego irá parar no servidor.

Habilite o encaminhamento de pacotes durante a execução rodando este comando:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

Seguindo, nos precisamos fazer isso permanente para que esta configuração se torne permanente depois que o servidor for reiniciado. Abra o arquivo de configuração do ``sysctl``.

```bash
vi /etc/sysctl.conf
```
    
Próximo ao topo do arquivo ``sysctl``, você verá:

```bash
# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1
```

Descomente ``net.ipv4.ip_forward``. Ele deve se parecer assim quando finalizado:

```bash
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
```

## Configure e criar o Certificado de Autoridade

O OpenVPN usa certificados para criptografar o tráfego.

1. copie o gerador de scripts Easy-RSA.

    ```bash
    cp -r /usr/share/easy-rsa/ /etc/openvpn
    ```

1. Crie a pasta que irá abrigar as chaves OpenVPN.

    ```bash
    mkdir /etc/openvpn/easy-rsa/keys
    ```

1. Configure os parâmetros para o nosso certificado. Abra o arquivo de variáveis:

    ```bash
    vi /etc/openvpn/easy-rsa/vars
    ```

    As variáveis entre aspas podem ser alteradas de acordo com a sua preferencia.
    
    ```bash
    export KEY_COUNTRY="BR"
    export KEY_PROVINCE="RS"
    export KEY_CITY="Novo Hamburgo"
    export KEY_ORG="Nome da Empresa"
    export KEY_EMAIL="contato@example.com"
    export KEY_OU="MYOrganizationalUnit"
    ```

    No mesmo arquivo ``vars``, edite também a linha mostrada abaixo. Para simplificar, iremos usar ``server`` como nome da chave.
    
    Abaixo no mesmo arquivo, nos iremos especificar o certificado correto. Procure a linha, logo após o bloco modificado que se lê:
    
    ```bash
    # X509 Subject Field
    export KEY_NAME="EasyRSA"
    ```

    Modifique o valor padrão de ``EasyRSA`` em ``KEY_NAME`` para ``server``.
    
    ```bash
    # X509 Subject Field
    export KEY_NAME="server"
    ```

1. Crie a pasta que irá abrigar as chaves do servidor OpenVPN.

    ```bash
    mkdir /etc/openvpn/keys
    ```

1. Agora será gerado os parametros Diffie-Helman usando a ferramenta construtora OpenSSL chamada ``dhparam``; isso pode demorar alguns minutos.

    O sinal ``-out`` especifica onde salvar os novos parametros.
    
    ```bash
    openssl dhparam -out /etc/openvpn/keys/dh1024.pem 1024
    ```

    O nosso certificado foi gerado agora é hora de gerar a chave.

1.  Vá para a pasta ``easy-rsa``.

    ```bash
    cd /etc/openvpn/easy-rsa
    ```

    Agora podemos começar a configurar o CA em si. Primeiramente inicialize a infraestrutura de chave pública (Public Key Infrastructure - PKI).
    
    Preste atenção no **ponto (.)** e no **espaço** em frente ao ``./vars``. Isso significa o diretório de trabalho atual (fonte).
    
    ```bash
    . ./vars
    ```
    
    > **_NOTA:_** O seguinte alerta será mostrado. Não se preocupe, como o diretório especificado no alerta esta vazio. ``NOTE: If you run ./clean-all, I will be doing a rm -rf on /etc/openvpn/easy-rsa/keys``.

1. Em seguida nos iremos limpar todas as outras chaves que podem interferir no processo da nossa instalação.

    ```bash
    ./clean-all
    ```

1. Finalmente nos iremos construir o CA usando um comando OpenSSL. Este comando irá solicitar a você uma confirmação de **_Nome Distinto_** (Distinguished Name) variáveis que foram inseridas anteriormente. Pressione ``ENTER`` para aceitar os valores existentes.

    ```bash
    ./build-ca
    ```

    Pressione ``ENTER`` para passar por cada solicitação, uma vez que você acabou de definir seus valores no arquivo ``vars``. 
    
    Agora o Certificado de Autoridade (CA) esta configurado.

## Gerando o Certificado e a Chave para o Servidor

Nesta parte, nos iremos configurar e iniciar nosso servidor OpenVPN.

Continue trabalhando a partir de ``/etc/openvpn/easy-rsa``, construa a sua chave com o nome do servidor. Isto foi espeficicado mais cedo como ``KEY_NAME`` no seu arquivo de configuração. O padrão para este tutorial é ``server``.

```bash
./build-key-server server
```

Será solicitado novamente a confirmação do Nome Distinto. Pressione ``ENTER`` para aceitar os valores padrões definido. Desta vez terá duas solicitações adicionais.

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:

Ambos devem ser deixados em branco, então apensa pressione ``ENTER`` para passar por cada uma.
    
Ao final duas consultas adicionais solicitam uma resposta positiva (``y``).
    
    Sign the certificate? [y/n]
    1 out of 1 certificate requests certified, commit? [y/n]

Então será apresentado a você uma indicação de sucesso.
    
    Write out database with 1 new entries
    Data Base Updated

## Mova os Certificados e as Chaves do Servidor

Agora nos iremos copiar o certificado e a chave para ``/etc/openvpn/keys``, conforme OpenVPN irá buscar nesta pasta o certificado CA e a chave do servidor.

```bash
cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn/keys
```

Inicie o servidor OpenVPN e verifique o seu status:

```bash
service openvpn start
service openvpn status
```


O comando status irá retornar algo selelhante ao seguinte:

```bash
● openvpn.service - OpenVPN service
   Loaded: loaded (/lib/systemd/system/openvpn.service; enabled)
   Active: active (exited) since Ter 2019-05-14 12:48:34 -03; 21h ago
 Main PID: 503 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/openvpn.service
```

O mais importanto da saída acima, você deve encontrar ``Active: active (exited) since...`` ao invés de  ``Active: inactive (dead) since...``.

## Gerando Certificados e Chaves para os Clientes

Você deve continuar trabalhando na pasta ``/etc/openvpn/easy-rsa``.

```bash
./build-key client
```

Novamente você será perguntado para confirmar ou alterar as variaves do Nome Distinto (Distinguished Name) e as seguintes solicitações devem ser deixadas em branco. Pessione ``ENTER`` para aceitar os padrões:

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:

Como anteriormente, estas duas confirmações ao final do processo de contrução exige uma resposta (``y``).

    Sign the certificate? [y/n]
    1 out of 1 certificate requests certified, commit? [y/n]

Então você terá a seguinte saida confirmando o sucesso na contrução da chave.

    Write out database with 1 new entries.
    Data Base Updated
    
### Configurando o arquivo de Cliente para Yealink

O OpenVPN requer o uso de certificados para ajudar a estabelecer a autenticidade da conexão dos clientes a um servidor OpenVPN. Você precisa obter os arquivos `` ca.crt``, ``client.crt``, ``client.key`` e `` vpn.cnf`` do sistema e então compactar eles no formato ``TAR``. 

1. Crie uma nova pasta chamada ``client`` para guardar as chaves para o cliente:

    ```bash
    mkdir -p /tmp/client/keys
    ```
    
1. Copie o arquivo ``client.conf`` e renomeie para ``vpn.cnf``.

    ```bash
    cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/vpn.cnf
    ```

1. Copie os arquivos de certificado necessário para a pasta do cliente criado anteriormente.

    ```bash
    cp /etc/openvpn/easy-rsa/keys/{client.crt,client.key,ca.crt} /etc/openvpn/client/keys
    ```

1. Os seguintes parametros devem ser configurados:

    ```bash
    client
    setenv SERVER_Poll_TIMEOUT 4
    nobind
    proto udp
    remote 200.240.249.44 1194
    dev tun
    dev-type tun
    persist-tun
    persist-key
    ns-cert-type server
    ca /config/openvpn/keys/ca.crt
    cert /config/openvpn/keys/client.crt
    key /config/openvpn/keys/client.key
    comp-lzo
    ```

1. Compactando em formato ``TAR``

    ```bash
    cd /etc/openvpn/client
    tar -cvpf openvpn.tar *
    ```

Fonte: [OpenVPN_Feature_on_Yealink_IP_Phones_V81_20.pdf](http://download.support.yealink.com/download?path=ZIjHOJbWuW/DFrGTLnGypiNdPZjJiENy01Unf47Kr1yULEZVmC5lSZwy9XNE64y111i/zwZXplusSymbol0uOcHaEePdpAvE0eOSNEY679O6k2SRcbByAyidFa8vHHbIMF4gplusSymbol0plusSymbol9bEDoJWUSwFFt2W3plusSymbol7krAanhPI/Gl0AFiX)