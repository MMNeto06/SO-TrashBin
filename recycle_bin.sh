#!/bin/bash
#################################################
# Linux Recycle Bin Simulation
# Author: Diogo Silva e Miguel Neto
# Date: [Date]
# Description: Shell-based recycle bin system
#################################################

# Global Configuration
RECYCLE_BIN_DIR="$HOME/.recycle_bin"
FILES_DIR="$RECYCLE_BIN_DIR/files"
METADATA_FILE="$RECYCLE_BIN_DIR/metadata.db"
CONFIG_FILE="$RECYCLE_BIN_DIR/config"
LOG_FILE="$RECYCLE_BIN_DIR/recyclebin.log"

# Color codes for output (optional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#################################################
# Function: initialize_recyclebin
# Description: Creates recycle bin directory structure
# Parameters: None
# Returns: 0 on success, 1 on failure
#################################################

initialize_recyclebin() {
	if [ ! -d "$RECYCLE_BIN_DIR" ]; then
		mkdir -p "$FILES_DIR"
		touch "$METADATA_FILE"
		touch "$CONFIG_FILE"
		echo "# Recycle Bin Metadata" > "$METADATA_FILE"
		echo "ID,ORIGINAL_NAME,ORIGINAL_PATH,DELETION_DATE,FILE_SIZE,FILE_TYPE,PERMISSIONS,OWNER" >> "$METADATA_FILE"
		echo "#!/bin/bash" >> "$CONFIG_FILE"
		echo "#This is the config file. It behaves like any other bash script" >> "$CONFIG_FILE"
		echo "#All variables here are imported to the main script when they're needed" >> "$CONFIG_FILE"
		echo "RETENTION_DAYS=-1" >> "$CONFIG_FILE"
		echo "MAX_SIZE_MB=-1" >> "$CONFIG_FILE"
		echo "Recycle bin initialized at $RECYCLE_BIN_DIR"
		return 0
	fi
	return 0
}

#################################################
# Function: generate_unique_id
# Description: Generates unique ID for deleted files
# Parameters: None
# Returns: Prints unique ID to stdout
#################################################
generate_unique_id() {
	local timestamp=$(date +%s)
	local random=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
	echo "${timestamp}_${random}"
}

#################################################
# Function: delete_file
# Description: Moves file/directory to recycle bin
# Parameters: $1 - path to file/directory
# Returns: 0 on success, 1 on failure
#################################################
delete_file() {
	local exit_code=0

	for file_path in "$@"
	do 
		echo "Delete function called with: $file_path" >> "$LOG_FILE"
		
		# Validate input
		if [ -z "$file_path" ]; then
		echo -e "${RED}Error: No file specified${NC}"
		echo -e "${RED}Error: No file specified${NC}" >> "$LOG_FILE"
		exit_code=1
		continue
		fi
		
		# Check if file exists
		if [ ! -e "$file_path" ]; then
		echo -e "${RED}Error: File '$file_path' does not exist${NC}"
		echo -e "${RED}Error: File '$file_path' does not exist${NC}" >> "$LOG_FILE"
		exit_code=1
		continue
		fi
			
		echo "Fetching metadata..." >> "$LOG_FILE"
		
		local original_file_name=$(basename "$file_path")
		local original_absolute_path=$(realpath "$file_path")
		local original_dir=$(dirname "$original_absolute_path")
		
		# Check if deletion directory is not recycle bin itself
		if [[ "$original_absolute_path" == "$RECYCLE_BIN_DIR" || "$original_dir" == "$RECYCLE_BIN_DIR" ]]
		then 
		   echo -e "${RED}Error: Cannot delete recycle bin itself.${NC}"
		   echo -e "${RED}Error: Cannot delete recycle bin itself.${NC}" >> "$LOG_FILE"
		   exit_code=1
		   continue
		fi 
		
		local deletion_timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
		local file_size=$(du -k "$original_absolute_path" | awk '{print $1}')
		local file_type=$(stat -c %F "$original_absolute_path")
		local original_permissions=$(stat -c %a "$original_absolute_path")
		local original_owner=$(stat -c %U:%G "$original_absolute_path")
		
		echo "Metadata successfully fetched!" >> "$LOG_FILE"
		
		echo "Checking disk space..." >> "$LOG_FILE"
		local available_disk_space=$(df -k "$FILES_DIR" | tail -1 | awk '{print $4}')
			 
		if (( file_size > available_disk_space ))
		then 
		   echo -e "${RED}Error: Not enough space available!${NC}"
		   echo -e "${RED}Error: Not enough space available!${NC}" >> "$LOG_FILE" 
		   exit_code=1
		   continue
		fi
		
		echo "There is enough disk space!" >> "$LOG_FILE"
		
		echo "Generating file id..." >> "$LOG_FILE"
		local file_unique_id=$(generate_unique_id)
		
		
		echo "Moving to recycle bin..."
		echo "Moving to recycle bin..." >> "$LOG_FILE"

		mv "$original_absolute_path" "$FILES_DIR/$file_unique_id" || 
		{
		   echo -e "${RED}Error: Permission denied!${NC}"
		   echo -e "${RED}Error: Permission denied!${NC}" >> "$LOG_FILE"
		   exit_code=1
		   continue
		}
		
		echo "File moved as: $file_unique_id"
		echo "File moved as: $file_unique_id" >> "$LOG_FILE"
		
		echo "Adding information to metadata file..." >> "$LOG_FILE"
		
		echo "$file_unique_id,$original_file_name,$original_absolute_path,$deletion_timestamp,$file_size,$file_type,$original_permissions,$original_owner" >> "$METADATA_FILE"
		
		echo "Information added successfully!" >> "$LOG_FILE"	
	done
	
	return $exit_code
}

