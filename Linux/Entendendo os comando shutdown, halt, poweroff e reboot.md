# Entendendo os comando shutdown, halt, poweroff e reboot

Se você tem interesse em trabalhar na administração de servidores Linux, estes são alguns dos importantes comandos que você precisa compreender para administrar um servidor de forma eficaz e confiável.

Normalmente, quando você desliga o computador executa algum dos comandos abaixo:

## Shutdown
O **shutdown** agenda um tempo para o sistema ser desligado. Ele pode ser utilizado para travar, desligar ou reiniciar a máquina.

Você pode especificar uma sequência de tempo (que normalmente é ```now``` ou ```hh:mm``` por hora/minutos) como primeiro argumento. Além disso, você pode definir uma mensagem de tela a ser enviada para todos os usuários conectados antes que o sistema desligue.

**IMPORTANTE!** Se o argumento de tempo é usado, 5 minutos antes que o sistema desative, o arquivo ```/run/nologin``` é criado para garantir que o sistema não aceite mais logons.
Exemplos de comandos:

    shutdown
    shutdown now
    shutdown 13:20
    shutdown -p now      # faz um poweroff
    shutdown -H now      # executa o halt
    shutdown -r09:35     # reinicia a máquina no horário especificado, no caso, 09:35am
    
Para cancelar um desligamento agendado, simplesmente digite:

    shutdown -c

## Halt
O **halt** instrui o hardware a parar todas as funções de CPU, mais sem desligar. Você pode usá-lo para deixar o sistema em um estado onde você pode executar manutenção de baixo nível.

Note que em alguns casos, ele desliga completamente o sistema. Vamos ver alguns exemplos de comandos:

    halt                # para a máquina
    halt -p             # executa um poweroff
    halt --reboot       # reinicia a máquina
    
## Power off
O **poweroff** envia um sinal ACPI com instruções para desligar o sistema. Vejamos alguns exemplos:

    poweroff            # poweroff
    poweroff --halt     # executa um halt
    poweroff --reboot   # reinicia a máquina

## Reboot
O **reboot** envia instruções para reiniciar o sistema.

    reboot              # reinicia a máquina
    reboot --halt       # executa um halt
    reboot -p   	    # executa um poweroff
    
Isso é tudo! Como mencionado anteriormente, entender esses comandos irão permitir gerenciar um servidor Linux de forma eficaz e confiável em um ambiente multi-usuário.

Fonte: [SempreUPdate](https://sempreupdate.com.br/entendendo-os-comandos-de-shutdown-halt-poweroff-e-reboot-no-linux/)