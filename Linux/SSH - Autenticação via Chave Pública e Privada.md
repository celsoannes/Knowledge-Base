# SSH - Autenticação via Chave Pública e Privada

1. Crie o par de chaves para cada usuario, então faça o login com o usuario que você gostaria de criar a chave de autenticação executando o seguinte comando `ssh-keygen`:

    ```bash
    celso@debian:~$ ssh-keygen
    ```

    Pressione `Enter` para manter o nome `id_rsa` conforme sugerido
    
    ```bash
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/celso/.ssh/id_rsa):                Created directory '/home/anequim/.ssh'.
    ```
    
    Informe uma senha ou deixe em branco e pressione `Enter`:
    
    ```bash
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    ```
    
    Dando tudo certo você verá uma saída semelhante com a abaixo
    ```bash
    Your identification has been saved in /home/celso/.ssh/id_rsa.
    Your public key has been saved in /home/celso/.ssh/id_rsa.pub.
    The key fingerprint is:
    SHA256:YLXihIJZ+PpC35LReQe/PtiKJEt5hrA5Hj0g/hgoWi4 celso@debian
    The key's randomart image is:
    +---[RSA 2048]----+
    | ..     .        |
    |.+   . . .       |
    |o.. . = .        |
    |  .. + +         |
    |.+  . o S        |
    |=.*.oo . o       |
    |+OoB++. + .      |
    |EoO+B... +       |
    |.=.o.. .o..      |
    +----[SHA256]-----+
    ```

1. Transferir a chave secreta criada no servidor para um cliente, então é possível fazer o login com a autenticação de par de chaves.

    Crie a pasta `.ssh` na pasta `home` do usuario caso ela não exista

    ```bash
    cliente@remoto:~$ mkdir ~/.ssh 
    cliente@remoto:~$ chmod 700 ~/.ssh
    ```

    Copie a chave secreta para o diretório ssh local

    ```bash
    cliente@remoto:~$ scp celso@debian:/home/celso/.ssh/id_rsa ~/.ssh/ 
    celso@debian's password:
    id_rsa
    ```

1. Se você definir `[PasswordAuthentication no]`, será mais seguro.

    ```bash
    vi /etc/ssh/sshd_config
    ```
    
    ```bash
    PasswordAuthentication no
    ```
    
    ```bash
    systemctl restart ssh 
    ```



Fonte: [Server World](https://www.server-world.info/en/note?os=Debian_9&p=ssh&f=4)