#################################################
# Function: list_recycled
# Description: Lists all items in recycle bin
# Parameters: None
# Returns: 0 on success
#################################################
list_recycled() {
	#TODO: implementar detailed DONE
	#confirmar que file size é legível DONE		#CONFIRMAR QUE ESTÁ DONE
	#Tratar lista vazia de forma graciosa DONE
	#Mostrar total de itens e total de espaço ocupado DONE
	echo "=== Recycle Bin Contents ==="

	if [[ -z $( ls -A "$FILES_DIR" ) ]]; then
		echo "The Recycle Bin is Currently Empty"
		return 0
	fi

	local total_items=0
	local total_size=0

	if [ "$1" == "--detailed" ]; then #este imprime toda a informação
		while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
			if [ "$file_id" != "# Recycle Bin Metadata" ]; then
				if [ "$file_id" == "ID" ]; then
					printf "%-20s %-20s %-40s %-20s %-15s %-23s %-15s %-20s\n" "Id" "Original Name" "Original Path" "Delete Date" "File Size (KB)" "File Type" "Permissions" "Owner"
					printf "%-20s %-20s %-40s %-20s %-15s %-23s %-15s %-20s\n" "--------------------" "--------------------" "----------------------------------------" "--------------------" "---------------" "------------------" "--------------" "--------------------"
				else
					printf "%-20s %-20s %-40s %-20s %-15s %-23s %-15s %-20s\n" "$file_id" "$original_name" "$original_path" "$deletion_date" "$file_size" "$file_type" "$permissions" "$owner"
					total_items=$(($total_items + 1))
					total_size=$(($total_size + $file_size))
				fi
			fi
		done < "$METADATA_FILE"
	else
		#aqui imprime-se só: id (truncated), original name, deletion date, filesize (legível)
		#TODO: o que é o id (truncated)???
		while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
			if [ "$file_id" != "# Recycle Bin Metadata" ]; then
				if [ "$file_id" == "ID" ]; then
					printf "%-20s %-20s %-20s %-15s\n" "Id" "Original Name" "Delete Date" "File Size (KB)"
					printf "%-20s %-20s %-20s %-15s\n" "--------------------" "--------------------" "--------------------" "---------------"
				else
					printf "%-20s %-20s %-20s %-12s\n" "$file_id" "$original_name" "$deletion_date" "$file_size"
					total_items=$(($total_items + 1))
					total_size=$(($total_size + $file_size))
				fi
			fi
		done < "$METADATA_FILE"
	fi

	echo "Listed Recycle Bin Contents" >> $LOG_FILE
	echo "Number of Items in Recycle Bin: $total_items"
	echo "Total Size of Recycle Bin (KB) : $total_size"
	return 0
}
#################################################
# Function: restore_file
# Description: Restores file from recycle bin
# Parameters: $1 - unique ID or name of file to restore 
# Returns: 0 on success, 1 on failure
#################################################
restore_file() {
	local recover_file="$1" 
	local file_found=0
	local PS3="Select an option: "
	
	echo "Restore function called with: $recover_file" >> "$LOG_FILE"
	
	if [ -z "$recover_file" ]; then
		echo -e "${RED}Error: No file ID specified${NC}" >> "$LOG_FILE"
		return 1
	fi
	
	echo "Searching file..."
	echo "Searching file..." >> "$LOG_FILE"
	
	tail -n +2 $METADATA_FILE | while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner <&3
	   do 
	      if [[ "$recover_file" == "$file_id" || "$recover_file" == "$original_name" ]] 
	      then 
	         echo "File match found!"
	         echo "File match found!" >> "$LOG_FILE"
	         file_found=1
	         local restore_name="$original_name"
	         local original_dir=$(dirname "$original_path")
	         
	         
	         if [[ -d "$original_dir" ]]
	         then 
	            echo "Old directory found!" >> "$LOG_FILE"
	            if [[ -f "$original_dir/$original_name" ]]
	            then 
	               echo "This file already exists at original path!"
	               echo "This file already exists at original path!" >> "$LOG_FILE"
	               select option in "Overwrite" "Restore with modified name" "Cancel operation"
	               do 
	                  case $option in 
	                     "Overwrite")
	                         echo "Overwrting file..." >> "$LOG_FILE"
	                         ;; 
	                     "Restore with modified name")
	                         echo "Changing file name..." >> "$LOG_FILE"
	                         local restore_timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
	                         restore_name="${original_name}_${restore_timestamp}"
	                         ;;
	                     "Cancel operation")
	                         echo "Cancelling restore." >> "$LOG_FILE" 
	                         return 1
	                         ;;
	                  esac
	                  break
	               done
	            fi
	         else 
	            echo "Old directory does not exist anymore, creating parent directories..." >> "$LOG_FILE"
	            mkdir -p "$original_dir" || 
	            {
	               echo -e "${RED}Error: Permission denied!${NC}" >> "$LOG_FILE"
	               return 1
	            }
	            echo "Parent directories created: $original_dir" >> "$LOG_FILE"
	         fi
	         
	         echo "Checking available disk space..." >> "$LOG_FILE"
	         
	         local available_disk_space=$(df -k "$original_dir" | tail -1 | awk '{print $4}')

	         if [[ $file_size -gt $available_disk_space ]]
	         then 
	            echo -e "${RED}Error: Not enough space available!${NC}" >> "$LOG_FILE" 
	            return 1
	         fi
	         
	         echo "Moving file..." > "$LOG_FILE"
	         mv "$FILES_DIR/$file_id" "$original_dir/$restore_name" || 
	         {
	            echo -e "${RED}Error: Permission denied!${NC}" >> "$LOG_FILE"
	            return 1
	         }
	         
	         echo "Restoring permissions..." >> "$LOG_FILE"
	         chmod "$permissions" "$original_dir/$restore_name"
	         
	         echo "Removing data from metadata file..." >> "$LOG_FILE"
	         sed -i "/^$file_id,/d" "$METADATA_FILE"
	         
	         echo "Restore complete!"
	         echo "Restore complete!" >> "$LOG_FILE"
	      fi

	   done 3< "$METADATA_FILE"
	   
	   if [[ $file_found -eq 0 ]]
	   then 
	      echo "No match was found for file: $recover_file" >> "$LOG_FILE"
	      return 1	
	   fi
	         
	return 0
}

