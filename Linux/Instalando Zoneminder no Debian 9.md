# Instalando Zoneminder no Debian 9

Este procedimento ira guia-lo através da instalação do ZoneMinder no Debian 9 (Stretch). Esta sessão foi testada com ZoneMinder 1.32.3 no Debian 9.8.

### Passo 1: Certifique-se de que seu sistema esta atualizado

Abra o console e use o comando ``su`` para se tornar Root.

    apt update
    apt upgrade

### Passo 2: Configure o Sudo (opicional mas recomendado)
Por padrão Debian não vem com ``sudo``, então você deve instalar ele e configurar ele manualmente. Este passo é opcional mas recomendado e as instruções seguintes assumem que você tenha configurado o ``sudo``. Se você preferir configurar **ZoneMinder** como ``root``, faça isso a seu próprio risco e adapte os seguintes comandos de acordo com as instruções.

    apt install sudo
    usermod -a -G sudo <username>
    exit

Agora sua sua sessão voltou para o seu usuario normal. Você pode verificar que agora você faz parte do grupo ``sudo`` com o comando ``groups``, ``sudo`` deve aparecer na lista. Se não, rode ``newgrp sudo`` e cheque novamente com ``groups``.

### Passo 3: Instalar Apache e MySQL

Estes não são dependencias para os pacotes ZoneMinder como eles podem ser instalados em outro momento. Se eles não estiverem instalados no seu sistema ainda, você deve acionar a sua instalação manualmente.

    sudo apt install apache2 mysql-server

### Passo 4: Adicionar o repositorio de pacotes do ZoneMinder

Os pacotes do ZoneMinder para o Debian não estão incluidos no repositório oficial do Debian. Para que seja possível instalar o ZoneMinder através do ``apt`` você deve editar a lista dos fontes do apt e adicionar o repositório do ZoneMinder.

``/etc/apt/sources.list``

Adicione o seguinte ao final do arquivo:

    # ZoneMinder repository
    deb https://zmrepo.zoneminder.com/debian/release stretch/

Devido ao repositório de pacotes do NoneMinder prove uma conexão segura através de HTTPS, deve ser habilitado HTTPS para apt.

    sudo apt install apt-transport-https

Finalmente, baixe a chave GPG para o repositório do ZoneMinder.

    wget -O - https://zmrepo.zoneminder.com/debian/archive-keyring.gpg | sudo apt-key add -

### Passo 5: Instalar ZoneMinder

    sudo apt update
    sudo apt install zoneminder

### Passo 6: Leia o README

O resto do processo de instalação esta coberto no README.Debian, então sinta-se a vontade para ler.

    gunzip /usr/share/doc/zoneminder/README.Debian.gz
    cat /usr/share/doc/zoneminder/README.Debian

### Passo 7: Habilitar o serviço ZoneMinder

    sudo systemctl enable zoneminder.service

### Passo 8: Configurar o Apache

Os comandos seguintes irão configurar o diretório virtual padrão ``/zm`` e configurar os módulos necessários do apache.

    sudo a2enconf zoneminder
    sudo a2enmod rewrite
    sudo a2enmod cgi # this is done automatically when installing the package. Redo this command manually only for troubleshooting.

### Passo 9: Editar o Fuzo Horário no PHP

Método automático:

    sudo sed -i "s/;date.timezone =/date.timezone = $(sed 's/\//\\\//' /etc/timezone)/g" /etc/php/7.0/apache2/php.ini

Método manual:

    sudo nano /etc/php/7.0/apache2/php.ini

Busque por ``[Date]`` e mude o ``date.timezone`` para o seu fuzo horário. Não esqueça de remover o ``;`` em frente do ``date.timezone``.

    [Date]
    ; Defines the default timezone used by the date functions
    ; http://php.net/date.timezone
    date.timezone = America/Sao_Paulo

### Passo 10: Inicie o ZoneMinder

Recarregue o apache para habilitar as suas modificações e inicie o ZoneMinder.

    sudo systemctl reload apache2
    sudo systemctl start zoneminder

Agora você esta pronto para ir com ZoneMinder. Abra o navegador e digite o ip da sua maquina seguido de ``/zm``.

Fonte: [ZoneMinder](https://zoneminder.readthedocs.io/en/latest/installationguide/debian.html#easy-way-debian-stretch)