# Como instalar OpenSSL 1.1.1 no Debian 8

O `OpenSSL 1.1.1` não está disponível nos repositórios do `Debian 8`, por isso é necessário baixar e compilar manualmente.

1. Baixar OpenSSL 1.1.1

    Baixe a última versão disponível do [OpenSSL 1.1.1](https://www.openssl.org/source/)
    
    ```bash
    cd /usr/src
    wget https://www.openssl.org/source/openssl-1.1.1i.tar.gz
    ```

1. Instale o OpenSSL a partir do `tar.gz`

    Crie a pasta  `/opt/openssl`
    
    ```bash
    mkdir /opt/openssl
    ```

    Descompacte o OpenSSL na pasta designada
    
    ```bash
    tar -zxvf /usr/src/openssl-1.1.1i.tar.gz --directory /opt/openssl
    ```
    
    Verifique se você possui **perl 5** ou superior
    
    ```bash
    perl --version

    This is perl 5, version 20, subversion 2 (v5.20.2) built for x86_64-linux-gnu-thread-multi
    (with 103 registered patches, see perl -V for more detail)
    
    Copyright 1987-2015, Larry Wall
    
    Perl may be copied only under the terms of either the Artistic License or the
    GNU General Public License, which may be found in the Perl 5 source kit.
    
    Complete documentation for Perl, including FAQ lists, should be found on
    this system using "man perl" or "perldoc perl".  If you have access to the
    Internet, point your browser at http://www.perl.org/, the Perl Home Page.
    ```
    
    Crie a variável de ambiente `LD_LIBRARY_PATH` com o seguinte valor
    
    ```bash
    export LD_LIBRARY_PATH=/opt/openssl/lib
    ```
    
    Verifique se o valor foi definido corretamente
    
    ```bash
    echo $LD_LIBRARY_PATH
    ```
    
    ```bash
    /opt/openssl/lib
    ```
    
    Execute o comando `config`
    
    ```bash
    cd /opt/openssl/openssl-1.1.1i
    ./config --prefix=/opt/openssl --openssldir=/opt/openssl/ssl
    ```
    
    ```bash
    Operating system: x86_64-whatever-linux2
    Configuring OpenSSL version 1.1.1i (0x1010109fL) for linux-x86_64
    Using os-specific seed configuration
    Creating configdata.pm
    Creating Makefile
    
    **********************************************************************
    ***                                                                ***
    ***   OpenSSL has been successfully configured                     ***
    ***                                                                ***
    ***   If you encounter a problem while building, please open an    ***
    ***   issue on GitHub <https://github.com/openssl/openssl/issues>  ***
    ***   and include the output from the following command:           ***
    ***                                                                ***
    ***       perl configdata.pm --dump                                ***
    ***                                                                ***
    ***   (If you are new to OpenSSL, you might want to consult the    ***
    ***   'Troubleshooting' section in the INSTALL file first)         ***
    ***                                                                ***
    **********************************************************************
    ```
    
    Agora rode o comando `make`
    
    ```bash
    make
    ```
    
    Execute o comando `make test` para verificar possíveis erros
    
    ```bash
    make test
    ```
    ```bash
    ../test/recipes/90-test_tls13ccs.t ................. ok
    ../test/recipes/90-test_tls13encryption.t .......... ok
    ../test/recipes/90-test_tls13secrets.t ............. ok
    ../test/recipes/90-test_v3name.t ................... ok
    ../test/recipes/95-test_external_boringssl.t ....... skipped: No external tests in this configuration
    ../test/recipes/95-test_external_krb5.t ............ skipped: No external tests in this configuration
    ../test/recipes/95-test_external_pyca.t ............ skipped: No external tests in this configuration
    ../test/recipes/99-test_ecstress.t ................. ok
    ../test/recipes/99-test_fuzz.t ..................... ok
    All tests successful.
    Files=158, Tests=2633, 129 wallclock secs ( 2.72 usr  0.21 sys + 92.67 cusr  5.30 csys = 100.90 CPU)
    Result: PASS
    ```
    
    Rode o comando `make install`
    
    ```bash
    make install
    ```
    
    Reconstrua o cache de biblioteca com o comando:
    
    ```bash
    updatedb
    ```
    
    Verifique a localização do binario do `openssl` com o seguinte comando:
    
    ```bash
    locate openssl | grep /opt/openssl/bin
    ```
    ```bash
    /opt/openssl/bin
    /opt/openssl/bin/c_rehash
    /opt/openssl/bin/openssl
    ```
    
    O diretório `/usr/bin` também possuí o binário `openssl` da versão anterior. A presença desta versão `openssl` _indesejada_ irá causar problemas, então temos que verificar!
    
    Execute o comando abaixo para rastrear o binário `/usr/bin/openssl`:
    
    ```bash
    cd /usr/bin
    ls -l openssl
    mv openssl openssl.old
    ```
    
1. Configure o caminho `PATH` da variável de ambiente

    é Preciso configurar o caminho `PATH` da variável de ambiente do `OpenSSL` conforme mostrado abaixo.
    
    Crie um arquivo chamado `openssl.sh` na pasta  de destino `/etc/profile.d/`:
    
    ```bash
    touch /etc/profile.d/openssl.sh
    vi /etc/profile.d/openssl.sh
    ```
    
    Adicione o seguinte conteúdo:
    
    ```bash
    #!/bin/sh
    export PATH=/opt/openssl/bin:${PATH}
    export LD_LIBRARY_PATH=/opt/openssl/lib:${LD_LIBRARY_PATH}
    ```
    
    Salve e feche o arquivo. Faça ele executável usando o seguinte comando:
     
    ```bash
    chmod +x /etc/profile.d/openssl.sh
    ```
    
    Defina a variável de ambiente permanentemente rodando o seguinte comando:
    
    ```bash
    source /etc/profile.d/openssl.sh
    ```
    
    **Relogue ou reinicie o sistema.**
    
    Agora, verifique o caminho `PATH` da variável de ambiente.
    
    ```bash
    echo $PATH
    ```
    ```bash
    /opt/openssl/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ```
    >O caminho `PATH` da variável de ambiente possui a pasta `/opt/openssl/bin`.
    
    ```bash
    which openssl
    ```
    >O binário `openssl` se encontra em `/opt/openssl/bin/openssl`.
    
    Agora, verifique a versão do openssl com o seguinte comando:
    
    ```bash
    openssl version
    ```
    ```bash
    OpenSSL 1.1.1i  8 Dec 2020
    ```
    > `openssl` está em sua ultima atualização disponível
    
    Agora verifique a versão do openssl usando a ferramenta de linha de comando:
    
    ```bash
    openssl
    ```
    ```bash
    OpenSSL> version
    OpenSSL 1.1.1i  8 Dec 2020
    OpenSSL>
    ```

Fonte: [Ask Ubuntu](https://askubuntu.com/questions/1126893/how-to-install-openssl-1-1-1-and-libssl-package)