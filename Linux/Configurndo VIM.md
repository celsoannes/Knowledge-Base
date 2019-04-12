# Configurando VIM

Edite o arquivo ```/etc/vim/vimrc```, descomentando as seguintes linhas:

Descomentando a próxima linha ativa o realce de sintaxe por padrão.

    syntax on

Se estiver usando um fundo escuro na área de edição e ```syntax on``` ative esta opção também.

    set background=dark

Descomente as linhas a seguir para que o VIM pule para a ultima posição quando o arquivo for reaberto. 

    if has("autocmd")
      au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    endif

Faz buscas ignorando maiúscolas e minúscolas.

    set ignorecase


**Nota:** Para desabilitar o mouse nas versões mais recentes do Debian basta criar o ```~/.vimrc``` caso não exista:

    [ -f ~/.vimrc ] && touch ~/.vimrc
