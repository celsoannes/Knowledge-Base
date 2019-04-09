# Como capturar pacotes de rede

## Instalando tshark

Rode os comandos abaixo para instalar ```tshark```.

    apt-get update
    apt-get install tshark

## Capturando Pacotes
Execute o seguinte comando:

    tshark -i eth0 -b filesize:150000 -f udp -w /tmp/captura.cap

### OBS:
O ```dumpcap``` pode ser instalado em um modo que permite a membros do grupo de sistema ```wireshark``` capturar pacotes. Isto é recomendado em vez da alternativa de executar o Wireshark/Tshark diretamente como root, porque menos código será executado com privilégios elevados.