#################################################
# Function: empty_recyclebin
# Description: Permanently deletes all items
# Parameters: Up to 2
# Returns: 0 on success, exit 1 if cancelled
#################################################
empty_recyclebin() {
	#TODO: implementar empty para ficheiro específico DONE
	#implementar --force para saltar confirmação DONE
	#Mostar somário do que foi apagado DONE
	#logar operações de apago DONE

	local force=1

	if [[ "$1" == "--force" || "$2 == --force" ]]; then
		force=0
	fi

	if [ $force -eq 1 ]; then
		read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	fi

	if [[ ! -z "$1" && "$1" != "--force" ]]; then
		while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
			if [[ "$file_id" == "$1" || "$original_name" == "$1" ]]; then
				rm -r "$FILES_DIR/$file_id"
				echo "$file_id - $original_name permanently deleted"
				echo "$file_id - $original_name permanently deleted" >> $LOG_FILE
				sed -i "/^$file_id,/d" "$METADATA_FILE"
				echo "$file_id - $original_name removed from metadata"
				echo "$file_id - $original_name removed from metadata" >> $LOG_FILE
				return 0
			fi
		done < "$METADATA_FILE"
		echo -e "${RED}Error: file name or id not found${NC}"
		echo -e "${RED}Error: file name or id not found${NC}" >> $LOG_FILE
	else
		if [[ -z $( ls -A "$FILES_DIR" ) ]]; then
			echo "The Recycle Bin is Currently Empty"
			return 0
		fi

		echo "The following files will be deleted"
		list_recycled
		echo "The following files will be deleted" >> $LOG_FILE
		list_recycled >> $LOG_FILE
		
		rm -r $FILES_DIR
		mkdir -p "$FILES_DIR"
		echo "Deleted all files"
		echo "Deleted all files" >> $LOG_FILE

		sed -i '3,$d' $METADATA_FILE #apaga da 3ª À última linha
		echo "Metadata has been reset" >> $LOG_FILE
		echo "Metadata has been reset"

		echo "Recycle Bin emptied" >> $LOG_FILE
		echo "Recycle Bin emptied"
	fi
	return 0
}

