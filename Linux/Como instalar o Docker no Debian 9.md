# Como instalar o Docker no Debian 9

## Desinstalar versões antigas
Versões antigas do Docker eram chamadas de `docker`, `docker.io`, ou `docker-engine`. Se algum deles estiver instalado, desinstale eles:

```bash
apt-get remove docker docker-engine docker.io containerd runc
```

Tudo bem se o `apt-get` retornar que que nenhum destes pacotes esta instalado.

O conteudo de `/var/lib/docker/`, incluindo imagens, containers, volumes e redes são preservados. O Docker CE agora é chamado `docker-ce`.

## Instalar Docker CE

### Configurando o repositório

1. Atualize o `apt` repositório de pacotes:

```console
root@docker:~# apt-get update
```


Fonte: [Docker](https://docs.docker.com/install/linux/docker-ce/debian/)