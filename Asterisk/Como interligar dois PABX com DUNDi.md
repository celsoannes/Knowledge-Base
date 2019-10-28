# Como integrar dois PABX com DUNDi

## Configurando Servidor A

### Configurando canal de comunicação IAX no servidor A

Edite o arquivo `/etc/asterisk/iax.conf`

```bash
[general]
bindport=4569
bindaddr=192.168.110.5
disallow=all
allow=g729
callerid=Servidor A
jitterbuffer=yes
forcejitterbuffer=yes
autokill=yes
nat=yes

[dundi-interno]
type=friend
dbsecret=dundi/secret
context=dundi-interno
trunk=yes
requirecalltoken=no
```
