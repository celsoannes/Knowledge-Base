# Criando sites estáticos com Jekyll

Criando um novo projeto

```bash
jekyll new minimal-blog
```

entre na pasta

```bash
cd minimal-blog
```

verifique o caminho do tema
```bash
bundle show minima
```
terá uma saida parecida com a seguinte:

```bash
/usr/local/rvm/gems/ruby-2.6.3/gems/minima-2.5.0
```

copie o para tema para o seu diretório 
```bash
cp -a /usr/local/rvm/gems/ruby-2.6.3/gems/minima-2.5.0/* 
```

Neste momento para não ter problemas de compatibilidade rode o comando abaixo:

```bash
bundle exec jekyll build 
```

Para ver o site, rode o seguinte comando:

```bash
bundle exec jekyll s 
```

Após rodar este comando será informado o endereço para acesso:

```bash
Server address: http://127.0.0.1:4000/
```

1. Entendendo o Front Matter e o Liquid Templates

    #### Variaveis

    Para definir uma variavel basta escrever entre os `---` do inicio da pagina a variavel da seguinte maneira:
    
        ---
        layout: default
        hello_word: "Hello Word com Liquid!"
        ---

    #### Explicando Escopo e chamando uma variável:
    
    O Jakell só entende três escopos:
    * `page` - variáveis definida dentro da página 
    * `post` - variáveis escritas dentro da pasta `_post`
    * `site` - todas as variáveis definidas dentro do arquivo `_config.yml`
    
    Para chamar a várivale dentro da página basta escrever o seguinte:
    
        {{ page.hello_world }}
    
        