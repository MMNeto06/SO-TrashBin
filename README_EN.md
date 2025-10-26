# Linux Recycle Bin System

## Authors
Miguel dos Santos Neto (125200)
Diogo Coelho e Silva (125240) 

## Description

This project consists on the development of a custom recycling bin for Linux systems, implemented in Bash, for the Sistemas Operativos unit course.

This system allows the safe deletion of files, moving them to a recycling area with a metadata file which contains all relevant information about the recycled files. Aditionally, it includes a configuration file, which can be adjusted by the user, as well as a log file wich documents all operations performed.

The user has access to a plethora of features, which will be described with detail through out this document. 

## Installation

To install and configure the system correctly, it is necessary to follow the steps described below:
    1. Download all files from the project and place the in the directory of your choice
    2. Open your terminal and make sure that your current/working directory is the same as the directory chosen in the step above
    3. To confirm that the main script is executable, give it execution permissions with the following command:
        chmod +x recycle_bin.sh
    4. The first command to be executed by the script should be *./recycle_bin.sh config*, to configure the recycle bin to your liking. It should be noted that it is not mandatory that this the first command you execute, however some of the functions will result in error in case you don't do it. Aditionally, this first command will create the recycling directory, so that you may start using it

## Usage
[How to use with examples]
After installing, the system can be run with the main script:
	./recycle_bin.sh [OPTION] [ARGUMENTS]
	
These are the available options: 
    - delete \<file\>: Moves the file to the recycle bin, instead of permanently deleting it. It should be noted that it is possible to pass multiple files as the argument, and directories will be accepted instead of files
	- list [--detailed]: Lists all files currently in the recycle bin. The --detailed flag shows more information on the listing
	- restore <file_name or file_id>: Restores the file/directory to it's original location.
	- search <search_pattern>: Searchs for recycled items that match the given pattern.
	- empty: [--force] [file_name or file_id]: Permanently eliminates all recycled files after confirmation. 
	The --force flag will skip confirmation. Optionally it is possible to delete a specific file/directory.
	- help: Displays a help message with all available commands.
	- autoclean: Automatically permanently eliminates the oldest items in the bin.
	The 'oldness' of a file is specifies in the configuration file.
	- stats: Shows statistics about the recycle bin
	- config: Opens the configuration file so that it may be edited.
	- quota: Checks the disk usage of the bin and compares it to the maximum allowed. If it exceeds the maximum, the user can perform a cleanup.
    - preview <file_id>: Shows the first ten lines of content of the corresponding file to the provided id, if the given file is a text file. If it's a binary file, it shows some information about it.
	- secure: Allows the enabling and setting of a password as confirmation for more sensitive commands, like empty and autoclean.
	
Use examples:
	./recycle_bin.sh delete testFile: Sends the file testFile to the recycle bin
	./recycle_bin.sh delete testFile1 testFile2 testFile3: Sends the files testFile1, testFile2 and testFile3 to the recycle bin. 
	./recycle_bin.sh list: Lists the content of the bin.
	./recycle_bin.sh list --detailed: Lists the content of the bin with more detail.
	./recycle_bin.sh restore testFile: Restores the file testFile, which had been previously recycled. 
	./recycle_bin.sh restore file_id: Restores the file whose id matches file_id. It should be noted that for all examples that include it, file_id is merely to show the example; when executing the program a real id should be used.
	./recycle_bin.sh search *.txt: Lists information about all the files with the .txt extension
	./recycle_bin.sh empty: Empties the recycle bin after user confirmation.
	./recycle_bin.sh empty --force: Empties the recycle bin.
	./recycle_bin.sh empty file_id: Eliminates from the recycle bin the file with the specified id after user confirmation
	./recycle_bin.sh help: Prints help information about how to use the script.
	./recycle_bin.sh autoclean: Automatically eliminates old files from the recycle bin.
	./recycle_bin.sh stats: Shows statistics about the recycle bin.
	./recycle_bin.sh config: Opens the configuration file so that it may be edited.
	./recycle_bin.sh quota: Checks if the recycle bin has exceeded the defined quota, with the option to autoclean if so.
	./recycle_bin.sh preview file_id: Shows the firts 10 lines of the specified file or inforation about it. 
	./recycle_bin.sh secure: Checks the password status and asks the user if they want to change it.
	
## Features
### Mandatory features
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

