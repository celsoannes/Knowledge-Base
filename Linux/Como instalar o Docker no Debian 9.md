# Como instalar o Docker no Debian 9

## Desinstalar versões antigas
Versões antigas do Docker eram chamadas de `docker`, `docker.io`, ou `docker-engine`. Se algum deles estiver instalado, desinstale eles:

    apt-get remove docker docker-engine docker.io containerd runc

Tudo bem se o `apt-get` retornar que que nenhum destes pacotes esta instalado.

O conteudo de `/var/lib/docker/`, incluindo imagens, containers, volumes e redes são preservados. O Docker CE agora é chamado `docker-ce`.

## Instalar Docker CE

### Configurando o repositório

1. Atualize o repositório de pacotes `apt`:

        apt-get update

1. Instalar pacotes para permitir que o `apt` use o repositorio sobre HTTPS:

        apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common

1. Adicionar Key GPG oficial do Docker:

        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

    Verifique se agora você tem a chave com a _impressão digital_ `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`, buscando pelos últimos 8 caracteres na _impressão digital_.

        apt-key fingerprint 0EBFCD88

    A saída do comando deve ser parecida com a seguinte:

        pub   rsa4096 2017-02-22 [SCEA]
              9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
        uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
        sub   rsa4096 2017-02-22 [S]

1. Use o comando a seguir para configurar o repositorio **stable**. Para adicionar o repositório **nightly** ou **test**, adicione a palavra `nightly` ou `test` (ou ambos) depois da palavra `stable` no comando abaixo. [Saiba mais sobre os canais **nightly** e **test**](https://docs.docker.com/install/).

    > **Nota:** O sub-comando `lsb_release -cs` abaixo retorna o nome da sua distribuição Debian, tal como `stretch`. As vezes, em uma distribuição como BunsenLabs Linux, talvez você precise mudar para `$(lsb_release -cs)` para sua distribuição Pai. Por exemplo, se você estiver usando `BunsenLabs Linux Helium` você poderia usar `stretch`. Docker não oferece nenhuma garantia em distribuições Debian não testadas ou não suportadas.

        add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/debian \
           $(lsb_release -cs) \
           stable"

## Instalar Docker CE

1. Atualize o repositório de pacotes `apt`:

        apt-get update
    
1. Instale a _última versão_ do Docker CE e container, ou vá para o proximo passo para instalar uma versão específica:

        apt-get install docker-ce docker-ce-cli containerd.io

    > ##### Obteve vários repositórios do Docker?
    > Se você tem vários repositórios do Docker habilitado, instalando ou atualizando sem uma versão específica no comando `apt-get install` ou `apt-get update` sempre instale a versão mais alta possivel, que pode não ser apropriado para suas necessidades de estabilidade.

1. Para instalar uma versão específica do Docker CE.

    Liste as versões disponíveis no repositório com o comando abaixo:
    
        apt-cache madison docker-ce
        
    1. Lista de versões disponíveis no seu repositório:
    
            docker-ce | 5:18.09.5~3-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 5:18.09.4~3-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 5:18.09.3~3-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 5:18.09.2~3-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 5:18.09.1~3-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 5:18.09.0~3-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 18.06.3~ce~3-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 18.06.2~ce~3-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 18.06.1~ce~3-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 18.06.0~ce~3-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 18.03.1~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 18.03.0~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.12.1~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.12.0~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.09.1~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.09.0~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.06.2~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.06.1~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.06.0~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.03.3~ce-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.03.2~ce-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.03.1~ce-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
            docker-ce | 17.03.0~ce-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages

    1. Instale uma versão específica usando a linha de versão da segunda coluna, por exemplo, `5:18.09.5~3-0~debian-stretch`.
    
            apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io

    1. Verifique que o Docker CE esta instalado corretamente rodando a imagem `hello-world`.
    
            docker run hello-world
            
        Este comando baixa uma imagem teste e roda em um container. Quando o container roda, ele imprime uma mensagem informativa e sai.

Docker CE esta instalado e rodando. O grupo `docker` é criado mas não são adicionados usuários nele. você precisa usar o `sudo` para rodar os comandos Docker. Para permitir usuários não privilegiados a rodar os comandos do Docker e para outras configurações adicionais clique [aqui](https://docs.docker.com/install/linux/linux-postinstall/).


Fonte: [Docker](https://docs.docker.com/install/linux/docker-ce/debian/)