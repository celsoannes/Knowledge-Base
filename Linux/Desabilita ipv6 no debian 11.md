# Como Desabilitar o IPv6 no Debian 11

Para desabilitar o IPv6 no Debian 11, siga os passos abaixo:

## 1. Editar o arquivo de configuração do GRUB

Abra o arquivo de configuração do GRUB com um editor de texto, como o `nano`:

```sh
sudo nano /etc/default/grub
```

## 2. Modificar as opções do GRUB

Encontre a linha que começa com `GRUB_CMDLINE_LINUX` e adicione `ipv6.disable=1` ao final da linha, dentro das aspas. Deve ficar algo assim:

```sh
GRUB_CMDLINE_LINUX="... ipv6.disable=1"
```

## 3. Atualizar a configuração do GRUB

Após salvar e fechar o arquivo, atualize a configuração do GRUB executando:

```sh
sudo update-grub
```

## 4. Reiniciar o sistema

Para aplicar as mudanças, reinicie o sistema:

```sh
sudo reboot
```

## 5. Verificar se o IPv6 está desabilitado

Após o reinício, você pode verificar se o IPv6 foi desabilitado com o seguinte comando:

```sh
sudo sysctl -a | grep disable_ipv6
```

O resultado deve mostrar `net.ipv6.conf.all.disable_ipv6 = 1` e `net.ipv6.conf.default.disable_ipv6 = 1`.