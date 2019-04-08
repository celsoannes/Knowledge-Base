# Restauração de Backup
Esses comandos devem ser disparados a partir de uma máquina cujo boot foi realizado através de um **live-cd** ou **similar**. A máquina de origem não pode ter nenhum serviço rodando, especialmente o **Asterisk** e o **MySQL**.

[Link para download do Debian Live (USB)](http://ftp.br.debian.org/debian-cd/8.2.0-live/amd64/iso-hybrid/debian-live-8.2.0-amd64-standard.iso)

Para criar o pendrive bootável a partir do Windows, utilize o [Win32DiskImager](http://downloads.sourceforge.net/project/win32diskimager/Archive/Win32DiskImager-0.9.5-binary.zip) outra alternativa é utilizar o [Rufus](https://rufus.ie/). Caso utilize-se **Linux** ou **Mac OS X**, basta rodar este comando:

    dd if=debian-live-6.0.3-i386-standard.img of=/dev/sdX
Onde **sdX** é o dispositivo do pendrive.

Caso isso seja feito através da Internet, deve-se adicionar o parâmetro z ao rsync, para que seja feita a compressão dos dados. Não deve ser utilizada compressão em rede local.

Os dois primeiros comandos devem ser necessariamente feitos no terminal físico. Os demais podem ser feitos via SSH.
Login e senha para acessar o linux live

    Login : user
    Password : live

    aptitude update
    apt-get install ssh rsync

Após instalar o SSH será necesasrio acessar o arquivo */etc/ssh/sshd_config*.

    PasswordAuthentication no

Alterar o paramentro *PasswordAuthentication* de *no* para *yes*:

    PasswordAuthentication yes

Após aterar o prametro será necessario reinicializar o SSH :

    /etc/init.d/ssh stop
    /etc/init.d/ssh start

Escolha o tipo dos se pedir opções não usar GPD

    cfdisk /dev/sda

Se você receber a seguinte mensagem de erro:

    Warning!! Unsupported GPT (GUID Partition Table) detected. Use GNU Parted.

Faça o seguinte procedimento:

    apt-get install parted
    root@debian:/home/user# parted /dev/sda
    GNU Parted 2.3
    Using /dev/sda
    Welcome to GNU Parted! Type 'help' to view a list of commands.
    (parted) mklabel msdos
    (parted) quit

Crie duas partições: uma com o tamanho total do disco menos 1024MB e outra com o restante. A primeira deve ser do tipo Linux (83) e a segunda tipo Linux Swap (82). O resultado final deve ser similar a este:

                                     cfdisk (util-linux-ng 2.17.2)                                  
                                                                                                    
                                          Disk Drive: /dev/sda                                      
                                   Size: 250059350016 bytes, 250.0 GB                               
                         Heads: 255   Sectors per Track: 63   Cylinders: 30401                      
                                                                                                    
        Name           Flags        Part Type    FS Type             [Label]           Size (MB)    
     ---------------------------------------------------------------------------------------------- 
        sda1                         Primary     Linux ext3                            249003.91    
        sda2                         Primary     Linux swap / Solaris                    1052.84    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
          [ Bootable ]  [  Delete  ]  [   Help   ]  [ Maximize ]  [  Print   ]  [   Quit   ]        
          [   Type   ]  [  Units   ]  [  Write   ]                                                  
                                                                                                    
                              Quit program without writing partition table

Caso apareça a seguinte mensagem:

                              FATAL ERROR: Bad primary partition 1: Partition ends in the final partial cylinder
                                                      Press any key to exit cfdisk

Prossiga com o seguinte comando:

    dd if=/dev/zero of=/dev/sda bs=1024 count=10

Após definida as partições, formate os volumes:

    mkfs.ext4 /dev/sda1
    mkswap /dev/sda2
    mkdir /target
    mount /dev/sda1 /target

O próximo comando vai copiar todos os dados da origem para o destino. Caso a origem seja um backup armazenado no servidor ssh, deve-se utilizar o seu próprio usuário. A origem deve ser o diretório /backup/nomecliente. Caso a origem seja o servidor do cliente, é indispensável que todos os serviços (exceto o SSH) sejam parados. O usuário será canall e o diretório de origem será **/**

    rsync -avPH --numeric-ids --exclude=/dev --exclude=/proc --exclude=/sys [usuario]@[ip origem]:[caminho origem]/ /target/
    
    Exemplos:
    rsync -avPH --numeric-ids --exclude=/dev --exclude=/proc --exclude=/sys mauricio@ssh:/backup/uri/ /target/
    rsync -avPH --numeric-ids --exclude=/dev --exclude=/proc --exclude=/sys vinicius@ssh:/backup/lzk/ /target/
    rsync -avPH --numeric-ids --exclude=/dev --exclude=/proc --exclude=/sys canall@10.1.2.10:/ /target/
    
    Direto do IP da maquina de backup:
    rsync -avPH --numeric-ids --exclude=/dev --exclude=/proc --exclude=/sys mauricio@172.16.1.4:/backup/canall/ /target/
    
    De um PABX live:
    rsync -avzH --numeric-ids --exclude=/var/log --include=/var/log/asterisk/cdr-csv/ --exclude=/backup --exclude=/proc --exclude=/bkpallvo --exclude=/dev --exclude=/sys --exclude=/tmp --exclude=/var/spool/asterisk/monitor --exclude=/var/lib/asterisk/sounds/meetme-conf-rec-* --exclude=/mnt root@pabx-e1:/ /target/

Se usar o rsync “usuário@ssh:/backup/(nome_cliente)/” vai pedir confirmação digite 'yes' e após vai pedir a senha de seu usuário.

Se o rsync foi completado sem erros, prossiga com os seguintes comandos:

    mkdir /target/dev
    mkdir /target/proc
    mkdir /target/sys
    mkdir /target/tmp
    chmod 777 /target/tmp
    mkdir -p /target/var/log/apache2
    mkdir -p /target/var/log/apt
    mkdir -p /target/var/log/asterisk/cdr-csv
    mkdir -p /target/var/log/asterisk
    mkdir -p /target/var/log/dbconfig-common
    mkdir -p /target/var/log/exim4
    mkdir -p /target/var/log/fsck
    mkdir -p /target/var/log/installer/cdebconf
    mkdir -p /target/var/log/mysql
    mkdir -p /target/var/log/news
    mkdir -p /target/var/log/ntpstats
    mkdir -p /target/var/log/proftpd
    mkdir -p /target/var/log/zabbix

### IMPORTANTE
Verifique a existencia do seguinte arquivo:

    find /etc/udev/rules.d/ -name *persistent-net.rules
    
Caso exista e dentro dele estejam especificados os endereços MAC das interfaces de rede, apagar essas linhas. Do contrário as interfaces de rede não funcionarão.

Agora vamos acessar o Linux através de um chroot para continuar o procedimento:

    mount -o bind /dev /target/dev
    mount -o bind /sys /target/sys
    mount -o bind /proc /target/proc
    chroot /target
    vi /etc/apt/sources.list

Verifique se a seguinte linha está presente, incluindo-a ou editando-a:

    deb http://ftp.br.debian.org/debian/ squeeze main contrib non-free

Continue o procedimento com os seguintes comandos:

    aptitude update
    aptitude install firmware-linux-nonfree

Caso algum dos comandos acima tenha falhado, adicione a seguinte linha no início do _/etc/resolv.conf_ e tente novamente. Do contrário, não é necessário alterar o arquivo.

    nameserver 8.8.8.8

Anote os UUIDs das partições ext3 e swap, rodando o comando *blkid*:

    root@debian:/# blkid
    /dev/sda1: UUID="0965b73b-ac5f-4e36-a76f-e3d09c101292" TYPE="ext3"
    /dev/sdb1: SEC_TYPE="msdos" LABEL="DEBIAN_LIVE" UUID="F8DD-03AE" TYPE="vfat" 
    /dev/loop0: TYPE="squashfs" 
    /dev/sda2: UUID="d54ecd32-c523-45c3-bac5-5dca5643df94" TYPE="swap"

Nesse exemplo, as UUIDs da partição ext3 e swap são respectivamente 0965b73b-ac5f-4e36-a76f-e3d09c101292 e d54ecd32-c523-45c3-bac5-5dca5643df94.

Edite o arquivo /etc/fstab e altere as UUIDs.

    # /etc/fstab: static file system information.
    #
    # Use 'blkid' to print the universally unique identifier for a
    # device; this may be used with UUID= as a more robust way to name devices
    # that works even if disks are added and removed. See fstab(5).
    #
    # <file system> <mount point>   <type>  <options>       <dump>  <pass>
    proc            /proc           proc    defaults        0       0
    # / was on /dev/sda1 during installation
    UUID=0965b73b-ac5f-4e36-a76f-e3d09c101292 /               ext3    errors=remount-ro 0       1
    # swap was on /dev/sda2 during installation
    UUID=d54ecd32-c523-45c3-bac5-5dca5643df9 none            swap    sw              0       0

Finalize o procedimento com os seguintes comandos:

    update-initramfs -t -u
    grub-mkdevicemap
    grub-mkconfig
    update-grub
    grub-install /dev/sda

Caso você receba a mensagem:

    grub-install: error: /usr/lib/grub/i386-pc/modinfo.sh doesn't exist. Please specify --target or --directory.
Tente instalar o grub-pc (referencia: https://goo.gl/HbASiv):

    apt-get install grub-pc
Caso você receba a seguinte mensagem:

    grub-mkconfig: command not found
Prossiga com o seguinte comando:

    apt-get install grub-common
No CentOS, deve-se primeiro editar o _/etc/grub.conf_ e alterar os UUIDs de acordo, assim como deve-se verificar o caminho dos arquivos necessários para o boot em relação ao diretório _/boot_. Após isso deve-se realizar o seguinte procedimento:


    dracut -f #equivalente ao update-initramfs
    grub
    grub> find /boot/grub/stage1
    grub> root (hd0,0)
    grub> setup (hd0)
    grub> quit
    grub-install /dev/sda
Reinicie o sistema e teste o funcionamento.