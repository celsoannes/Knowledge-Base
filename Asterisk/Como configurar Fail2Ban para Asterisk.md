# Como configurar Fail2Ban para Asterisk

## Asterisk

O Asterisk é um PABX VoIP de código aberto. Se você tem o seu Asterisk exposto para a Internet, você pode ver pessoas usando força bruta com usuarios e senhas; a parte dos obvios riscos de segurança, isto ocorre frequentemente em alta taxa, causando alto processamento de CPU e alta largura de banda.

### AVISO: Existem certos tipos de ataque ao Asterisk que o Fail2Ban é ineficaz contra.


## Instalar Fail2Ban

Antes de instalar qualquer pacote, atualize o indice de pacotes:

    apt-get update

Instale o Fail2Ban.

    apt-get install fail2ban

#### Asterisk 10.x e mais recentes

A equipe do Asterisk introduziu um novo registro - o registro ``security``. Ele toma conta de registrar informações extra para eventos de segurança - o que pode ser usado pelo Fail2Ban para parar ataques - especiamente tentativas de efetuar ligações sem se registrar o que não poderia ser bloqueado antes de usar o Fail2Ban.

Primeiramente o registro de segurança precisa ser habilitado em ``/etc/asterisk/logger.conf``:

    messages => security, notice,warning,error
    
Também modifique o formato da data para que o Fail2Ban compreenda o arquivo de registros.

    [general]
    dateformat=%F %T
    
Então reinicie o módulo de registros do Asterisk:

    asterisk -rx "logger reload"
    
Para filtrar exemplos, use os que vem com o Fail2Ban. Não esqueça de apontar o Fail2Ban (em ``jail.conf``) para ``/var/log/asterisk/messages`` ou ``/var/log/asterisk/messages`` e ``/var/log/asterisk/security`` - se você configurou o relatório de registros separado do registro principal. A configuração acima irá imprimir mensagens de segurança no relatório de registros principal.

#### Versões antigas do Asterisk - sem /var/log/asterisk/security

Asterisk 1.4 (Debian: 1:1.4.21.2~dfsg-3+lenny1)

A primeira linha ``/var/log/asterisk/messages``, que é escrita pelo asterisk. Não é usada pelo Fail2Ban (0.8.3) porque a a data e hora esta fechada dentro de colchetes.
A segunda linha é o que você pega se você instruir o Asterisk para registrar no ``syslog`` adicionando ``syslog.local0 => notice,warning,error`` para ``/etc/asterisk/logger.conf`` (e obviamente configuurando seu ``syslogd`` para registrar ``local0`` para algum arquivo).

Fail2Ban 0.8.3+ reconhece o formado do registro do Asterisk 1.8.x e não é necessário habilitar ``syslog.local0`` como isto irá apenas preencher seu arquivo ``messages/syslog``. Use ``fail2ban-regex`` para testar os seus arquivos de configuração e você irá ver eles funcionando.

    [Aug 8 14:31:33] NOTICE[1687] chan_sip.c: Registration from '"150"<sip:150@hostname>' failed for '192.0.2.1' - No matching peer found
    Aug 8 14:31:33 hostname asterisk[1617]: NOTICE[1687]: chan_sip.c:15642 in handle_request_register: Registration from '"154"<sip:154@hostname>' failed for '192.0.2.1' - No matching peer found

Template: ``logger.conf``


Não esqueça de adicionar isto em ``/etc/asterisk/logger.conf``.

    [general]
    dateformat=%F %T

Isto é importante, de outra maneira Fail2Ban não irá ser capaz de abalizar o arquivo de registros. 

## Failregex

A expressão regular abaixo ``failregex`` é proposta para este software. Multiplas expressões regulares para ``failregex`` só ira funcionar com uma versão do **Fail2Ban** superior ou igual a **0.7.6**.

A marcação ``<HOST>`` na expressão regular abaixo é apenas um aliás para ``(?:::f{4,6}:)?(?P<host>\S+)``. A substituição é feita automaticamente pelo **Fail2Ban** quando adicionada a expressão regular. No momento, exatamente um grupo chamado ``host`` ou marcador ``<HOST>`` deve estar presente em cada expressão regular.

    failregex = asterisk.*chan_sip.c.*Registration from .* failed for '<HOST>' - No matching peer found

