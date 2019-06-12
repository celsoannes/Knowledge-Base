# Como Instalar e Configurar ODBC no Debian 9

1. Instale os drivers do ODBC usando o seguinte comando:

    ```bash
    apt-get install unixodbc unixodbc-dev
    ```

1. Instale o conector ODBC para o banco de dados:

    ```bash
    apt-get install odbc-postgresql
    ```
1. Configurando ODBC para PostgreSQL Edite o arquivo ``odbcinst.ini`` para que fique da seguinte maneira:

    ```bash
    vi /etc/odbcinst.ini
    ```
    
    ```bash
    [PostgreSQL ANSI]
    Description=PostgreSQL ODBC driver (ANSI version)
    Driver=psqlodbca.so
    Setup=libodbcpsqlS.so
    Debug=0
    CommLog=1
    UsageCount=1

    [PostgreSQL Unicode]
    Description=PostgreSQL ODBC driver (Unicode version)
    Driver=psqlodbcw.so
    Setup=libodbcpsqlS.so
    Debug=0
    CommLog=1
    UsageCount=1
    ```

    Verifique se o sistema é capaz de ver o driver executando o seguinte comando:
    
    ```bash
    odbcinst -q -d
    ```
    
    O retorno deve ser parecido com o seguinte:
    
    ```bash
    [PostgreSQL ANSI]
    [PostgreSQL Unicode]
    ```
    
    Configure o arquivo ``odbc.ini``, este arquivo possui todas as informações sobreo banco que o Asterisk irá usar.
    
    ```bash
    /etc/odbc.ini
    ```
    
    ```bash
    [asterisk]
    Description         = PostgreSQL connection to 'asterisk' database
    Driver              = PostgreSQL Unicode
    Database            = asterisk
    Servername          = localhost
    UserName            = asterisk
    Password            = welcome
    Port                = 5432
    Protocol            = 9.6
    ReadOnly            = No
    RowVersioning       = No
    ShowSystemTables    = No
    ShowOidColumn       = No
    FakeOidIndex        = No
    ConnSettings        =
    ```

1. Validando o conector ODBC Verifique a conexão do ODBC com o banco de dados usando o seguinte comando:

    ```bash
    echo "select 1" | isql -v asterisk
    ```

    A saída deverá ser parecida com esta:
    
    ```sql
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
    | ?column?   |
    +------------+
    | 1          |
    +------------+
    SQLRowCount returns 1
    1 rows fetched
    ```

1. Configure o ``res_odbc.conf`` para permitir que o Asterisk conecte através do ODBC. Altere o ``res_odbc.conf`` para que ele fique da seguinte maneira:

    ```bash
    vi /etc/asterisk/res_odbc.conf
    ```
 
    ```bash
    [ENV]
    PGCLIENTENCODING => UTF8

    [asterisk]
    enabled => yes
    dsn => asterisk
    pre-connect => yes
    ```

    Depois de configurar o arquivo reinicie o Asterisk
    
    ```bash
    service asterisk restart
    ```
    
    Para verificar se o Asterisk esta conectado ao banco de dados através do ODBC execute o seguinte comando:
    
    ```bash
    asterisk -rx "odbc show"
    ```
    
    A saída deve ser parecida com as linhas abaixo:
    
    ```bash
    ODBC DSN Settings
    -----------------

      Name:   asterisk
      DSN:    asterisk
      Last connection attempt: 1969-12-31 21:00:00
    ```




Fonte: [Asterisk Guide](http://www.asteriskdocs.org/en/3rd_Edition/asterisk-book-html-chunk/installing_configuring_odbc.html)