#################################################
# Function: search_recycled
# Description: Searches for files in recycle bin
# Parameters: $1 - search pattern
# Returns: 0 on success
#################################################
search_recycled() {
	local pattern="$1"	
	local matches_found=0
	
	tail -n +2 $METADATA_FILE | while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner
	do
	   if echo "$original_name" | grep -iq "$pattern" || echo "$original_path" | grep -iq "$pattern" 
	   then 
	      matches_found=$(($matches_found+1))
	      if (( matches_found == 1 ))
	      then 
	        printf "%-20s %-20s %-40s %-20s %-12s %-23s %-15s %-20s\n" "Id" "Original Name" "Original Path" "Delete Date" "File Size" "File Type" "Permissions" "Owner"
		 	printf "%-20s %-20s %-40s %-20s %-12s %-23s %-15s %-20s\n" "--------------------" "--------------------" "----------------------------------------" "--------------------" "------------" "------------------" "--------------" "--------------------"
	      fi
	      
	      printf "%-20s %-20s %-40s %-20s %-12s %-23s %-15s %-20s\n" "$file_id" "$original_name" "$original_path" "$deletion_date" "$file_size" "$file_type" "$permissions" "$owner"
	   fi
        done < "$METADATA_FILE"
	
	if (( matches_found == 0 ))
	then 
	   echo "No file with $pattern pattern was found"
	   return 1
	fi
	
	return 0
}

#################################################
# Function: auto_cleanup
# Description: Auto clean old files from bin
# Parameters: None
# Returns: 0 on success
#################################################
auto_cleanup(){
	#TODO: Automatically delete items older than RETENTION_DAYS DONE
	#Read retention period from config file DONE
	#Provide cleanup summary DONE
	#Run manually or integrate into delete operation - CURRENTLY IS MANUAL

	#Get config file variables
	source "$CONFIG_FILE"

	if [ $RETENTION_DAYS -eq -1 ]; then
		echo "Retention days is not configured"
		gedit $CONFIG_FILE
		return 0
	fi

	while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
		if [[ "$file_id" != "ID" && "$file_id" != "# Recycle Bin Metadata" ]]; then
			#get deletion date as epoch
			local date_convert=$(echo "$deletion_date" | sed 's/_/ /; s/-/:/3; s/-/:/3')
			local del_epoch=$(date --date="$date_convert" +"%s")
			
			#get cutoff date as epoch (fonte é quick reference)
			local cutoff=$(date -d "$RETENTION_DAYS days ago" +%s)
			
			#compare epochs
			if [ $del_epoch -le $cutoff ]; then
				echo "auto_cleanup will delete $file_id - $original_name"
				echo "auto_cleanup will delete $file_id - $original_name" >> $LOG_FILE
				empty_recyclebin $file_id "--force"
			fi
		fi
	done < "$METADATA_FILE"

	return 0
}

