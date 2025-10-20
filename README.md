# Linux Recycle Bin System

## Authors
Miguel dos Santos Neto (125200)
Diogo Coelho e Silva (125240) 

## Description

Este projeto consiste no desenvolvimento de uma reciclagem personalizada para sistemas Linux, implementada em Bash, no âmbito da unidade curricular de Sistemas Operativos.

O sistema permite a eliminação segura de ficheiros, armazenando-os numa área de reciclagem acompanhada de um ficheiro de metadados que contém todas as informações relevantes acerca dos ficheiros reciclados. Adicionalmente, inclui um ficheiro de configuração, que pode ser ajustado pelo utilizador, bem como um ficheiro de registo que documenta as operações realizadas.

O utilizador dispõem de diversas funcionalidades, as quais serão descritas detalhadamente ao longo deste documento.

## Installation

De modo a instalar e configurar o sistema corretamente, é necessário seguir os passos descritos abaixo:
	1. Descarregar todos os ficheiros do projeto e colocá-los num diretório à sua escolha.
	2. Abra o seu terminal e certifique-se que se localiza no diretório escolhido anteriormente.
	3. De modo a confirmar que o programa principal é executável, forneça permissões de execução com o seguinte comando: 
		chmod +x recycle_bin.sh
	4. O primeiro comando relativo ao programa a ser executado deve ser *./recycle_bin.sh config*, para poder configurar a sua reciclagem ao seu gosto. É evidente que não é obrigatório que este seja o primeiro comando que executa, contudo, algumas funcionalidades podem resultar em erros caso não o faça. Adicionalmente, este comando irá criar o diretório da reciclagem, para que possa começar a utilizá-la.

## Usage
[How to use with examples]
Após a instalação, o sistema pode ser executado através do programa principal: 
	./recycle_bin.sh [OPTION] [ARGUMENTS]
	
Estas são as opções disponíveis: 
	- delete <file>: Move o ficheiro para a reciclagem, em vez de o eliminar permanentemente. Note-se que pode passar vários ficheiros como argumento, ou até mesmo diretórios.
	- list: TODO
	- restore <file_name or file_id>: Restora o ficheiro para a sua localização original. 
	- search <search_pattern>: Procura ficheiros reciclados que correspondem ao padrão indicado.
	- empty: TODO
	- help: Mostra uma mensagem de ajuda com todos os comandos disponíveis.
	- autoclean: TODO
	- stats: TODO
	- config: Abre o ficheiro de configurações para que possa alterar o seu conteúdo.
	- quota: Verifica o espaço ocupado pela reciclagem e compara com o máximo permitido. Caso seja exceda o máximo, o utilizador tem a possibilidade de realizar uma limpeza.
	- preview <file_id>: Mostras as primeiras dez linhas do conteúdo do ficheiro cujo id corresponde a file_id, no caso deste se tratar de um ficheiro de texto. Se for um ficheiro binário, mostra algumas informações. 
	
Exemplos de utilização:
	./recycle_bin.sh delete testFile: Envia o ficheiro testFile para a reciclagem. 
	./recycle_bin.sh delete testFile1 testFile2 testFile3: Envia os ficheiros testFile1, testFile2 e testFile3 para a reciclagem. 
	list aqui
	./recycle_bin.sh restore testFile: Restora o ficheiro testFile, que foi previamente reciclado. 
	./recycle_bin.sh restore file_id: Restora o ficheiro reciclado cujo id corresponde a file_id. Note-se que file_id é apenas para efeitos de exemplo, ao executar o programa deve utilizar um id verdadeiro.
	./recycle_bin.sh search *.txt: Lista informações de todos os ficheiros que tenham a extensão .txt.
	empty aqui
	./recycle_bin.sh help
	autoclean aqui
	stats aqui
	./recycle_bin.sh config
	./recycle_bin.sh quota
	
## Features
### Funcionalidades Obrigatórias
Foram implementadas as seguintes funcionalidades obrigatórias:
	- initialize_recyclebin();
	- delete_file();
	- list_recycled();
	- restore_file();
	- search_recycled();
	- empty_recyclebin();
	- display_help();

### Funcionalidades Opcionais 
Foram implementadas as seguintes funcionalidades opcionais:
	- show_statistics();
	- auto_cleanup();
	- check_quota();
	- preview_file();
	
## Configuration

De modo a configurar a sua reciclagem, deve utilizar o seguinte comando: ./recycle_bin.sh config.

## Examples
[Detailed usage examples with screenshots]
## Known Issues

Não são conhecidas quaisquer limitações ou bugs no nosso sistema.

## References

Para a realização deste projeto, foram efetuadas pesquisas e consultas a diversas fontes de informação, com o objetivo de adquirir o conhecimento necessário sobre comandos e técnicas fundamentais ao seu desenvolvimento.
As referências consultadas encontram-se listadas abaixo, devidamente associadas às etapas de desenvolvimento em que foram aplicadas (isto é, as funções implementadas).

delete_file(): 

list_recycled():

restore_file():

search_recycled():

empty_recyclebin():

show_statistics():

auto_cleanup():

check_quota():

preview_file():

### Utilização de LLMs e outras notas
Importa referir que foram utilizados LLMs como ferramenta de apoio à compreensão de conceitos, ao estudo de funcionalidades de comandos identificadas durante a pesquisa e à resolução de erros (debug) ocorridos durante o desenvolvimento.

Parte do código apresentado foi também elaborado com base no estudo dos materiais de apoio disponibilizados.

