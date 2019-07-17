# Como Sincronizar o NTP

1. Instalando servidor NTP

    ```bash
    apt-get update
    apt-get install ntp ntpdate
    ```

1. Configurando NTPd

    Após a instalação, precisamos nos certificar que o horário de nosso computador não está mais que 16 minutos atrasado ou adiantado. Vamos utilizar o comando abaixo para atualizar o horário do computador com o servidor NTP padrão de referência:
    
    ```bash
    ntpd -q -g
    ```

    Após a atualização do horário através dos servidores padrões do Debian e do Ubuntu, o **NTP** utiliza o arquivo `ntp.drift`. O `ntp.drift` registra a instabilidade na freqüência do relógio do seu computador e o NTP o utiliza este registro para sincronizar corretamente o relógio do seu equipamento com o do servidor de referência. Algumas distribuições Linux não criam o arquivo automaticamente no momento da instalação, porém o **Debian** (Debian 8.0 e 9.0) e o Ubuntu o criam corretamente.

1.  Configurando o servidor NTP via `ntp.conf`

    O arquivo responsável pela configuração do servidor NTP é o `ntp.conf` que no Debian e Ubuntu está localizado em `/etc/ntp.conf`. Nas duas distribuições o `ntp.conf` é idêntico, salvo é claro o servidor NTP de referência, que no Ubuntu é ntp.ubuntu.com e no Debian são quatro servidores, onde o primeiro é `0.debian.pool.ntp.org`.
    
    Vamos agora entender a estrutura do arquivo para definirmos uma configuração usual.
    
    A primeira linha faz referência a localização do arquivo `ntp.drift` que comentei um pouco acima neste post. Verifique se ele está criado no diretório apontado em seu arquivo de configuração. Caso não esteja criado, então utilize o comando abaixo:
    
    ```bash
    touch /var/lib/ntp/ntp.drift
    ```

    Caso você deseje monitorar seu servidor NTP através de LOGs, então **"descomente"** (retire o caracter `#`) da linha `statsdir`. Não esqueça de **"descomentar"** também as linhas de `filegen`, pois serão utilizadas para definir as informações gravadas em log.

    O terceiro item do arquivo de configuração é relativo ao servidor NTP de referência, ele deve ser configurado no padrão:

    ```bash
    server <endereço-do-servidor> <opções>
    ```

    Existem doze itens de configuração de servidor. Eu recomendo a utilização de três opções, são elas:

    * `iburst` – quando o NTPd não localiza o servidor, então ele envia oito pacotes, ao invés de dois pacotes (padrão), assim mesmo que sua conexão apresente alguma instabilidade o NTPd tentará mais contatos com o servidor NTP de referência;
    * `prefer` – define o servidor NTP de referência como preferencial;
    * `dynamic` – permite que um servidor, mesmo que inalcançável, ainda seja contatado futuramente, pois sua rede local ou sua conexão de internet pode ter falhado ou esteja com sinal intermitente.

    Sugiro estes cinco servidores:

    * `a.ntp.br` – Servidor da NTP.br;
    * `ntp.ansp.br` – Servidor do NARA (núcleo de apoio a rede acadêmica);
    * `ntp.cais.rnp.br` – Servidor da RNP (rede nacional de pesquisa);
    * `b.ntp.br` – Servidor da NTP.br;
    * `c.ntp.br` – Servidor da NTP.br;

    É importante, por questões de segurança, que não seja permitido que estes servidores NTP de referência façam qualquer alteração no horário, pois estes são para consulta e a alteração de horário deverá ser feita localmente, então vamos colocar uma regra de restrição de alteração e consulta para estes servidores. Configuramos estes parâmetros dentro da configuração de restrict, como por exemplo:

    ```bash
    restrict <endereço-do-servidor> mask 255.255.255.255 nomodify noquery
    ```

    Eu não modifico a configuração padrão das primeiras quatro linhas contendo o item o chamada `restrict`, pois desejo que meu servidor NTP troque horário com qualquer computador, porém não permitindo alteração de configuração e também permito que usuários do próprio computador façam consultas ao servidor. A única configuração de restrição que eu faço é a inserção da linha:

    ```bash
    restrict <rede-local> mask <máscara-de-rede>
    ```

    A linha acima deve ser utilizada para liberar todas as máquinas da rede local para acessarem o servidor de NTP.