#################################################
# Function: check_quota
# Description: Check if recycle bin exceeds MAX_SIZE_MB
# Parameters: None
# Returns: 0 on success
#################################################
check_quota(){
	echo "check_quota function called." >> "$LOG_FILE"
	
	source "$CONFIG_FILE"
	
	if [[ $MAX_SIZE_MB -eq -1 ]] 
	then 
		echo "Max_Size is not configured."
		gedit $CONFIG_FILE
		return 0
        fi 
        
        echo "MAX_SIZE_MB = $MAX_SIZE_MB" >> "$LOG_FILE"
        
        echo "Fetching recycle bin size..." >> "$LOG_FILE"
        local recycle_bin_size=$(du -sm "$RECYCLE_BIN_DIR" | awk '{print $1}')
        echo "Recycle bin size: $recycle_bin_size MB." >> "$LOG_FILE"
        
        if (( recycle_bin_size >= MAX_SIZE_MB )) 
        then 
        	echo -e "${RED}WARNING: Recycle bin is full!${NC}"
        	echo -e "${RED}WARNING: Recycle bin is full!${NC}" >> "$LOG_FILE"
        	echo "Asking user to clear space..." >> "$LOG_FILE"
        	echo "Do you want to clear some space in recycle bin? [Y/N]"
        	read choice
        	if [[ $choice == "Y" || $choice == "y" ]] 
        	then 
        		echo "Clearing space..."
        		echo "Clearing space..." >> "$LOG_FILE"
        		auto_cleanup
                else 
                	echo "User denied" >> "$LOG_FILE"
                	return 1
                fi 
        fi 
        
        return 0
}


#################################################
# Function: show_statistics
# Description: Shows statistics about the bin
# Parameters: None
# Returns: 0 on success
#################################################
show_statistics(){
	#TODO:Display total number of items in recycle bin  DONE
	# Show total storage used with quota percentage 	#SILVA FAZ QUOTA QUANDO PODERES
	# Break down by file type (files vs directories) DONE
	# Show oldest and newest items DONE
	# Display average file size DONE

	local total_items=0
	local total_size=0
	local n_files=0
	local n_dir=0
	local oldest_file=" "
	local oldest_time=0
	local newest_file=" "
	local newest_time=0

	while IFS=',' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
		if [[ "$file_id" != "ID" && "$file_id" != "# Recycle Bin Metadata" ]]; then
			total_items=$(($total_items + 1))
			total_size=$(($total_size + $file_size))
			
			if [ -d "$FILES_DIR/$file_id" ]; then
				n_dir=$(($n_dir + 1))
			else
				n_files=$(($n_files + 1))
			fi

			local date_convert=$(echo "$deletion_date" | sed 's/_/ /; s/-/:/3; s/-/:/3')
			local del_epoch=$(date --date="$date_convert" +"%s")

			if [[ $oldest_time -eq 0 || $del_epoch -lt $oldest_time ]]; then
				oldest_time=$del_epoch
				oldest_file="$file_id - $original_name - $deletion_date - $file_type"
			fi

			if [[ $newest_time -eq 0 || $del_epoch -gt $newest_time ]]; then
				newest_time=$del_epoch
				newest_file="$file_id - $original_name - $deletion_date - $file_type"
			fi
		fi
	done < "$METADATA_FILE"

	local avg_file_size=$(echo "scale=3; $total_size / $total_items" | bc -l) #source-aula03e07.sh

	echo "=== Statistics ==="
	echo "Total number of items: $total_items"
	echo "Total size of bin: $total_size" #TODO: ALTERAR QUANDO QUOTA FOR IMPLEMENTADA!!!!
	echo "Number of files in bin: $n_files"
	echo "Number of directories in bin: $n_dir"
	echo "Oldest item in bin: $oldest_file"
	echo "Newest item in bin: $newest_file"
	echo "Average size of item: $avg_file_size KB" #TODO: CONFIRMAR QUE É TAMANHO MÉDIO DE ITEM E NÃO FICHEIROS

	echo "=== Statistics ===" >> $LOG_FILE
	echo "Total number of items: $total_items" >> $LOG_FILE
	echo "Total size of bin: $total_size" >> $LOG_FILE #TODO: ALTERAR QUANDO QUOTA FOR IMPLEMENTADA!!!!
	echo "Number of files in bin: $n_files" >> $LOG_FILE
	echo "Number of directories in bin: $n_dir" >> $LOG_FILE
	echo "Oldest item in bin: $oldest_file" >> $LOG_FILE
	echo "Newest item in bin: $newest_file" >> $LOG_FILE
	echo "Average size of item: $avg_file_size KB" >> $LOG_FILE #TODO: CONFIRMAR QUE É TAMANHO MÉDIO DE ITEM E NÃO FICHEIROS
	return 0

}

