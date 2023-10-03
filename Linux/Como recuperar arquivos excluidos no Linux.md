# Como recuperar arquivos excluidos no linux

O TestDisk é uma poderosa ferramenta de recuperação de dados que pode ajudar a recuperar partições perdidas ou corrompidas em sistemas Debian Linux. Este tutorial fornecerá instruções passo a passo sobre como instalar e usar o TestDisk no Debian.


### Passo 1: Instalar o TestDisk

O TestDisk geralmente está disponível nos repositórios oficiais do Debian. Você pode instalá-lo usando o comando `apt-get`:

```bash
apt-get update
apt-get install testdisk
```


### Passo 2: Executar o TestDisk

Após a instalação ser concluída, você pode iniciar o TestDisk executando o seguinte comando no terminal:

```bash
testdisk
```
Escolha `[ Create ]` para criar um arquivo `testdisk.log`.

```bash
TestDisk 7.1, Data Recovery Utility, July 2019
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org


TestDisk is free data recovery software designed to help recover lost
partitions and/or make non-booting disks bootable again when these symptoms
are caused by faulty software, certain types of viruses or human error.
It can also be used to repair some filesystem errors.

Information gathered during TestDisk use can be recorded for later
review. If you choose to create the text file, testdisk.log , it
will contain TestDisk options, technical information and various
outputs; including any folder/file names TestDisk was used to find and
list onscreen.

Use arrow keys to select, then press Enter key:
>[ Create ] Create a new log file
 [ Append ] Append information to log file
 [ No Log ] Don't record anything
```

### Passo 3: Selecionar o Disco

Ao iniciar o TestDisk, você verá uma tela de boas-vindas. Use as teclas de seta para navegar e pressione `Enter` para selecionar a unidade na qual deseja realizar a recuperação de dados.

```bash
TestDisk 7.1, Data Recovery Utility, July 2019
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org

  TestDisk is free software, and
comes with ABSOLUTELY NO WARRANTY.

Select a media (use Arrow keys, then press Enter):
>Disk /dev/sda - 268 GB / 250 GiB - VMware Virtual disk
 Disk /dev/sr0 - 395 MB / 377 MiB (RO) - VMware Virtual IDE CDROM Drive
 Disk /dev/loop0 - 46 MB / 44 MiB (RO)
 Disk /dev/loop1 - 20 KB / 20 KiB (RO)
 Disk /dev/loop2 - 66 MB / 63 MiB (RO)
 Disk /dev/loop4 - 66 MB / 63 MiB (RO)
 Disk /dev/loop5 - 110 MB / 105 MiB (RO)
 Disk /dev/loop6 - 110 MB / 105 MiB (RO)


>[Proceed ]  [  Quit  ]

Note: Disk capacity must be correctly detected for a successful recovery.
If a disk listed above has an incorrect size, check HD jumper settings and BIOS
detection, and install the latest OS patches and disk drivers.
```

### Passo 4: Selecionar o Tipo de Tabela de Partições

O TestDisk suporta vários tipos de tabelas de partições. O TestDisk detecta automaticamente a sua partição, se você não tem certeza do tipo de tabela de partições que a unidade possui, pode selecionar a opção "Analyse" para que o TestDisk tente detectar automaticamente.

```bash
TestDisk 7.1, Data Recovery Utility, July 2019
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org


Disk /dev/sda - 268 GB / 250 GiB - VMware Virtual disk

Please select the partition table type, press Enter when done.
>[Intel  ] Intel/PC partition
 [EFI GPT] EFI GPT partition map (Mac i386, some x86_64...)
 [Humax  ] Humax partition table
 [Mac    ] Apple partition map (legacy)
 [None   ] Non partitioned media
 [Sun    ] Sun Solaris partition
 [XBox   ] XBox partition
 [Return ] Return to disk selection



Hint: Intel partition table type has been detected.
Note: Do NOT select 'None' for media with only a single partition. It's very
rare for a disk to be 'Non-partitioned'.
```

### Passo 5: Selecione a Opção de Recuperação

Após selecionar a tabela de partições, você será apresentado com várias opções de recuperação escolha: `Advanced`

````bash
TestDisk 7.1, Data Recovery Utility, July 2019
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org


Disk /dev/sda - 268 GB / 250 GiB - VMware Virtual disk
     CHS 32635 255 63 - sector size=512

 [ Analyse  ] Analyse current partition structure and search for lost partitions
