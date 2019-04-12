# Como instalar o Docker no Debian 9

## Desinstalar versões antigas
Versões antigas do Docker eram chamadas de `docker`, `docker.io`, ou `docker-engine`. Se algum deles estiver instalado, desinstale eles:

```bash
apt-get remove docker docker-engine docker.io containerd runc
```

Fonte: [Docker](https://docs.docker.com/install/linux/docker-ce/debian/)