1. Exemplo de configuração do `ntp.conf`

    Abaixo segue meu exemplo de configuração do `ntp.conf`:

    ```bash
    driftfile /var/lib/ntp/ntp.drift
    
    statsdir /var/log/ntpstats/
    statistics loopstats peerstats clockstats
    filegen loopstats file loopstats type day enable
    filegen peerstats file peerstats type day enable
    filegen clockstats file clockstats type day enable
    
    server a.ntp.br prefer iburst dynamic
    server b.ntp.br iburst dynamic
    server c.ntp.br iburst dynamic
    
    restrict a.ntp.br mask 255.255.255.255 nomodoify noquery
    restrict b.ntp.br iburst mask 255.255.255.255 nomodoify noquery
    restrict c.ntp.br iburst mask 255.255.255.255 nomodoify noquery
    
    restrict -4 default kod notrap nomodify nopeer noquery
    restrict -6 default kod notrap nomodify nopeer noquery
    restrict 127.0.0.1
    restrict ::1
    restrict 192.168.0.0 mask 255.255.255.0
    ```

    Depois de salvar (gravar) o arquivo, não vamos reiniciar o serviço ainda. Primeiro vamos parar o servidor NTP (caso esteja rodando) e sincronizar o horário, do nosso servidor NTP, com os comandos:

    ```bash
    systemctl stop ntp
    ntpdate a.ntp.br
    ```

    Após feita sincronização de horário com um servidor NTP de referência, então vamos reiniciar o serviço de NTP com o comando:

    ```bash
    systemctl start ntp
    ```

1. Verificando se o nosso servidor NTP está sincronizando corretamente

    Para verificarmos se os servidores ao qual estamos tentando sincronizar estão fornecendo respostas e nosso servidor **NTP** está sincronizando o horário corretamente, precisaremos executar o comando de consulta. O resultado é atualizado constantemente nos dois primeiros dias de sincronização, pois as informações de frequência ainda estão sendo atualizadas no arquivo `ntp.drift`.

    Comando de consulta da situação de sincronização:

    ```bash
    ntpq -p
    ```

    O resultado deve variar, mas pode ser como o abaixo:

    ```bash
         remote           refid      st t when poll reach   delay   offset  jitter
    ==============================================================================
     0.debian.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
     1.debian.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
     2.debian.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
     3.debian.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
     d.st1.ntp.br    .ONBR.           1 u    1   64    1   27.141   -2.825   0.000
     200.160.7.193 ( 76.127.35.142    2 u    1   64    1   14.897   -0.987   0.000
     Time100.Stupi.S .PPS.            1 u    1   64    1  262.004  -11.998   0.405
     b.st1.ntp.br    .ONBR.           1 u    2   64    1   53.343    3.976   0.000
     gpg.n1zyy.com   213.251.128.249  2 u    1   64    1  173.675   -6.335   0.000
     a.ntp.br        200.160.7.186    2 u    1   64    1   14.676   -1.093   0.166
     ec2-52-67-171-2 203.206.205.83   3 u    1   64    1   15.972    2.617   0.017
     ntp1.ifsc.usp.b 143.107.229.211  2 u    2   64    1  134.123   50.747   0.000
     ntp4.rbx-fr.hos 193.190.230.65   2 u    2   64    1  225.672    3.467   0.000
    ```

Fonte: [software.livre](http://softwarelivre.org/andre-ferraro/blog/linux-instalando-configurando-e-sincronizando-o-relogio-de-servidores-e-clientes-com-ntp-no-debian-ubuntu-e-windows.)