# Configurando Teleport Community Edition

Caso não tenha instalado o Teleport ainda, assista o [vídeo](https://www.youtube.com/watch?v=BJWbSqiDLeU) ou siga os passos do [guia](https://goteleport.com/docs/).

## Adicionando usuários locais

Uma identidade de usuário no Teleport existe no escopo de um cluster. Um administrador do Teleport cria contas de usuário do Teleport e as mapeia para as funções que podem ser usadas.

| Teleport User | Allowed OS Logins | Description                                                                                                         |
|---------------|-------------------|---------------------------------------------------------------------------------------------------------------------|
| `joe`           | `joe`, `root`         | O usuário `joe` do Teleport pode fazer login nos _Nodes_ membros como usuário `joe` ou `root` no sistema operacional. |
| `bob`           | `bob`               | O usuário `bob` do Teleport pode fazer login nos _Nodes_ membros somente como usuário `bob` do sistema operacional. |
| `kim`           |                   | Se nenhum login do sistema operacional for especificado, o padrão será o mesmo nome do usuário do Teleport, `kim`.   |

Vamos adicionar um novo usuário ao Teleport usando a ferramenta `tctl`:

````shell
tctl users add joe --logins=joe,root --roles=access,editor
````

````shell
User "joe" has been created but requires a password. Share this URL with the user to complete user setup, link is valid for 1h:
https://<proxy_host>:443/web/invite/<token>

NOTE: Make sure <proxy_host>:443 points at a Teleport proxy which users can access.
````

O usuário conclui o registro visitando esse URL no navegador da Web, escolhendo uma senha e configurando a autenticação multifator. Se as credenciais estiverem corretas, o Teleport Auth Server gera e assina um novo certificado, e o cliente armazena essa chave e a utiliza nos logins subsequentes.

Por padrão, a chave expirará automaticamente após 12 horas, após as quais o usuário precisará fazer login novamente com suas credenciais. Esse TTL pode ser configurado com um valor diferente.

Depois de autenticada, a conta se tornará visível via `tctl`:

````shell
tctl users ls

User           Allowed Logins
----           --------------
admin          admin,root
kim            kim
joe            joe,root
````

## Edição de usuários
Os administradores podem editar entradas de usuários via `tctl`.

Por exemplo, para ver a lista completa de registros de usuários, um administrador pode executar:

````shell
tctl get users
````

Para editar o usuário `joe`:

Transfira a definição do usuário para um arquivo:
````shell
tctl get user/joe > joe.yaml
````

Edite o conteúdo do `joe.yaml`

Atualize o registro do usuário:
````shell
tctl create -f joe.yaml
````

## Exclusão de usuários
Os administradores podem excluir um usuário local por meio do tctl:


## Criando uma nova Função (Role)

Primeiro crie um arquivo para a função, por exemplo, `estagiario.yaml`, não queremos que ele tenha acesso a todas as máquinas certo? Copie o seguinte conteudo para o arquivo:

````yaml
kind: role
version: v7
metadata:
  name: estagiario
spec:
  allow:
    # Configura logins SSH para princípios de login
    logins: ['readonly']
    # Atribui usuários com esta função ao grupo Kubernetes integrado "view"
    kubernetes_groups: ["view"]
    # Permitir acesso a nós SSH, clusters Kubernetes, aplicativos ou bancos de dados
    # rotulados como "estagiario" ou "teste"
    node_labels:
      'env': ['estagiario','teste']
    kubernetes_labels:
      'env': 'estagiario'
    kubernetes_resources:
      - kind: "*"
        namespace: "*"
        name: "*"
        verbs: ["*"]
    app_labels:
      'type': ['monitoring']
  # As regras de negação sempre sobrescrevem as regras de permissão.
  deny:
    # negar acesso a qualquer Nó, banco de dados, aplicativo ou cluster Kubernetes rotulado
    # como prod para qualquer usuário.
    node_labels:
      'env': 'prod'
    kubernetes_labels:
      'env': 'prod'
    kubernetes_resources:
      - kind: "namespace"
        name: "prod"
    db_labels:
      'env': 'prod'
    app_labels:
      'env': 'prod'
````

Criar uma função usando o comando `tctl create -f`:

````shell
tctl create -f /tmp/estagiario.yaml
````

Obter uma lista de todas as funções no sistema:

````shell
tctl get roles --format text
````

Adicione ao usuario a nova função pela interface Web.

O usuário só energará as máquinas que possuirem a etiqueta `estagiario`, vamos adicionar a etiqueta `estagiario` a um host já cadastrado.

No host de destino, abra o arquivo `/etc/teleport.yaml` e encontre o atributo `labels` adicionado o a nova chave `env: estagiario`, ficando assim:

````shell
...
ssh_service:
  enabled: "yes"
  labels:
    env: estagiario
...
````

Reinicie o serviço do `teleport`

````shell
systemctl restart teleport
````

O usúario terá que sair e entrar na sessão novamente para ver os seus hosts.



Fontes: [Roles](https://goteleport.com/docs/access-controls/access-requests/oss-role-requests/), [Usuários](https://goteleport.com/docs/management/admin/users/), [Templates](https://goteleport.com/docs/access-controls/guides/role-templates/), [Labels](https://goteleport.com/docs/management/admin/labels/)