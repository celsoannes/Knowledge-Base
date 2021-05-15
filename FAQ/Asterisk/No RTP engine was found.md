# No RTP engine was found. Do you have one loaded?

### Ambiente
* Debian 9
* Asterisk 16.15.1

### Problema
Ao tentar efetuar uma ligação usando WebRTC a seguinte mensagem é exibida:

    [2021-01-14 11:19:54] ERROR[11877][C-00000001]: rtp_engine.c:489 ast_rtp_instance_new: No RTP engine was found. Do you have one loaded?
    [2021-01-14 11:19:54] NOTICE[11877][C-00000001]: chan_sip.c:19680 send_check_user_failure_response: RTP init failure for device "FinTi Tecnologia" <sip:finti-92927cd0890e47059989471763f1f033@webrtc.webcall.digital>;tag=p1tf57mvss for INVITE, code = -9

### Solução
Carregue o módulo `res_rtp_asterisk.so` adicionando a linha abaixo ao arquivo `modules.conf`.
```bash
vi /etc/asterisk/modules.conf
```
```bash
load => res_rtp_asterisk.so 
```

**Reinicie o Asterisk.**

Caso o problema persista, também carregue os módulos `sorcery` abaixo.

```bash
vi /etc/asterisk/modules.conf
```
```bash
load => res_sorcery_astdb.so
load => res_sorcery_config.so
load => res_sorcery_memory.so
load => res_sorcery_memory_cache.so
load => res_sorcery_realtime.so
```