########################################################################################
# Function: file_preview
# Description: Show first 10 lines for text files or file information for binary files
# Parameters: $1 - unique ID of file to preview
# Returns: 0 on success
########################################################################################
file_preview(){
	local file_id="$1"
	
	# Validate input
	if [ -z "$file_id" ]; then
	echo -e "${RED}Error: No file id specified${NC}"
	echo -e "${RED}Error: No file id specified${NC}" >> "$LOG_FILE"
	return 1
	fi
		
	echo "file_preview function called with: $file_id" >> "$LOG_FILE"
	
	local file_path="$FILES_DIR/$file_id"
	
	# Check if file exists
	if [ ! -e "$file_path" ]; then
	echo -e "${RED}Error: File '$file_path' does not exist${NC}"
	echo -e "${RED}Error: File '$file_path' does not exist${NC}" >> "$LOG_FILE"
	return 1
	fi
	
	if file "$file_path" | grep -q text
	then 
		echo "$file_id is a text file."
		echo "$file_id is a text file." >> "$LOG_FILE"
		echo "Showing first ten lines... " >> "$LOG_FILE"
		
		echo "First ten lines: "
		head -n 10 "$file_path"
	else 
		echo "$file_id is a binary file."
		echo "$file_id is a binary file." >> "$LOG_FILE"
		echo "Displaying file information..." >> "$LOG_FILE"
		
		echo "File information: "
		file "$file_path"
	fi
	
	return 0
}

#################################################
# Function: display_help
# Description: Shows usage information
# Parameters: None
# Returns: 0
#################################################
display_help() {
	cat << EOF
Linux Recycle Bin - Usage Guide

SYNOPSIS:
	$0 [OPTION] [ARGUMENTS]

OPTIONS:
	delete <file> Move file/directory to recycle bin
	list List all items in recycle bin
	restore <id> Restore file by ID
	search <pattern> Search for files by name
	empty Empty recycle bin permanently
	help Display this help message

EXAMPLES:
	$0 delete myfile.txt
	$0 list
	$0 restore 1696234567_abc123
	$0 search "*.pdf"
	$0 empty

EOF
	return 0
}

#################################################
# Function: main
# Description: Main program logic
# Parameters: Command line arguments
# Returns: Exit code
#################################################
main() {
	# Initialize recycle bin
	initialize_recyclebin
	
	# Parse command line arguments
	case "$1" in
		delete)
			shift
			delete_file "$@"
			;;
		list)
			list_recycled "$2"
			;;
		restore)
			restore_file "$2"
			;;
		search)
			search_recycled "$2"
			;;
		empty)
			empty_recyclebin "$2"
			;;
		help|--help|-h)
			display_help
			;;
		autoclean)
			auto_cleanup
			;;
		stats)
			show_statistics
			;;
		config)
			gedit "$CONFIG_FILE"
			;;
		preview) 
			file_preview "$2"
			;;
		*)
			echo "Invalid option. Use 'help' for usage information."
			exit 1
			;;
	esac
}

# Execute main function with all arguments
main "$@"
