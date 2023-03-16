# Como configurar interface VLAN no Debian 10 e 11

## Instalando pacores necessários

Instalar o pacote `vlan` irá providenciar o comando `vconfig` necessário para `ifup` e `ifdown` quando utilizado VLANs.

````shell
apt update
apt install vlan 
````

## Tabela de roteamento

Adicione as linhas abaixo para permitir multiplas VLANs para criar tabelas de roteamento

````shell
echo "500 firsttable" | tee -a /etc/iproute2/rt_tables
````


## Carregando modulo

Carregue o módulo do kernel `8021q`.

````shell
modprobe 8021q
````

Confirme o carregamento do módulo:

````shell
lsmod | grep 8021q
````
````shell
8021q                  32768  0
garp                   16384  1 8021q
mrp                    20480  1 8021q
````

## Configurando VLAN:

Em minha configuração a interface a ser configurada é a `eno1`. Os detalhes da configurações estão abaixo:

````shell
Interface: eno1
VLAN ID: 503
IP Address: 172.20.20.10 
Gateway: 172.20.20.1
DNS: 172.20.20.1
````

Abra o arquivo de configuração padrão de interfaces do seu servidor Debian:

````shell
vi /etc/network/interfaces
````

Cole e modifique o conteudo das configurações abaixo:

````shell
# Source custom network configuration files
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The first VLAN interface
auto eno1.503
iface eno1.503 inet static
    address 172.20.20.10
    netmask 255.255.255.240
    gateway 172.20.20.1
    dns-nameservers 8.8.8.8 8.8.4.4
````

O nome da interface VLAN deve seguir a convenção de nomes suportada pela `vconfig`. Este formato `interfacex.y`, onde `interfacex` é o nome da interface física e `y` é o número da VLAN.

Finalmente, suba a interface usando `ifup`:

````shell
sudo ifup eno1.503
````

Talvez você precise reiniciar para confirmar que as configurações foram carregadas na inicialização.

````shell
reboot
````

Uma ver que tiver inicializado você pode inspecionar a interface VLAN usando o comando:

````shell
$ ifconfig eno1.503
````

Exemplo da saida:

````shell
eno1.503  Link encap:Ethernet  HWaddr e0:db:55:fe:5b:04
          inet addr:72.20.20.10  Bcast:72.20.20.15  Mask:255.255.255.240
          UP BROADCAST MULTICAST  MTU:1500 Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
````

Vamos supor que você queira adicionar outra interface VLAN a configuração continua a mesma:

````shell
# The second VLAN interface
auto eno1.504
iface eno1.504 inet static
    address 172.21.10.0
    netmask 255.255.255.0
````

Se o host é hypervisor considere adicionar as as configurações `sysctl`:

````shell
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.arp_filter=0" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=2" | tee -a /etc/sysctl.conf
````

Carregue as configurações:

````shell
sysctl -p
net.ipv4.ip_forward = 1
net.ipv4.conf.all.arp_filter = 0
net.ipv4.conf.all.rp_filter = 2
````

Isto é tudo que precisa para configurar interface VLAN.

Fonte: [Debian](https://wiki.debian.org/NetworkConfiguration#Howto_use_vlan_.28dot1q.2C_802.1q.2C_trunk.29_.28Etch.2C_Lenny.29) ,[TechView](https://techviewleo.com/how-to-configure-vlan-interface-on-debian/)