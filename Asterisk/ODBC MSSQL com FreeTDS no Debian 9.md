# ODBC MSSQL com FreeTDS no Debian 9

1. Instale os drivers do ODBC usando o seguinte comando:

    ```bash
    apt-get install unixodbc unixodbc-dev
    ```

1. Instale o pacote do FreeTDS

    ```bash
    apt-get install tdsodbc
    ```

1. Procure onde biblioteca `libtdsodbc.so` foi instalada:

    ```bash
    find / -name libtdsodbc.so
    ```
    
1. Será retornada uma linha semelhante a abaixo:
    
    ```bash
    /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so
    ```

1. Configure os arquivos ODBC. Não é necessário armazenar o usuario e senhas aqui.

    `/etc/odbcinst.ini`

    ```bash
    [FreeTDS]
    Description=FreeTDS ODBC driver for MSSQL
    Driver=/usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so
    FileUsage=1
    UsageCount=1
    ```
    
    `/etc/odbc.ini`
    
    ```bash
    [MSSQL-asterisk]
    description         = Asterisk ODBC for MSSQL
    driver              = FreeTDS
    server              = 192.168.1.25
    port                = 1433
    database            = voipdb
    ```

1. Teste a conexão com o banco usando o comando abaixo:

    ```bash
    echo "select 1" | isql -v MSSQL-asterisk <USUARIO> <SENHA>
    ```

    Você verá uma saída como esta:
    
    ```bash
    +---------------------------------------+
    | Connected!                            |
    |                                       |
    | sql-statement                         |
    | help [tablename]                      |
    | quit                                  |
    |                                       |
    +---------------------------------------+
    SQL> select 1
    +------------+
    |            |
    +------------+
    | 1          |
    +------------+
    SQLRowCount returns 1
    1 rows fetched
    SQL>
    ```

1. Configure o `res_odbc.conf` para permitir que o Asterisk conecte através do ODBC. Altere o  arquivo `/etc/asterisk/res_odbc.conf` para que ele fique da seguinte maneira:

    ```bash
    [client_mssql]
    enabled=yes
    dsn=MSSQL-asterisk
    username=SEU_USUARIO
    password=SUA_SENHA
    pre-connect=yes
    logging=yes
    loguniqueid=yes
    ```

1. Reinicie o asterisk e verifique a conexão com o comando abaixo:

    ```bash
    asterisk*CLI> odbc show mazer
    ```
    
    Você verá um retorno parecido com o abaixo:
    
    ```bash
    ODBC DSN Settings
    -----------------
    
      Name:   client_mssql
      DSN:    MSSQL-asterisk
        Number of active connections: 1 (out of 1)
        Logging: Enabled
        Number of prepares executed: 0
        Number of queries executed: 0
    ```
    


Fonte: [QA Stack](https://qastack.com.br/ubuntu/578934/mssql-connection-from-ubuntu)

Fonte: [Designed For Satisfaction](http://guywyant.info/log/206/connecting-to-ms-sql-server-from-ubuntu/)

Fonte: [Voip-info.org](https://www.voip-info.org/freetds/)
