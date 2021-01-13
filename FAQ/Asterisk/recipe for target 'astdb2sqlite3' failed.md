# recipe for target 'astdb2sqlite3' failed

### Ambiente
* Debian 9
* Asterisk 13.38.1

### Problema

* Ao executar o comando `make` a seguinte mensagem é apresentada:


    /usr/src/asterisk-13.38.1/Makefile.rules:201: recipe for target 'astdb2sqlite3' failed
    make[1]: *** [astdb2sqlite3] Error 1
    Makefile:394: recipe for target 'utils' failed
    make: *** [utils] Error 2

### Solução

Rode o seguinte comando:

    apt-get install libsqlite3-dev


Fonte: [wiki.asterisk.org](https://wiki.asterisk.org/wiki/display/AST/SQLite3+astdb+back-end)