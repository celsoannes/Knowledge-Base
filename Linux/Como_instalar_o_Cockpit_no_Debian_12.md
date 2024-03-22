# Como instalar o Cockpit no Debian 12

## 1. Atualizar a lista de pacotes
Quando você estiver no terminal do Debian, a próxima tarefa será executar o comando de atualização do sistema, para que nosso sistema tenha as atualizações de segurança mais recentes e a lista de pacotes APT atualizada.

````shell
apt update
````

````shell
apt upgrade
````

## 2. Etapas para configurar o Cockpit no Linux Debian 12 ou 11

````shell
apt install cockpit
````

## 3. Acessar a interface da Web do Cockpit
Após a conclusão da instalação, abra o navegador que pode acessar o endereço IP ou o domínio em que o Cockpit foi instalado. No entanto, não se esqueça de abrir a porta número `9090` se você tiver um firewall ativo.

Na URL do navegador, digite https://ip-do-servidor:9090

Substitua `ip-do-servidor` pelo endereço real.

## 4. Faça login com seu nome de usuário do Debian
Agora, na interface de login do Cockpit, você pode usar qualquer usuário que tenha no Debian para fazer login. Para obter controle total, você pode usar o usuário `root` ou um usuário com permissões de súper usuario.

Login no painel do Cockpit
## 5. Painel de controle do Cockpit no Debian 11 | 12
Agora, você terá o Dashboard do Cockpit com várias configurações e valores de monitoramento do sistema em tempo real. A partir daqui, você pode ficar de olho na carga do seu sistema.

Por padrão o usuário `root` vem bloqueado para acesso, se quiser fazer acesso diretamente com o usuário root, basta comentar ele:

````shell
vi /etc/cockpit/disallowed-users
````

````shell
# List of users which are not allowed to login to Cockpit
#root
````

## 6. Podman para o Cockpit para executar contêineres
Se você também quiser criar e executar contêineres usando a interface do Cockpit, isso também é possível. Para isso, instale o pacote `cockpit-podman` em seu terminal de comando.

````shell
apt install cockpit-podman
````

Quando a instalação estiver concluída, vá para o Dashboard e lá você verá a opção Podman Containers.

## 7. Atualizações e desinstalação
As futuras atualizações do Cockpit serão instaladas automaticamente quando você executar o comando de atualização e upgrade do sistema, ou seja

````shell
apt update && sudo apt upgrade
````

No entanto, aqueles que, no futuro, não quiserem mais o Cockpit em seu Linux Debian 12 ou 11, poderão executar o comando de desinstalação:

````shell
apt autoremove cockpit*
````

Qual é a porta do Linux cockpit?
O número de porta padrão usado pelo Cockpit é a porta 9090, que pode ser usada junto com o endereço IP do servidor para acessar o Dashboard.

O cockpit é um servidor da Web?
Não, o Cockpit é uma ferramenta de gerenciamento de servidor que oferece uma interface baseada na Web para gerenciar facilmente servidores Linux remotos ou locais.

Podemos usar o Docker no Cockpit?
Em vez do Docker, por padrão o Cockpit oferece o Podman compatível com o Docker para criar contêineres usando a interface da Web.

Fontes: [Linux Shout](https://linux.how2shout.com/how-to-install-cockpit-in-debian-11-or-12-servers-or-desktops/), [cockpit](https://cockpit-project.org/running.html#debian)