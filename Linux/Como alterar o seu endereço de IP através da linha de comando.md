# Como alterar o seu endereço de IP através da linha de comando

É facil alterar o seu endereço de IP usando uma interface gráfica, mas você sabia que o Linux permite que você altere o endereço de rede da sua placa de rede usando um comando simples a partir do terminal?

Este truque deve funcionar em todas as distribuições baseadas no Debian, incluindo Ubuntu. Para iniciar, digite:  ```ifconfig``` no terminal, e então pressione Enter. Este comando lista todas as interfaces de rede do sistema, então anote o nome da interface para qual você deseja alterar o endereço de IP.

    eth0      Link encap:Ethernet  HWaddr 00:0c:29:ed:8d:51
              inet addr:192.168.152.129  Bcast:192.168.152.255  Mask:255.255.255.0
              inet6 addr: fe80::20c:29ff:feed:8d51/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:225 errors:0 dropped:0 overruns:0 frame:0
              TX packets:159 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:143275 (139.9 KiB)  TX bytes:19929 (19.4 KiB)
    
    lo        Link encap:Local Loopback
              inet addr:127.0.0.1  Mask:255.0.0.0
              inet6 addr: ::1/128 Scope:Host
              UP LOOPBACK RUNNING  MTU:65536  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Para alterar as configurações, você também usa o comando ```ifconfig```, desta vez com um parametros adicionais. O próximo comando muda a interface de rede chamada ```eth0``` para usar endereço ```IP 102.168.0.1```, e designa a máscara de sub-rede ```255.255.255.0```.

    ifconfig eth0 192.168.0.1 netmask 255.255.255.0

Em sistemas mais novos pode-se usar o seguinte método:

    ip addr add 192.168.0.1/24 dev ens32

Você poderia, certamente, substituir em qualquer valor que você desejar. Se você rodar ```ifconfig``` novamente você verá que a sua interface terá pego as configurações que você definiu para ela.

    eth0      Link encap:Ethernet  HWaddr 00:0c:29:ed:8d:51
              inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
              inet6 addr: fe80::20c:29ff:feed:8d51/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:257 errors:0 dropped:0 overruns:0 frame:0
              TX packets:188 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:147585 (144.1 KiB)  TX bytes:25257 (24.5 KiB)
    
    lo        Link encap:Local Loopback
              inet addr:127.0.0.1  Mask:255.0.0.0
              inet6 addr: ::1/128 Scope:Host
              UP LOOPBACK RUNNING  MTU:65536  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Se você também precisar alterar o Gateway Padrão usado pela interface de rede, você usar o comando ```route```. O comando seguinte, por exemplo, define o gateway padrão para a interface ```eth0``` para ```192.168.0.253```:

    route add default gw 192.168.0.253 eth0
    
Em sistemas mais novos pode-se usar o seguinte método:

    ip route add 192.168.0.0/24 dev ens32
    ip route add default via 192.168.0.1


Para ver as suas novas configurações, você precisará mostrar a tabela de rotas. Digite o seguinte comando no terminal e pressione Enter:

    route -n

    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    0.0.0.0         192.168.0.253   0.0.0.0         UG    0      0        0 eth0
    192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0

Fonte: [How-To Geek](https://www.howtogeek.com/118337/stupid-geek-tricks-change-your-ip-address-from-the-command-line-in-linux/)


