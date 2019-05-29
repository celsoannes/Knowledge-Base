# Instalando PostgreSQL no Debian 9

PostgreSQL ou Postgres, é um sistema de gerenciamento de banco de dados relacional que provê um implementação de linguagem de consulta SQL. Ele é uma escolha popular para projetos pequenos e grandes e possui a vantagem de ser compatível com os padrões e possuir varias configurações avançadas como transações confiáveis e leitura simultâneas sem bloqueio.

## Instalando PostgreSQL
 
 1. Atualize o indice de repositório, então instale o postgres junto com o pacote ``-contrib`` que irá adicionar algumas utilidades e funcionalidades a mais.
 
    ```bash
    apt-get update
    apt-get install postgresql postgresql-client postgresql-contrib
    ```
    
1. Por padrão o PostgreSQL vem com um banco e um usuário chamado ``postgres``. Mude para o usuário postgres para executar os comandos do PostgreSQL. Você deve executar o comando abaixo registrado como ``root``.
  
    ```bash
    su postgres
    ```

1. Agora execute o comando abaixo para entrar no PostgreSQL.

    ```bash
    psql
    ```

1. Defina uma senha para o usuário ``postgres`` com o seguinte comando:

    ```bash
    postgres=# \password postgres
    ```

1. Instale o [PostgreSQL Adminpack](https://www.postgresql.org/docs/9.1/adminpack.html), entre com o seguinte comando no terminal do ``postgres``:

    ```bash
    postgres=# CREATE EXTENSION adminpack;
    ```

1. Altere o mode de autenticação do PostgreSQL para ``md5`` no arquivo ``pg_hba.conf`` para que sempre seja solicitada a senha e permitido o acesso externo.

    ```bash
    vi /etc/postgresql/9.6/main/pg_hba.conf
    ```
    
    Encontre a linha abaixo:
    
    ```bash
    # "local" is for Unix domain socket connections only
    local   all             all                                     peer
    ```
    
    Substitua ``peer`` por ``md5``:
    
    ```bash
    # "local" is for Unix domain socket connections only
    local   all             all                                     md5
    ```

    Para poder acessar o servidor PostgreSQL a partir de outras máquinas adicione a seguinte linha ao final do arquivo:
   
    ```bash
    host    all             all             0.0.0.0/0               md5
    ```

1. Habilite a conexão por TCP/IP para que seja possível acessar o banco a partir de outros computadores, edite o arquivo ``postgresql.conf``.

    ```bash
    vi /etc/postgresql/9.6/main/postgresql.conf
    ```
    
    Encontre e remova os comentários das seguintes linhas:
    
    ```bash
    #listen_addresses = 'localhost'
    #password_encryption = on
    ```
    
    Para:
    
    ```bash
    listen_addresses = 'localhost'
    password_encryption = on
    ```
    
    Ainda na linha ``listen_addresses`` altere ``localhost`` por ``*``, ficando assim:
    
    ```bash
    listen_addresses = '*'
    ```
    
1. Reinicie o PostgreSQL para que as mudanças tenham efeito:

    ```bash
    service postgresql restart
    ```