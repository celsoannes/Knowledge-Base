# Como Instalar o Ruby on Rails no Debian 12

Neste tutorial, mostraremos como instalar o Ruby on Rails no Debian 12. Para aqueles que não sabem, o Ruby on Rails, frequentemente referido como Rails, é um poderoso e elegante framework de aplicativos da web que facilita o desenvolvimento de sites e aplicativos robustos e dinâmicos.

Este artigo pressupõe que você tenha pelo menos conhecimento básico de Linux, saiba como usar o shell e, o mais importante, hospede seu site em seu próprio VPS. A instalação é bastante simples e pressupõe que você está executando a conta de root. Se não estiver, talvez precise adicionar 'sudo' aos comandos para obter privilégios de root. Mostrarei a você a instalação passo a passo do Ruby on Rails em um Debian 12 (Bookworm).

### Pré-requisitos

* Um servidor executando um dos seguintes sistemas operacionais: **Debian 12** _(Bookworm)_.
* É recomendável usar uma instalação limpa do sistema operacional para evitar possíveis problemas.
* Acesso SSH ao servidor (ou simplesmente abra o Terminal se estiver em um ambiente de desktop).
* Uma conexão de internet ativa. Você precisará de uma conexão de internet para baixar os pacotes e dependências necessários para o Ruby on Rails.
* Um usuário `sudo` não `root` ou acesso à conta de `root`. Recomendamos agir como um usuário `sudo` não `root`, no entanto, tenha cuidado ao agir como `root`, pois você pode danificar o sistema se não tomar cuidado.

## Instalar o Ruby on Rails no Debian 12 Bookworm
**Passo 1**. Antes de instalarmos qualquer software, é importante garantir que seu sistema esteja atualizado, executando os seguintes comandos `apt` no terminal:

````shell
sudo apt update
sudo apt install build-essential libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev
````

Este comando irá atualizar o repositório, permitindo que você instale as versões mais recentes dos pacotes de software.

**Passo 2**. Escolha um Gerenciador de Versões do Ruby.

Os Gerenciadores de Versões do Ruby (RVM) oferecem uma maneira conveniente de instalar e gerenciar diferentes versões do Ruby em seu sistema. Aqui, vamos nos concentrar no RVM, uma escolha popular entre os desenvolvedores. Para instalar o RVM, siga estas etapas:

````shell
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
````

Em seguida, instale o RVM com a versão estável:

```shell
curl -sSL https://get.rvm.io | bash -s stable
```

Para começar a usar o RVM, você precisa carregá-lo no seu shell. Execute o seguinte comando:

````shell
source ~/.rvm/scripts/rvm
````

**Passo 3**. Instalando o Ruby.

Com o RVM instalado, podemos prosseguir com a instalação do Ruby no Debian 12. Siga os passos abaixo:

```shell
rvm install ruby --latest
```

>Caso se depare com a seguinte mensagem de erro:
> ````shell
> Error running '__rvm_make -j4',
> please read /home/mako/.rvm/log/1696356387_ruby-2.7.2/make.log
>
> There has been an error while running make. Halting the installation.
>````
> Instale pacote ssl compativel com o ruby 
>````shell
> rvm pkg install openssl
>````
> Repita a instalação forçando o uso do pacote ssl que foi baixado
> ````shell
> rvm install <ruby version here> --with-openssl-dir=$rvm_path/usr
> ````
> Ficaria assim:
> ```shell
> rvm install ruby-2.7.2 --with-openssl-dir=/home/mako/.rvm/usr
> ```

Este comando irá automaticamente baixar, compilar e instalar a versão estável mais recente do Ruby.

Para definir a versão padrão do Ruby para o seu sistema, use o seguinte comando:
````shell
rvm use ruby --default
````

**Passo 4**. Instalando o Ruby on Rails.

Agora que o Ruby está instalado, podemos prosseguir com a instalação do Ruby on Rails. Execute o seguinte comando:

````shell
gem install rails
````

Para garantir que o Ruby e o Ruby on Rails tenham sido instalados corretamente, execute os seguintes comandos:

````shell
ruby -v
rails -v
````

Você deverá ver os números da versão do Ruby e do Ruby on Rails, confirmando uma instalação bem-sucedida.

**Passo 5**. Criando um Projeto de Amostra em Rails.

Para obter experiência prática, vamos criar um projeto de amostra em Rails. Abra o terminal e navegue até o diretório desejado onde você deseja criar o projeto. Execute o seguinte comando:

````shell
rails new sample_project
````


Este comando criará um novo projeto Rails chamado `sample_project` no diretório atual.

**Passo 6**. Solução de Problemas.

Se você encontrar algum problema durante o processo de instalação, aqui estão algumas dicas de solução de problemas:

* Verifique novamente se você atendeu a todos os pré-requisitos e seguiu os passos de instalação com precisão.
* Certifique-se de ter uma conexão de internet ativa durante o processo de instalação.
* Consulte a documentação oficial do Ruby on Rails para guias de solução de problemas detalhados e perguntas frequentes.
* 
Parabéns! Você instalou com sucesso o Ruby on Rails. Obrigado por utilizar este tutorial para instalar a versão mais recente do Ruby on Rails no Debian 12 Bookworm. Para obter ajuda adicional ou informações úteis, recomendamos que você verifique o site oficial do [Ruby on Rails](https://rubyonrails.org/).

Fonte: [idroot](https://rubyonrails.org/)