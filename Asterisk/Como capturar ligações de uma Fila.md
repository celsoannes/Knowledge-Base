# Como capturar ligações de uma Fila

A proposta aqui não é capturar um ramal tocando que esta recebendo a ligação de uma fila, isso seria muito fácil, imagine o seguinte senário, uma fila com dois membros onde os dois membros estão ocupados e existem ligações na fila esperando atendimento, outros ramais só irão conseguir capturar essas ligações caso um dos ramais membros estivessem tocando. Abaixo iremos solucionar este problema permitindo que qualquer ramal capture uma ligação em espera na fila.

## Capturando uma Fila
O truque aqui é, não tente capturar um ramal tocando, capture a extenção da fila:

Vamos criar um cenário minimo de configurações para que possa ser usado como exemplo:

```bash
;sip.conf
[general]
bindport=5060
context=default
disallow=all
allow=ulaw
qualify=yes

[1000]
type=friend
secret=mysecret
context=trusted
host=dynamic

[1001]
type=friend
secret=mysecret
context=trusted
host=dynamic
```

```bash
;queues.conf
[itg_queue]
musicclass=default
strategy=rrmemory
joinempty=yes
leavewhenempty=no
ringinuse=no

member => SIP/1000
```

```bash
;# Passo 1 #
[ivr-dialextension]
exten => 8501,1,Goto(itg-queue,itg,1)     ;Salta para o contexto itg-queue

;# Passo 2 #
[itg-queue]
exten => itg,1,Queue(itg_queue,crhH,,,127)

;# Passo 3 #
[trusted]
exten => 8501,hint,Queue:itg_queue        ;Provê um hint para a fila
exten => _**8501,1,Pickup(itg@trusted)    ;Captura a fila
```

1. A ligação de origem entra ``8501@ivr-dialextension``
1. Que salta para o contexto ``itg-queue`` que chamará os membros registrados
1. Todos os ramais que discarem ``**8501`` no contexto ``trusted`` poderão capturar uma ligação chamando na extenção.

> _**NOTA:**_ A captura deve ser feita no mesmo contexto de permissão do ramal na fila. Ex.: Se no sip.conf o ramal tiver ``context=interno`` o Pickup deve estar assim: ``Pickup(itg@interno)``.

Fontes: [list.digium](http://lists.digium.com/pipermail/asterisk-users/2012-April/271738.html),[Yeastar Support](https://support.yeastar.com/hc/en-us/community/posts/360016047674-Support-a-hint-on-a-queue)
