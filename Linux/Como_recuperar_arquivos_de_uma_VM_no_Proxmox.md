# Como Recuperar Arquivos de uma VM no Proxmox

## Ativação dos Volumes Lógicos LVM

Primeiro, você precisa ativar os volumes lógicos dentro da partição LVM. Você pode fazer isso usando o comando `lvscan`. Execute o seguinte comando para escanear e ativar os volumes lógicos:

```shell
sudo lvscan
```

Você verá uma saída semelhante a esta:

```shell
  ACTIVE            '/dev/pve/swap' [8.00 GiB] inherit
  ACTIVE            '/dev/pve/root' [2.72 TiB] inherit
```

## Identificação do Volume Lógico

É necessário identificar o nome do volume lógico dentro da partição LVM. Você pode usar o comando `lvdisplay` para listar todos os volumes lógicos disponíveis:

```shell
lvdisplay
```

A saída será semelhante a esta:

```shell
  --- Logical volume ---
  LV Path                /dev/pve/swap
  LV Name                swap
  VG Name                pve
  LV UUID                YW49OH-83aU-Mmt0-22ZE-zAiQ-2l25-fd9MiD
  LV Write Access        read/write
  LV Creation host, time proxmox, 2023-08-16 03:05:35 +0000
  LV Status              available
  # open                 0
  LV Size                8.00 GiB
  Current LE             2048
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:0

  --- Logical volume ---
  LV Path                /dev/pve/root
  LV Name                root
  VG Name                pve
  LV UUID                7AR2mn-yrMJ-7XEP-XtuB-3iKv-82EN-cyc0yH
  LV Write Access        read/write
  LV Creation host, time proxmox, 2023-08-16 03:05:35 +0000
  LV Status              available
  # open                 1
  LV Size                2.72 TiB
  Current LE             713092
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:1
```

## Montagem do Volume Lógico

Monte o volume lógico raiz em um diretório temporário, por exemplo, `/mnt/root`:

```shell
mkdir /mnt/root
mount /dev/pve/root /mnt/root
```

Navegue até o diretório montado e procure por pastas relacionadas às VMs:

```shell
cd /mnt/root
ls
```

Os arquivos das VM poderão ser encontrados em:

```shell
cd /mnt/root/var/lib/vz/images/
```

Dentro vão estar as pastas com os arquivos das VMs:

```shell
ls
```

```shell
100  101  102  103
```

```shell
cd 100
ls
```

```shell
vm-100-disk-0.qcow2
```

## Montagem do Arquivo de Disco

Para montar o arquivo de disco `vm-100-disk-0.qcow2`, você pode usar o utilitário `qemu-nbd`, que permite montar imagens de disco QEMU (`qcow2`) como dispositivos de bloco em seu sistema. Aqui está como você pode fazer isso:

```shell
apt-get update
apt-get install qemu-utils
```

Primeiro, certifique-se de que o módulo nbd (Network Block Device) esteja carregado. Você pode fazer isso executando o seguinte comando:

```shell
modprobe nbd
```

Como a imagem do disco da VM é um arquivo `qcow2`, é necessário primeiro montá-lo usando o qemu-nbd e, em seguida, montar a partição dentro da imagem do disco. Aqui está como você pode fazer isso:

Conecte a imagem do disco da VM como um dispositivo de bloco usando o qemu-nbd:

```shell
qemu-nbd --connect=/dev/nbd0 /mnt/root/var/lib/vz/images/100/vm-100-disk-0.qcow2
```

Certifique-se de substituir `/mnt/root/var/lib/vz/images/100/vm-100-disk-0.qcow2` pelo caminho correto para o arquivo de imagem do disco da VM.

Descubra a partição dentro da imagem do disco. Você pode usar a ferramenta parted ou fdisk para isso. Por exemplo:

```shell
 fdisk -l /dev/nbd0
```

Isso deve listar as partições dentro da imagem do disco. Anote o número da partição que você deseja montar.

```shell
...
Device      Boot      Start        End    Sectors  Size Id Type
/dev/nbd0p1 *          2048 2095151103 2095149056  999G 83 Linux
/dev/nbd0p2      2095153150 2097149951    1996802  975M  5 Extended
/dev/nbd0p5      2095153152 2097149951    1996800  975M 82 Linux swap / Solaris
...
```

Monte a partição dentro da imagem do disco. Substitua `<partição>` pelo número da partição que você anotou:

```shell
mkdir /mnt/vm_mount_point
mount /dev/nbd0p<partição> /mnt/vm_mount_point
```

Certifique-se de substituir `<partição>` pelo número da partição correto.

```shell
mount /dev/nbd0p1 /mnt/vm_mount_point
```

Com esses passos, você deve ser capaz de montar a partição dentro da imagem do disco da VM com sucesso. Após a montagem, você poderá acessar os arquivos da VM dentro do diretório `/mnt/vm_mount_point`. 

```shell
cd /mnt/vm_mount_point
ls
```

```shell
bin  boot  dev  etc  home  initrd.img  initrd.img.old  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  vmlinuz  vmlinuz.old
```

Não se esqueça de desmontar o dispositivo `nbd0` quando terminar de usar:

```shell
umount /mnt/vm_mount_point
qemu-nbd --disconnect /dev/nbd0
```