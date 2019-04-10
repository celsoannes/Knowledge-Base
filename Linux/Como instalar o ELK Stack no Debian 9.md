# Como instalar o ELK Stack no Debian 9

Neste tutorial, nos iremos mostrar a você como instalar ELK Stac no Debian 9. ELC stack é uma coleção de três produtos de código aberto, [Elasticsearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash) e [Kibana](https://www.elastic.co/products/kibana) e é uma solucção robusta para pesquisa, análise e visualização de dados.

* [Elasticsearch](https://www.elastic.co/products/elasticsearch) é uma distribuição, RESTful de pesquisa e analise NoSQL baseado na engine Lucene.
* [Logstash](https://www.elastic.co/products/logstash) é um processador de dados pipeline leve para gerenciar eventos e registros de uma ampla variedade de origens.
* [Kibana](https://www.elastic.co/products/kibana) é uma aplicação web para visualização de dados que funciona em cima do Elasticsearch.

Este tutorial ELK Stak deve funcionar em outros sistemas **Linux VPS** também mas foi testado e escrito para um **Debian 9 VPS**. Instalar ELK Stak no Debian 9 é fácil e direto ao ponto, apenas siga os passos abaixo e você deve ter ele instalado em menos de 10 minutos.

## 1. Requisitos

Para completar este tutorial, você precisará:

* Um Debian 9 VPS
* Um usuário com poderes de administrador ou ```root```

## 2. Atualize o sistema e installe os pacotes necessários

    apt-get update && apt-get -y upgrade
    apt-get install apt-transport-https software-properties-common wget

## 3. Instalar Java

Elasticsearch exige no mínimo o Java 8 instalado para rodar. Ele suporta ambos OpenJDK e Oracle Java. Neste guia, nos iremos instalar OpenJDK versão 8.

Para instalar o OpenJDK rode o seguinte comando:

    apt install openjdk-8-jdk

Para verificar se tudo esta instalado corretamente, rode:

    java -version

Você deve ver uma resposta semelhante a abaixo:

    openjdk version "1.8.0_212"
    OpenJDK Runtime Environment (build 1.8.0_212-8u212-b01-1~deb9u1-b01)
    OpenJDK 64-Bit Server VM (build 25.212-b01, mixed mode)

## 4. Instalar e configurar Elasticsearch no Debian 9

Nos iremos instalar o Elasticsearch usando o gerenciamento de pacotes ```apt``` a partir do repositório oficial do Elastic. Primeiro habilite o repositório e atualize a lista de pacotes cache com o seguinte comando:

    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
    apt-get update

e instale o Elasticsearch com ```apt``` usando o seguinte comando:

    apt-get install elasticsearch

Uma vez que a instalação estiver completa, abra o arquivo ```elasticsearch.yml``` e restrinja o acesso remoto para a instância do Elasticsearch:

```/etc/elasticsearch/elasticsearch.yml```

    # ---------------------------------- Network -----------------------------------
    #
    # Set the bind address to a specific IP (IPv4 or IPv6):
    #
    #network.host: 192.168.0.1
    network.host: localhost

Reinicie o serviço dp Elasticsearch e configure ele para iniciar automaticamente durante o boot:

    systemctl restart elasticsearch
    systemctl enable elasticsearch

Para verificar o status do servidor elasticsearch você pode usar o seguinte comando:

    curl -X GET http://localhost:9200

A saída deverá ser parecida com a abaixo:

    {
      "name" : "KyjGFNJ",
      "cluster_name" : "elasticsearch",
      "cluster_uuid" : "850W6VaNTEeNOOogeZxhXw",
      "version" : {
        "number" : "6.7.1",
        "build_flavor" : "default",
        "build_type" : "deb",
        "build_hash" : "2f32220",
        "build_date" : "2019-04-02T15:59:27.961366Z",
        "build_snapshot" : false,
        "lucene_version" : "7.7.0",
        "minimum_wire_compatibility_version" : "5.6.0",
        "minimum_index_compatibility_version" : "5.0.0"
      },
      "tagline" : "You Know, for Search"
    }

## 5. Instalar e configurar o Kibana no Debian 9

Igual ao Elasticsearch, nos iremos instalar a ultima versão do Kibana usando o gerenciador de pacotes ```apt``` a partir do repositório oficial do Elastic:

    apt-get install kibana

Uma vez que a instalação tiver completado, abra o arquivo ```kibana.yml``` e restrinja o acesso remoto para a instância do Kibana:

```/etc/kibana/kibana.yml```

    # Specifies the address to which the Kibana server will bind. IP addresses and host names are both vali$
    # The default is 'localhost', which usually means remote machines will not be able to connect.
    # To allow connections from remote users, set this parameter to a non-loopback address.
    server.host: "localhost"

Inicie o servido do Kibana e configure para iniciar automaticamente durante o boot:

    systemctl restart kibana
    systemctl enable kibana

Kibana irá rodar no localhost na porta 5601

## 6. Instalar e configurar o Nginx como proxy reverso

Nos iremo usar o Nginx como proxy reverso para acessar Kibana a partir de um endereço IP público. Para instalar o Nginx rode:

    apt-get install nginx

Crie um arquivo de autenticação básica com o comando ```openssl```:

**Nota**: Substitua ```YourStrongPassword``` por uma senha forte de sua preferencia: 

    echo "admin:$(openssl passwd -apr1 YourStrongPassword)" | tee -a /etc/nginx/htpasswd.kibana

Exclua o host virtual padrão do nginx:

    rm -f /etc/nginx/sites-enabled/default

e crie um arquivo de configuração de host virtual para a instância do Kibana:

    touch /etc/nginx/sites-available/kibana

Crie um certificado ssl auto-assinado com o seguinte comando:

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

A saída completa irá se parecer com a seguinte:

    Country Name (2 letter code) [AU]:BR
    State or Province Name (full name) [Some-State]:Rio Grande do Sul
    Locality Name (eg, city) []:Passo Fundo
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:FinTI Tecnologia
    Organizational Unit Name (eg, section) []:Telecomunicações
    Common Name (e.g. server FQDN or YOUR name) []:elk.finti.com.br
    Email Address []:suporte@finti.com.br





Adicione o seguinte configuração ao arquivo ```kibana``` arrecém criado:

    server {
        listen 80 default_server;
        server_name _;
        return 301 https://172.16.1.120;
    }
    
    server {
        listen 443 default_server ssl http2;
    
        server_name 172.16.1.120;
    
        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
        ssl_session_cache shared:SSL:10m;
    
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/htpasswd.kibana;
    
        location / {
            proxy_pass http://localhost:5601;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }


Ative o bloco do servidor criando um link simbólico:

    ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana

Teste a configuração do Nginx:

    nginx -t

A saída do comando será parecida com o seguinte:

    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

Reinicie o serviço do Nginx e configure para iniciar automaticamente no boot:

    systemctl restart nginx
    systemctl enable nginx

## 7. Instalar Logstash no Debian 9

O último passo é instalar o Logstash usando o gerenciador de pacotes ```apt``` a partir do repositório oficial do Elastic.

    apt-get install logstash

Uma vez instalado os pacotes do Logstash inicie o serviço do Logstash e configure para iniciar automaticamente durante o boot:

    systemctl restart logstash
    systemctl enable logstash

A configuração do Logstash depende das suas preferencias pessoais e dos plugins que você irá usar. Você pode encontrar mais informações sobre como configurar Logstash [aqui](https://www.elastic.co/guide/en/logstash/current/configuration.html).

## 8. Acessando Kibana

Você pode acessar a interface Kibana abrindo o seu navegador e digitando:  ```https://SeuEndereçoIP```.




Fontes: [RoseHosting](https://www.rosehosting.com/blog/how-to-install-the-elk-stack-on-debian-9/), [DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04)