## Configurando Asterisk Conf e Jail Rules

``/etc/fail2ban/jail.conf``

```bash
[DEFAULT]
bantime = 3600
findtime = 21600
maxretry = 3
backend = auto
```

```bash
[asterisk-iptables]
# if more than 4 attempts are made within 6 hours, ban for 24 hours
enabled  = true
filter   = asterisk
action   = iptables-allports[name=ASTERISK, protocol=all]
              sendmail[name=ASTERISK, dest=you@yourmail.co.uk, sender=fail2ban@local.local]
logpath  = /var/log/asterisk/messages
maxretry = 4
findtime = 21600
bantime = 86400
```

``filter.d/asterisk.conf`` Arquivo para Asterisk 1.4/1.6:
```bash
# Fail2Ban configuration file
#
#
# $Revision: 251 $
#

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf


[Definition]

#_daemon = asterisk

# Option:  failregex
# Notes.:  regex to match the password failures messages in the logfile. The
#          host must be matched by a group named "host". The tag "<HOST>" can
#          be used for standard IP/hostname matching and is only an alias for
#          (?:::f{4,6}:)?(?P<host>\S+)
# Values:  TEXT
#

failregex = NOTICE.* .*: Registration from '.*' failed for '<HOST>' - Wrong password
            NOTICE.* .*: Registration from '.*' failed for '<HOST>' - No matching peer found
            NOTICE.* .*: Registration from '.*' failed for '<HOST>' - Username/auth name mismatch
            NOTICE.* <HOST> failed to authenticate as '.*'$
            NOTICE.* .*: No registration for peer '.*' (from )
            NOTICE.* .*: Host  failed MD5 authentication for '.*' (.*)
            NOTICE.* .*: Registration from '.*' failed for '<HOST>' - Device does not match ACL
            NOTICE.* .*: Registration from '.*" .* failed for '<HOST>' - Peer is not supposed to register
            VERBOSE.*SIP/<HOST>-.*Received incoming SIP connection from unknown peer
   
# Option:  ignoreregex
# Notes.:  regex to ignore. If this regex matches, the line is ignored.
# Values:  TEXT
#
ignoreregex =
```

``filter.d/asterisk.conf`` Arquivo para Asterisk 1.8:

```bash
# Fail2Ban configuration file
#
#
# $Revision: 251 $
#

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf


[Definition]

#_daemon = asterisk

# Option:  failregex
# Notes.:  regex to match the password failures messages in the logfile. The
#          host must be matched by a group named "host". The tag "<HOST>" can
#          be used for standard IP/hostname matching and is only an alias for
#          (?:::f{4,6}:)?(?P<host>\S+)
# Values:  TEXT
#
# Asterisk 1.8 uses Host:Port format which is reflected here

failregex = NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - Wrong password
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - No matching peer found
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - No matching peer found
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - Username/auth name mismatch
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - Device does not match ACL
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - Peer is not supposed to register
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - ACL error (permit/deny)
            NOTICE.* .*: Registration from '.*' failed for '<HOST>:.*' - Device does not match ACL
            NOTICE.* .*: Registration from '\".*\".*' failed for '<HOST>:.*' - No matching peer found
            NOTICE.* .*: Registration from '\".*\".*' failed for '<HOST>:.*' - Wrong password
            NOTICE.* <HOST> failed to authenticate as '.*'$
            NOTICE.* .*: No registration for peer '.*' \(from <HOST>\)
            NOTICE.* .*: Host <HOST> failed MD5 authentication for '.*' (.*)
            NOTICE.* .*: Failed to authenticate user .*@<HOST>.*
            NOTICE.* .*: <HOST> failed to authenticate as '.*'
            NOTICE.* .*: <HOST> tried  to authenticate with nonexistent user '.*'
            VERBOSE.*SIP/<HOST>-.*Received incoming SIP connection from unknown peer
   
# Option:  ignoreregex
# Notes.:  regex to ignore. If this regex matches, the line is ignored.
# Values:  TEXT
#
ignoreregex =
```


Fonte: [Fail2Ban](https://www.fail2ban.org/wiki/index.php/Asterisk)