>[ Advanced ] Filesystem Utils
 [ Geometry ] Change disk geometry
 [ Options  ] Modify options
 [ MBR Code ] Write TestDisk MBR code to first sector
 [ Delete   ] Delete all data in the partition table
 [ Quit     ] Return to disk selection





Note: Correct disk geometry is required for a successful recovery. 'Analyse'
process may give some warnings if it thinks the logical geometry is mismatched.
````

**Passo 6: Escolha de partições

No menu vertical escolha a partição `Linux` onde estão os seus arquivos e no menu inferior horizontal selecione `[ List ]`.

````bash
TestDisk 7.1, Data Recovery Utility, July 2019
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org

Disk /dev/sda - 268 GB / 250 GiB - CHS 32635 255 63

     Partition                  Start        End    Size in sectors
> 1 * Linux                    0  32 33 32510 221 31  522285056
  2 E extended             32510 253 62 32635  74 15    1996802
  5 L Linux Swap           32510 254  1 32635  74 15    1996800












 [  Type  ]  [Superblock] >[  List  ]  [Image Creation]  [  Quit  ]
                              List and copy files
````

Após a conclusão da busca, você verá uma lista de arquivos encontradas. Utilize as setas para cima e para baixo, ou as teclas PgUp e PgDn, a fim de percorrer a lista de arquivos e diretórios. Para acessar um diretório, pressione a seta para a direita ou a tecla Enter; para sair de um diretório, utilize a seta para a esquerda ou a tecla Esc.

```bash
TestDisk 7.1, Data Recovery Utility, July 2019
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org
 1 * Linux                    0  32 33 32510 221 31  522285056
Directory /
                                                   Previous
 drwxr-xr-x     0     0      4096 16-Aug-2023 15:44 home
 drwxr-xr-x     0     0      4096 10-Apr-2021 17:15 proc
 drwx------     0     0      4096 21-Sep-2023 16:12 root
 drwxr-xr-x     0     0      4096 16-Aug-2023 15:39 run
 drwxr-xr-x     0     0      4096 10-Apr-2021 17:15 sys
 drwxrwxrwt     0     0      4096 21-Sep-2023 17:02 tmp
 drwxr-xr-x     0     0      4096 16-Aug-2023 15:22 mnt
 drwxr-xr-x     0     0      4096 16-Aug-2023 15:22 srv
 drwxr-xr-x     0     0      4096 16-Aug-2023 15:22 opt
 drwxr-xr-x     0     0      4096 17-Aug-2023 14:16 snap.dpkg-new
 lrwxrwxrwx     0     0        30 16-Aug-2023 15:27 initrd.img.old
 lrwxrwxrwx     0     0        28 16-Aug-2023 15:27 vmlinuz
 lrwxrwxrwx     0     0        31 16-Aug-2023 15:27 initrd.img
>drwxr-xr-x     0     0      4096 17-Aug-2023 14:16 snap
                                                   Next
Use Right to change directory, h to hide deleted files
    q to quit, : to select the current file, a to select all files
    C to copy the selected files, c to copy the current file
```



Os arquivos grifados em vermelho são os arquivos que podem ser recuperados.

Para recuperar um arquivo, basta destacá-lo e pressionar 'c' (minúsculo).

O visualizador mudará e solicitará que você escolha um destino para o arquivo recuperado. Como criamos um diretório chamado "restored" e começamos o TestDisk a partir dele, a primeira entrada na lista (.) representa esse diretório. Para recuperar o arquivo excluído para esse diretório, pressione 'C' (maiúsculo).

Após fazer isso, você voltará à tela de seleção de arquivos. Se você quiser recuperar mais arquivos, basta repetir o processo. Destaque um arquivo excluído, pressione 'c' (minúsculo) para copiá-lo e, em seguida, pressione 'C' (maiúsculo) para recuperá-lo.


**Passo 7: Sair do TestDisk**

Depois de concluir o processo de recuperação, você pode sair do TestDisk selecionando a opção "Quit" (Sair) no menu principal.

Lembre-se de que o uso do TestDisk pode ser complicado e arriscado, dependendo da situação. Se você não tem experiência em recuperação de dados, é aconselhável procurar ajuda de um profissional para evitar a perda de dados irreversível. Certifique-se de fazer backups regulares para evitar a necessidade de recuperação de dados no futuro.

Fonte: [SEMPREUPDATE](https://sempreupdate.com.br/como-recuperar-arquivos-excluidos-no-linux-com-testdisk/)