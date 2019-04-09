# Backup e Restore no MySQL

## 1. Fazendo Backup de um banco MySQL

### 1.1 Fazendo Backup de um único banco:
O comando abaixo irá fazer o backup de um único banco:

    mysqldump -u root -ptmppassword sugarcrm > sugarcrm.sql

    mysqldump -u root -p[root_password] [database_name] > dumpfilename.sql

### 1.2 Fazendo Backup de múltiplos bancos:
Se você quer fazer o backup de múltiplas tabelas, primeiro identifique os bancos que você deseja fazer backup usando o ```show databases``` como mostrado abaixo:

    mysql -u root -ptmppassword
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | bugs               |
    | mysql              |
    | sugarcr            |
    +--------------------+
    4 rows in set (0.00 sec)

Por exemplo, se você quiser fazer um backup das tabelas ```sugarcrm``` e ```bugs```, execute o ```mysqldump``` como mostrado abaixo:

    # mysqldump -u root -ptmppassword --databases bugs sugarcrm > bugs_sugarcrm.sql

Verifique que o arquivo ```bugs_sugarcrm.sql``` contem o backup dos dois bancos.

    grep -i "Current database:" /tmp/bugs_sugarcrm.sql
    -- Current Database: `mysql`
    -- Current Database: `sugarcrm`

### 1.3 Fazendo Backup de todos os bancos:
O exemplo abaixo faz um backup de todos os bancos daquela instância MySQL.

    mysqldump -u root -ptmppassword --all-databases > /tmp/all-database.sql

### 1.4 Fazendo Bakcup de uma tabale específica.
Neste exemplo iremos fazer o backup apenas da tabela ```accounts_contacts``` do banco ```sugarcrm```.

    mysqldump -u root -ptmppassword sugarcrm accounts_contacts \
    > /tmp/sugarcrm_accounts_contacts.sql

## 2. Fazendo Restore de um banco MySQL

### 2.1 Restaurando um banco
Neste exemplo, para restaurar o banco ```sugarcrm```, rode o comando com o ```<``` conforme mostrado abaixo. Quando você estiver restaurando o ```dumpfilename.sql``` em um banco de dados remoto, certifique-se de criar o banco de dados ```sugarcrm``` antes de realizar a restauração.

    mysql -u root -ptmppassword

    mysql> create database sugarcrm;
    Query OK, 1 row affected (0.02 sec)

    mysql -u root -ptmppassword sugarcrm < /tmp/sugarcrm.sql

    mysql -u root -p[root_password] [database_name] < dumpfilename.sql

### 2.2 Fazendo Backup de um banco de dados e restaurando em um servidor remoto em um único comando:
Esta é uma opção elegante, se você quer manter um banco de dados de apenas leitura no servidor remoto. O exemplo abaixo irá fazer o backup do banco ```sugarcrm``` no servidor local e restaurar ele como banco de dados ```sugarcrm1``` no servidor remoto. Por favor, note que você deve criar primeiro o banco ```sugarcrm1``` no servidor remoto antes de executar o comando.

    [local-server]# mysqldump -u root -ptmppassword sugarcrm | mysql \
    -u root -ptmppassword --host=remote-server -C sugarcrm1

Fonte: [The Geek Stuff](https://www.thegeekstuff.com/2008/09/backup-and-restore-mysql-database-using-mysqldump)