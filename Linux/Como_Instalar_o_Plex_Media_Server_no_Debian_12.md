# Como Instalar o Plex Media Server no Debian 12

## 1. Atualize o Sistema Debian Antes da Instalação do Plex
Comece atualizando seu sistema Debian para garantir um processo de instalação tranquilo. Isso garante que todos os pacotes existentes estejam atualizados:

````shell
apt update && apt upgrade
````

## 2. Instalar os Pacotes Iniciais Necessários para o Plex
A instalação do Plex requer alguns pacotes adicionais. Instale-os executando o seguinte comando:

````shell
apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
````

Esses pacotes fornecerão as ferramentas para lidar com o repositório Plex, incluindo conexões seguras e gerenciamento de chaves GPG.

# 3. Importar o Repositório Plex APT no Debian
Adicione o repositório Plex ao seu sistema Debian para instalar o Plex a partir da fonte oficial. Isso garante que você instale e atualize o software diretamente do repositório oficial usando o gerenciador de pacotes APT.

Primeiro, abra seu terminal e importe a chave GPG do Plex com o seguinte comando:

````shell
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | tee /usr/share/keyrings/plex.gpg > /dev/null
````

Esse comando faz o download da chave GPG do Plex, que é usada para verificar a autenticidade dos pacotes do repositório.

Em seguida, adicione o repositório do Plex ao seu sistema:

````shell
echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | tee /etc/apt/sources.list.d/plexmediaserver.list
````

Esse comando cria um novo arquivo no diretório `sources.list.d` com as informações necessárias sobre o repositório Plex.

## 4. Instalar o Plex Media Server Cia Comando APT no Debian
Antes de instalar o Plex, atualize seu índice de pacotes para incluir o repositório Plex recém-adicionado:

````shell
apt update
````

Agora você pode instalar o Plex Media Server no Debian usando o seguinte comando:

````shell
apt install plexmediaserver
````

> NOTA: Durante a instalação, você poderá ver um prompt perguntando se deseja substituir a lista de repositórios importada pelo Plex.
> 
> Digite `N` para prosseguir com a instalação, pois você não deseja substituir a lista de repositórios importada. Isso ocorre porque a chave GPG assinada correta já está em vigor.

## 5. Verificar a Instalação do Plex Media Server
Por padrão, o serviço Plex Media deve iniciar automaticamente. Para verificar isso, use o seguinte comando systemctl para verificar o status:

````shell
systemctl status plexmediaserver
````

````shell
● plexmediaserver.service - Plex Media Server
     Loaded: loaded (/lib/systemd/system/plexmediaserver.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-03-15 08:32:39 -03; 18min ago
   Main PID: 841 (Plex Media Serv)
      Tasks: 112 (limit: 4644)
     Memory: 245.3M
        CPU: 30.542s
     CGroup: /system.slice/plexmediaserver.service
             ├─ 841 "/usr/lib/plexmediaserver/Plex Media Server"
             ├─ 876 "Plex Plug-in [com.plexapp.system]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/System.bundle
             ├─ 919 "/usr/lib/plexmediaserver/Plex Tuner Service" /usr/lib/plexmediaserver/Resources/Tuner/Private /usr/lib/plexmediaserver/Resources/Tuner/Shared 1.40.1.8227-c0dd5a73e 32600
             ├─ 941 "Plex Plug-in [com.plexapp.agents.plexthememusic]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/PlexThemeMusic.bundle
             ├─1005 "Plex Plug-in [org.musicbrainz.agents.music]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Musicbrainz.bundle
             ├─1115 "Plex Plug-in [com.plexapp.agents.thetvdb]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/TheTVDB.bundle
             ├─1404 "Plex Plug-in [com.plexapp.agents.themoviedb]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/TheMovieDB.bundle
             ├─1486 "Plex Plug-in [com.plexapp.agents.imdb]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/PlexMovie.bundle
             └─1554 "Plex Plug-in [com.plexapp.agents.localmedia]" /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 1.40.1.8227-c0dd5a73e /usr/lib/plexmediaserver/Resources/Plug-ins-c0dd5a73e/LocalMedia.bundle

mar 15 08:32:41 plex Plex Media Server[870]:   --allowRetries arg     Whether we will allow retries
mar 15 08:32:41 plex Plex Media Server[870]: Session Health options:
mar 15 08:32:41 plex Plex Media Server[870]:   --sessionStatus arg    Seassion health status (exited, crashed, or abnormal)
mar 15 08:32:41 plex Plex Media Server[870]:   --sessionStart arg     Session start timestamp in UTC or epoch time
mar 15 08:32:41 plex Plex Media Server[870]:   --sessionDuration arg  Session duration in seconds
mar 15 08:32:41 plex Plex Media Server[870]: Common options:
mar 15 08:32:41 plex Plex Media Server[870]:   --userId arg           User that owns this product
mar 15 08:32:41 plex Plex Media Server[870]:   --version arg          Version of the product
mar 15 08:32:41 plex Plex Media Server[870]:   --sentryUrl arg        Sentry URL to upload to
mar 15 08:32:41 plex Plex Media Server[870]:   --sentryKey arg        Sentry Key for the project
````

Se o serviço não estiver ativo, use o seguinte comando para iniciar o Plex Media Server:

````shell
systemctl start plexmediaserver
````

Para garantir que o Plex Media Server seja iniciado automaticamente na inicialização do sistema, ative o serviço com este comando:

````shell
systemctl enable plexmediaserver
````

Se você precisar reiniciar o serviço Plex Media Server por qualquer motivo, use o seguinte comando:

````shell
systemctl restart plexmediaserver
````

## 6: Configuração do Plex Media Server na WebUI no Debian
Agora que o Plex está instalado em seu sistema, você deve configurar e concluir a instalação por meio da WebUI. A WebUI permite que você gerencie sua biblioteca de mídia e personalize as configurações do servidor. Siga as etapas abaixo para acessar e configurar o Plex Media Server na WebUI:

### 6.1 Acessar a WebUI
Para acessar a WebUI, abra o navegador de Internet de sua preferência e navegue até um dos seguintes endereços:

http://127.0.0.1:32400/web

ou

http://localhost:32400/web

Se esses dois não funcionarem, tente usar o seguinte endereço:

http://localhost:32400/web/index.html#!/setup
Agora, você pode fazer login usando uma conta de mídia social existente listada acima ou com seu e-mail para registrar uma nova conta se for novo no Plex. Uma vez conectado, você iniciará a configuração inicial.

Fonte: [Linux Capable](https://www.linuxcapable.com/how-to-install-plex-media-server-on-debian-linux/)