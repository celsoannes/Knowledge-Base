# Como exportar e importar bancos no PostgreSQL
Estando logado como *root* registre-se com o usuario *postgres* rodando o comando abaixo:
    
    su postgres

## Exportar um banco de dados
Rode o comando abaixo para exportar um banco de dados:

    pg_dump <database_name> > database_name.pgdump

Rode o comando abaixo caso queira exportar todos os bancos:

    pg_dumpall -o > db_all.out

## Importar um banco de dados
Rode o comando abaixo para importar um banco de dados:

    cat database_name.pgdump | psql -d database_name

Rode o comando abaixo caso queira exportar todos os bancos:

    psql -e template1 < db_all.out

Fonte: [IT Base of Knowledge's Weblog](https://itbdc.wordpress.com/2008/06/23/export-import-postgresql-database)