# Linux Recycle Bin System

## Authors
Miguel dos Santos Neto (125200)
Diogo Coelho e Silva (125240) 

## Description

Este projeto consiste no desenvolvimento de uma reciclagem personalizada para sistemas Linux, implementada em Bash, no âmbito da unidade curricular de Sistemas Operativos.

O sistema permite a eliminação segura de ficheiros, armazenando-os numa área de reciclagem acompanhada de um ficheiro de metadados que contém todas as informações relevantes acerca dos ficheiros reciclados. Adicionalmente, inclui um ficheiro de configuração, que pode ser ajustado pelo utilizador, bem como um ficheiro de registo que documenta as operações realizadas.

O utilizador dispõem de diversas funcionalidades, as quais serão descritas detalhadamente ao longo deste documento.

## Installation
[How to install/setup]
De modo a instalar e configurar o sistema corretamente, é necessário seguir os passos descritos abaixo:
	1. Descarregar todos os ficheiros do projeto e colocá-los num diretório à sua escolha.
	2. Abra o seu terminal e certifique-se que se localiza no diretório escolhido anteriormente.
	3. De modo a confirmar que o programa principal é executável, forneça permissões de execução com o seguinte comando: 
		chmod +x recycle_bin.sh
	4. O primeiro comando relativo ao programa a ser executado deve ser *./recycle_bin.sh config*, para poder configurar a sua reciclagem ao seu gosto. É evidente que não é obrigatório que este seja o primeiro comando que executa, contudo, algumas funcionalidades podem resultar em erros caso não o faça. Adicionalmente, este comando irá criar o diretório da reciclagem, para que possa começar a utilizá-la.

## Usage
[How to use with examples]
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
[How to configure settings]
De modo a configurar a sua reciclagem, deve utilizar o seguinte comando: ./recycle_bin.sh config.

## Examples
[Detailed usage examples with screenshots]
## Known Issues
[Any limitations or bugs]
Não são conhecidas quaisquer limitações ou bugs no nosso sistema.
## References
[Resources used]
Para a realização deste projeto, foram efetuadas pesquisas e consultas a diversas fontes de informação, com o objetivo de adquirir o conhecimento necessário sobre comandos e técnicas fundamentais ao seu desenvolvimento.
As referências consultadas encontram-se listadas abaixo, devidamente associadas às etapas de desenvolvimento em que foram aplicadas (isto é, as funções implementadas).

delete_file(): 

list_recycled():

restore_file():

search_recycled():

empty_recyclebin():

### Funcionalidades opcionais
show_statistics():

auto_cleanup():

check_quota():

preview_file():

### Utilização de LLMs e outras notas
Importa referir que foram utilizados LLMs como ferramenta de apoio à compreensão de conceitos, ao estudo de funcionalidades de comandos identificadas durante a pesquisa e à resolução de erros (debug) ocorridos durante o desenvolvimento.

Parte do código apresentado foi também elaborado com base no estudo dos materiais de apoio disponibilizados.

