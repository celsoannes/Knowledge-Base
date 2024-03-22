# Configurando LDAP no Debian 11

1. Instalando pacotes

    ```bash
    apt-get update
    apt-get install libnss-ldapd libpam-ldapd
    ```

1. Configurando

    ![Configuração de Pacotes LDAP](./images/ldap_configuracao_nslcd_001.png)
    
    ![Configuração de Pacotes LDAP](./images/ldap_configuracao_nslcd_002.png)

    ![Configuração de Pacotes LDAP](./images/ldap_configuracao_libnss-ldap.png)

1. Criando pasta `home` automaticamente ao fazer o login

    Adicione a seguinte linha no arquivo `common-account`:
    
    ```bash
    vi /etc/pam.d/common-account
    ```
    
    ```bash
    session    required   pam_mkhomedir.so skel=/etc/skel/ umask=0022
    ```

    Certifique-se de que a opção `UsePAM yes` esta descomentada no arquivo `sshd_config`:
    
    ```bash
    vi /etc/ssh/sshd_config
    ```
    
    ```bash
    UsePAM yes
    ```