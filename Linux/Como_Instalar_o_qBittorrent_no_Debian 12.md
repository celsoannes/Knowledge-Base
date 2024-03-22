# Como Instalar o qBittorrent Web no Debian 12

Este tutorial mostrará como instalar o qBittorrent no Debian 12. O qBittorrent é um cliente BitTorrent P2P gratuito, de código aberto, rápido e leve, escrito em C++ / Qt, disponível para Linux, FreeBSD, MacOS e Windows. Seu objetivo é fornecer uma alternativa de código aberto ao uTorrent, que é um cliente BitTorrent muito popular entre os usuários do Windows.

## Instalação do qBittorrent no Debian 12

O `qBittorrent` e o `libtorrent-rasterbar` agora estão oficialmente incluídos no Debian. Os pacotes são mantidos por _Cristian Greco_. Consulte esta [página](https://packages.debian.org/search?keywords=qbittorrent&searchon=names&suite=all&section=all) para obter mais informações.

Você pode instalar o cliente de linha de comando do qBittorrent em um servidor Debian 12 sem periféricos e gerenciá-lo por meio da interface da Web do qBittorrent (você o controla em um navegador da Web). Entre por SSH em seu servidor Debian 12 e use o PPA para instalar o daemon do qBittorrent.

```shell
add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
```

> Caso receba a mensagem "`add-apt-repository: command not found`", execute o seguinte comando:
> ```shell
> apt-get install software-properties-common python3-launchpadlib -y
> ```
> Então rode o comando novamente.

```shell
apt install qbittorrent-nox
```

Observe que precisamos instalar o `qbittorrent-nox` (sem o X), em vez do `qbittorrent`. O qBittorrent-nox deve ser controlado por meio de sua interface de usuário da Web rica em recursos, que pode ser acessada por padrão em http://localhost:8080. O acesso à UI da Web é seguro e o nome de usuário padrão da conta é "`admin`" com "`adminadmin`" como senha. Você pode iniciar o qBitorrent-nox com:

```shell
qbittorrent-nox
```

No entanto, iniciar o qBittorrent-nox dessa forma não é recomendado, pois não é possível executar outro comando enquanto ele estiver em execução. Pressione `Ctrl+C` para encerrá-lo agora. Podemos criar uma unidade de serviço systemd para que ela possa ser executada em segundo plano e também iniciada no momento da inicialização do sistema.

Crie o usuário e o grupo `qbittorrent-nox` para que ele possa ser executado como um usuário sem privilégios, o que aumentará a segurança do seu servidor.

```shell
adduser --system --group qbittorrent-nox
```

A flag `--system` significa que estamos criando um usuário do sistema em vez de um usuário normal. Um usuário do sistema não tem senha e não pode fazer login, que é o que você deseja para um cliente de torrent. Um diretório home `/home/qbittorent-nox` será criado para esse usuário. Talvez você queira adicionar sua conta de usuário ao grupo `qbittorrent-nox` com o seguinte comando para que a conta de usuário tenha acesso aos arquivos baixados pelo qBittorrent-nox. Os arquivos são baixados para `/home/qbittorrent-nox/Downloads/` por padrão. Observe que você precisa fazer login novamente para que a alteração dos grupos tenha efeito.

```shell
adduser seu-usuario qbittorrent-nox
```

Em seguida, crie um arquivo de serviço systemd para o `qbittorrent-nox` com seu editor de texto favorito, como o vi.

```shell
vi /etc/systemd/system/qbittorrent-nox.service
```

Copie e cole as seguintes linhas no arquivo. Se houver outro serviço usando a porta 8080, você precisará alterar o número da porta do qBitorrent para algo diferente, como 8081. Observe também que a opção -d (daemonize) é necessária nessa unidade de serviço do systemd.

```shell
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
#Não altere para "simple"
Type=forking
User=qbittorrent-nox
Group=qbittorrent-nox
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Agora, inicie o qBittorrent-nox com o seguinte comando.

```shell
systemctl start qbittorrent-nox
```

Observe que, se você alterar um arquivo de serviço do systemd, precisará recarregar o daemon do systemd para que a alteração tenha efeito.

```shell
systemctl daemon-reload
```

Talvez você também queira ativar a inicialização automática no momento da inicialização do sistema.

```shell
systemctl enable qbittorrent-nox
```

Verifique seu status:

```shell
systemctl status qbittorrent-nox
```

Você pode ver que o qBittorrent-nox está em execução e que a inicialização automática no momento da inicialização está ativada.

## Acesso à Interface do Usuário da Web do qBittorrent

Para acessar a interface do usuário da Web do qBittorrent a partir da rede local, digite o endereço IP privado do servidor Ubuntu seguido do número da porta, como abaixo.

```shell
192.168.0.102:8080
```

O nome de usuário é `admin`. A senha padrão é `adminadmin`.

É altamente recomendável alterar o nome de usuário e a senha padrão. Vá para `Ferramentas > Opções` e selecione a guia **Interface de Usuário da Web**. Na seção **Autenticação**, altere o nome de usuário e a senha.

E agora você pode começar a baixar torrents em seu servidor Debian 12. Você tem a opção de carregar torrents locais ou adicionar links magnéticos. Os arquivos são baixados para `/home/qbittorrent-nox/Downloads/` por padrão.

Fonte: [LinuxBabe](https://www.linuxbabe.com/ubuntu/install-qbittorrent-ubuntu-18-04-desktop-server)