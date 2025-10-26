#!/bin/bash

#######################################################
# Linux Recycle Bin Simulation
# Authors: Diogo Silva (125240) & Miguel Neto (125200)
# Date: [Date]
# Description: Shell-based recycle bin system
#######################################################

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
		touch "$LOG_FILE"
		echo "# Recycle Bin Metadata" > "$METADATA_FILE"
		echo "ID|ORIGINAL_NAME|ORIGINAL_PATH|DELETION_DATE|FILE_SIZE|FILE_TYPE|PERMISSIONS|OWNER" >> "$METADATA_FILE"
		echo "#!/bin/bash" >> "$CONFIG_FILE"
		echo "#This is the config file. It behaves like any other bash script" >> "$CONFIG_FILE"
		echo "#All variables here are imported to the main script when they're needed" >> "$CONFIG_FILE"
		echo "RETENTION_DAYS=-1" >> "$CONFIG_FILE"
		echo "MAX_SIZE_MB=-1" >> "$CONFIG_FILE"
		echo "PASSWD_ACTIVE=0" >> "$CONFIG_FILE"
		echo "PASSWD_VALUE=1234" >> "$CONFIG_FILE"
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

#########################################################################
# Function: log
# Description: Writes important information to log file and/or terminal
# Parameters: $1 - message type (info, error)
#			  $2 - where to write (terminal, file or both)
#			  $3 - information to write
# Returns: 0 on success, 1 on failure
#########################################################################
log(){
	local info_type="$1"
	local writing_place="$2"
	local message_to_write="$3"
	local echo_type="echo"

	if [[ "$info_type" == "error" ]]
	then
		echo_type="echo -e"
	fi

    case "$writing_place" in
        terminal)
            $echo_type "$message_to_write"
            ;;
        file)
            if [[ -z "$LOG_FILE" ]]; then
				echo -e "${RED}Error: LOG_FILE not defined.${NC}"
                return 1
            fi
            $echo_type "$message_to_write" >> "$LOG_FILE"
            ;;
        both)
            $echo_type "$message_to_write"
            if [[ -z "$LOG_FILE" ]]; then
                echo -e "${RED}Error: LOG_FILE not defined.${NC}"
                return 1
            fi
            $echo_type "$message_to_write" >> "$LOG_FILE"
            ;;
        *)
            echo -e "${RED}Error: Invalid writing place.${NC}"
            return 1
            ;;
    esac

	return 0
}

#################################################
# Function: delete_file
# Description: Moves file/directory to recycle bin
# Parameters: $1 - path to file/directory
# Returns: 0 on success, 1 on failure
#################################################
delete_file() {
	local exit_code=0
	local this_absolute_path=$(realpath "$0") # absolute path of this script

	if [[ "$#" -lt 1 ]]; then
		echo "Must indicate at least one file/directory for deletion"
		echo "Use: $0 delete <file1> <file2> ... <fileN>"
		exit_code=1
	fi

	source "$CONFIG_FILE"
	
	if [[ $MAX_SIZE_MB -eq -1 ]] 
	then 
		log info both "Max_Size is not configured."
		nano $CONFIG_FILE
		return 1
    fi 

	local max_size_kb=$((MAX_SIZE_MB * 1024))

	for file_path in "$@"
	do 
		log info file "Delete function called with: $file_path"
		
		# Validate input
		if [ -z "$file_path" ]; then
		log error both "${RED}Error: No file specified${NC}"
		exit_code=1
		continue
		fi
		
		# Check if file exists
		if [ ! -e "$file_path" ]; then
		log error both "${RED}Error: File '$file_path' does not exist${NC}"
		exit_code=1
		continue
		fi

		# Check file permissions
		if [ ! -r "$file_path" ] || [ ! -w "$file_path" ]; then
			log error both "${RED}Error: Permission denied!${NC}"
			return 1
		fi
		
		log info file "Fetching metadata..." 
		
		local original_file_name=$(basename "$file_path")
		local original_absolute_path=$(realpath "$file_path")
		local original_dir=$(dirname "$original_absolute_path")
		
		if [[ "$original_absolute_path" == "$this_absolute_path" ]] 
		then 
			log error both "${RED}Error: Cannot delete main script.${NC}"
			exit_code=1
			continue
		fi
		
		# Check if deletion directory is not recycle bin itself
		if [[ "$original_absolute_path" == "$RECYCLE_BIN_DIR" || "$original_dir" == "$RECYCLE_BIN_DIR" ]]
		then 
		   log error both "${RED}Error: Cannot delete recycle bin itself.${NC}"
		   exit_code=1
		   continue
		fi 
		
		local deletion_timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
		local file_size=$(du -k "$original_absolute_path" | awk '{print $1}')
		local file_type=$(stat -c %F "$original_absolute_path")
		local original_permissions=$(stat -c %a "$original_absolute_path")
		local original_owner=$(stat -c %U:%G "$original_absolute_path")
		
		log info file "Metadata successfully fetched!"
		
		log info file "Checking disk space..."
		local current_bin_size=$(du -sk "$RECYCLE_BIN_DIR" | awk '{print $1}')
			 
		if (( file_size+current_bin_size >  max_size_kb ))
		then 
		   log error both "${RED}Error: Not enough space available!${NC}"
		   exit_code=1
		   continue
		fi
		
		log info file "There is enough disk space!"
		
		log info file "Generating file id..."
		local file_unique_id=$(generate_unique_id)
		
		log info both "Moving to recycle bin..."

		#
		mv "$original_absolute_path" "$FILES_DIR/$file_unique_id" 2>/dev/null || 
		{
		   log error both "${RED}Error: Permission denied!${NC}"
		   exit_code=1
		   continue
		}
		
		log info both "File moved as: $file_unique_id"
		
		log info file "Adding information to metadata file..."
		
		echo "$file_unique_id|$original_file_name|$original_absolute_path|$deletion_timestamp|$file_size|$file_type|$original_permissions|$original_owner" >> "$METADATA_FILE"
		
		log info file "Information added successfully!"
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
	echo "=== Recycle Bin Contents ==="

	if [[ -z $( ls -A "$FILES_DIR" ) ]]; then
		echo "The Recycle Bin is Currently Empty"
		return 0
	fi

	local total_items=0
	local total_size=0

	if [ "$1" == "--detailed" ]; then #este imprime toda a informação
		while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
			if [ "$file_id" != "# Recycle Bin Metadata" ]; then
				if [[ "$file_id" == "ID" ]]; then
					printf "%-20s %-20s %-40s %-20s %-15s %-23s %-15s %-20s\n" "Id" "Original Name" "Original Path" "Delete Date" "File Size" "File Type" "Permissions" "Owner"
					printf "%-20s %-20s %-40s %-20s %-15s %-23s %-15s %-20s\n" "--------------------" "--------------------" "----------------------------------------" "--------------------" "---------------" "------------------" "--------------" "--------------------"
				else
					local size_to_bytes=$(($file_size * 1024))
					local readable_filesize=$( numfmt --to=iec $size_to_bytes )
					local print_original_name=$original_name
					local print_original_path=$original_path
					if [[ ${#original_name} -gt 20 ]]; then
						print_original_name="${original_name:0:16}..."
					fi
					if [[ ${#original_path} -gt 40 ]]; then
						print_original_path="${original_path:0:36}..."
					fi
					printf "%-20s %-20s %-40s %-20s %-15s %-23s %-15s %-20s\n" "$file_id" "$print_original_name" "$print_original_path" "$deletion_date" "$readable_filesize" "$file_type" "$permissions" "$owner"
					total_items=$(($total_items + 1))
					total_size=$(($total_size + $file_size))
				fi
			fi
		done < "$METADATA_FILE"
	else
		#aqui imprime-se só: id (truncated), original name, deletion date, filesize (legível)
		while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
			if [ "$file_id" != "# Recycle Bin Metadata" ]; then
				if [ "$file_id" == "ID" ]; then
					printf "%-20s %-20s %-20s %-15s\n" "Id" "Original Name" "Delete Date" "File Size"
					printf "%-20s %-20s %-20s %-15s\n" "--------------------" "--------------------" "--------------------" "---------------"
				else
					local size_to_bytes=$(($file_size * 1024))
					local readable_filesize=$( numfmt --to=iec $size_to_bytes )
					local print_original_name=$original_name
					if [[ ${#original_name} -gt 20 ]]; then
						print_original_name="${original_name:0:16}..."
					fi
					printf "%-20s %-20s %-20s %-12s\n" "${file_id:0:10}_..." "$print_original_name" "$deletion_date" "$readable_filesize"
					total_items=$(($total_items + 1))
					total_size=$(($total_size + $file_size))
				fi
			fi
		done < "$METADATA_FILE"
	fi

	log info file "Listed Recycle Bin Contents"
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
	
	log info file "Restore function called with: $recover_file"
	
	if [ -z "$recover_file" ]; then
		log error both "${RED}Error: No file ID specified${NC}"
		return 1
	fi
	
	log info both "Searching file..."
	
	while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner <&3
		do 
	    	if [[ "$recover_file" == "$file_id" || "$recover_file" == "$original_name" ]] 
	     	then 
	        	log info both "File match found!"
				file_found=1
				local restore_name="$original_name"
				local original_dir=$(dirname "$original_path")
	         
	         
				if [[ -d "$original_dir" ]]
				then 
					log info file "Old directory found!"
					if [[ -f "$original_dir/$original_name" ]]
					then 
						log info both "This file already exists at original path!"
						select option in "Overwrite" "Restore with modified name" "Cancel operation"
						do 
							case $option in 
								"Overwrite")
									log info file "Overwrting file..."
									;; 
								"Restore with modified name")
									log info file "Changing file name..."
									local restore_timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
									restore_name="${original_name}_${restore_timestamp}"
									;;
								"Cancel operation")
									log info both "Cancelling restore."
									return 1
									;;
							esac
							break
						done
					fi
				else 
					log info file "Old directory does not exist anymore, creating parent directories..."
					mkdir -p "$original_dir" || 
					{
					log error both "${RED}Error: Permission denied!${NC}"
					return 1
					}
					log info file "Parent directories created: $original_dir"
				fi
				
				log info file "Checking available disk space..." >> "$LOG_FILE"
				
				local available_disk_space=$(df -k "$original_dir" | tail -1 | awk '{print $4}')

				if (( file_size > available_disk_space ))
				then 
					log error both "${RED}Error: Not enough space available!${NC}" 
					return 1
				fi
				
				log info file "Moving file..." 
				mv "$FILES_DIR/$file_id" "$original_dir/$restore_name" 2>/dev/null || 
				{
					log error both "${RED}Error: Permission denied!${NC}" 
					return 1
				}
				
				log info file "Restoring permissions..."
				chmod "$permissions" "$original_dir/$restore_name"
				
				log info file "Removing data from metadata file..."
				sed -i "/^$file_id|/d" "$METADATA_FILE"
				
				log info both "Restore complete!"
	    	fi

	   done 3< <(tail -n +3 "$METADATA_FILE")
	   
	   if [[ $file_found -eq 0 ]]
	   then 
	      log info both "No match was found for file: $recover_file"	
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
	source "$CONFIG_FILE"

	local force=1

	if [[ "$1" == "--force" || "$2" == "--force" ]]; then
		force=0
	fi

	if [[ -z $( ls -A "$FILES_DIR" ) ]]; then
		echo "The Recycle Bin is Currently Empty"
		return 0
	fi
	
	if [ $force -eq 1 ]; then
		read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
		if [[ $PASSWD_ACTIVE -eq 1 ]]; then
			read -sp "Please input your current password to continue: " passwd
			echo ""
			if [[ "$passwd" != "$PASSWD_VALUE" ]]; then
				echo -e "${RED}Wrong password, try again${NC}" 
				exit 1
			fi
		fi
	fi

	if [[ ! -z "$1" && "$1" != "--force" ]]; then
		while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
			if [[ "$file_id" == "$1" || "$original_name" == "$1" ]]; then
				rm -r "$FILES_DIR/$file_id"
				log info both "$file_id - $original_name permanently deleted"
				sed -i "/^$file_id|/d" "$METADATA_FILE"
				log info both "$file_id - $original_name removed from metadata"
				return 0
			fi
		done < "$METADATA_FILE"
		log error both "${RED}Error: file name or id not found${NC}"
	else
		log info both "The following files will be deleted"
		list_recycled
		list_recycled >> $LOG_FILE
		
		rm -r $FILES_DIR
		mkdir -p "$FILES_DIR"
		log info both "Deleted all files"

		sed -i '3,$d' $METADATA_FILE #apaga da 3ª À última linha
		log info both "Metadata has been reset"

		log info both "Recycle Bin emptied"	
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
	
	# METER REFERÊNCIA
	local safe_pattern=$(printf '%s' "$pattern" | sed 's/[.[\^$+{}()|]/\\&/g')
	safe_pattern=$(printf '%s' "$safe_pattern" | sed 's/\*/.*/g; s/\?/./g')
	
	while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner
	do
	   if echo "$original_name" | grep -iqE "$safe_pattern" || echo "$original_path" | grep -iqE "$safe_pattern" 
	   then 
	      matches_found=$(($matches_found+1))
	      if (( matches_found == 1 ))
	      then 
	        printf "%-20s %-20s %-40s %-20s %-12s %-23s %-15s %-20s\n" "Id" "Original Name" "Original Path" "Delete Date" "File Size" "File Type" "Permissions" "Owner"
		 	printf "%-20s %-20s %-40s %-20s %-12s %-23s %-15s %-20s\n" "--------------------" "--------------------" "----------------------------------------" "--------------------" "------------" "------------------" "--------------" "--------------------"
	      fi
			local size_to_bytes=$(($file_size * 1024))
			local readable_filesize=$( numfmt --to=iec $size_to_bytes )
			local print_original_name=$original_name
			local print_original_path=$original_path
			if [[ ${#original_name} -gt 20 ]]; then
				print_original_name="${original_name:0:16}..."
			fi
			if [[ ${#original_path} -gt 40 ]]; then
				print_original_path="${original_path:0:36}..."
			fi
	      	printf "%-20s %-20s %-40s %-20s %-12s %-23s %-15s %-20s\n" "$file_id" "$print_original_name" "$print_original_path" "$deletion_date" "$readable_filesize" "$file_type" "$permissions" "$owner"
	   fi
        done < <(tail -n +3 "$METADATA_FILE")
	
	
	if (( matches_found == 0 ))
	then 
		log error both "${RED}Error: No file with '$pattern' was found.${NC}" 
		return 1
	fi
	
	return 0
}

#################################################
# Function: auto_cleanup (OPTIONAL)
# Description: Auto clean old files from bin
# Parameters: None
# Returns: 0 on success
#################################################
auto_cleanup(){
	#at this moment, autoclean runs manually

	#Get config file variables
	source "$CONFIG_FILE"
	local count=0

	if [ $RETENTION_DAYS -eq -1 ]; then
		log info both "Retention days is not configured."
		return 0
	fi

	if [[ $PASSWD_ACTIVE -eq 1 ]]; then
		read -sp "Please input your current password to continue: " passwd
		echo ""
		if [[ "$passwd" != "$PASSWD_VALUE" ]]; then
			log info both "${RED}Wrong password, try again${NC}" 
			exit 1
		fi
	fi

	while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
		if [[ "$file_id" != "ID" && "$file_id" != "# Recycle Bin Metadata" ]]; then
			#get deletion date as epoch
			local date_convert=$(echo "$deletion_date" | sed 's/_/ /; s/-/:/3; s/-/:/3')
			local del_epoch=$(date --date="$date_convert" +"%s")
			
			#get cutoff date as epoch (fonte é quick reference)
			local cutoff=$(date -d "$RETENTION_DAYS days ago" +%s)
			
			#compare epochs
			if [ $del_epoch -le $cutoff ]; then
				log info both "auto_cleanup will delete $file_id - $original_name"
				count=$(($count + 1))
				empty_recyclebin $file_id "--force"
			fi
		fi
	done < "$METADATA_FILE"

	if [[ $count -eq 0 ]]; then
		log info both "Autoclean didn't delete any files"
	else
		log info both "Autoclean deleted $count files"
	fi
	
	return 0
}

#################################################
# Function: check_quota (OPTIONAL)
# Description: Check if recycle bin exceeds MAX_SIZE_MB
# Parameters: None
# Returns: 0 on success
#################################################
check_quota(){
	log info file "check_quota function called."
	
	source "$CONFIG_FILE"
	
	if [[ $MAX_SIZE_MB -eq -1 ]] 
	then 
		log info both "Max_Size is not configured."
		nano $CONFIG_FILE
		return 1
    fi 
        
    log info file "MAX_SIZE_MB = $MAX_SIZE_MB"
        
    log info file "Fetching recycle bin size..."
    local recycle_bin_size=$(du -sm "$RECYCLE_BIN_DIR" | awk '{print $1}')
    log info file "Recycle bin size: $recycle_bin_size MB."
        
    if (( recycle_bin_size >= MAX_SIZE_MB )) 
    then 
        log error both "${RED}WARNING: Recycle bin is full!${NC}"
        log info file "Asking user to clear space..."
        echo "Do you want to clear some space in recycle bin? [Y/N]"
        read choice
        if [[ $choice == "Y" || $choice == "y" ]] 
        then 
        	log info both "Clearing space..."
        	auto_cleanup
        else 
            log info file "User denied" >> "$LOG_FILE"
            return 1
        fi 
	else
		log info both "Recycle bin size is valid!"
    fi 
        
    return 0
}


#################################################
# Function: show_statistics (OPTIONAL)
# Description: Shows statistics about the bin
# Parameters: None
# Returns: 0 on success
#################################################
show_statistics(){

	source "$CONFIG_FILE"
	local total_items=0
	local total_size=0
	local n_files=0
	local n_dir=0
	local oldest_file=" "
	local oldest_time=0
	local newest_file=" "
	local newest_time=0

	while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner; do
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
	
	local total_size_to_bytes=$(($total_size * 1024))
	local readable_totalsize=$( numfmt --to=iec $total_size_to_bytes )
	local avg_file_size=$(( $total_size / $total_items ))
	local avg_size_to_bytes=$(($avg_file_size * 1024))
	local readable_avgsize=$( numfmt --to=iec $avg_size_to_bytes )
	local recycle_bin_size_mb=$(du -sm "$RECYCLE_BIN_DIR" | awk '{print $1}')
	#local quota_percentage;

	log info both "=== Statistics ==="
	log info both "Total number of items: $total_items"
	if [[ $MAX_SIZE_MB -eq -1 ]]; then
		log info both "Total size of bin: $readable_totalsize"
	else
		local quota_percentage=$(echo "scale=3; $recycle_bin_size_mb / $MAX_SIZE_MB" | bc -l)
		log info both "Storage used: $quota_percentage %"
	fi
	log info both "Number of files in bin: $n_files"
	log info both "Number of directories in bin: $n_dir"
	log info both "Oldest item in bin: $oldest_file"
	log info both "Newest item in bin: $newest_file"
	log info both "Average size of item: $readable_avgsize"

}

########################################################################################
# Function: file_preview (OPTIONAL)
# Description: Show first 10 lines for text files or file information for binary files
# Parameters: $1 - unique ID of file to preview
# Returns: 0 on success
########################################################################################
file_preview(){
	local file_id="$1"
	
	# Validate input
	if [ -z "$file_id" ]; then
	log error both "${RED}Error: No file id specified${NC}"
	return 1
	fi
		
	log info file "file_preview function called with: $file_id"
	
	local file_path="$FILES_DIR/$file_id"
	
	# Check if file exists
	if [ ! -e "$file_path" ]; then
	log error both "${RED}Error: File '$file_path' does not exist${NC}"
	return 1
	fi
	
	if file "$file_path" | grep -q text
	then 
		log info both "$file_id is a text file."
		log info file "Showing first ten lines... "
		
		echo "First ten lines: "
		head -n 10 "$file_path"
	else 
		log info both "$file_id is a binary file."
		log info file "Displaying file information..."
		
		echo "File information: "
		file "$file_path"
	fi
	
	return 0
}

#################################################
# Function: secure_operation
# Description: Adds password protection for sensitive operations
# Parameters: None
# Returns: 0 on success, exit 1 if cancelled
#################################################
secure_operation(){
	source "$CONFIG_FILE"
	local passwd_active=$PASSWD_ACTIVE
	local passwd_value=$PASSWD_VALUE
	log info file "secure_operation called"
	if [[ $passwd_active -eq 0 ]]; then
		read -p "Password is currently inactive, would you like to activate it? [Y/n]" activate
		if [[ ! "$activate" =~ ^([yY]|[yY][eE][sS])$ ]]; then
			echo "Exiting"
			return 0
		fi
		read -sp "Please set your new password: " passwd
		echo ""
		passwd_active=1
		passwd_value="$passwd"
		log info both "Password is now active and set"
	elif [[ $passwd_active -eq 1 ]]; then
		echo "Password is currently active"
		echo "Would you like to:"
		echo "(1) : Deactivate password"
		echo "(2) : Change password"
		echo "(3) : Exit"
		read option

		if [[ $option -eq 1 ]]; then
			read -sp "Please input your current password: " passwd
			echo ""
			if [[ "$passwd" == "$passwd_value" ]]; then
				passwd_active=0
				log info both "Password is now inactive"
			else
				echo -e "${RED}Wrong password, try again${NC}"
				exit 1
			fi
		elif [[ $option -eq 2 ]]; then
			read -sp "Please input your current password: " passwd
			echo ""
			if [[ "$passwd" == "$passwd_value" ]]; then
				read -sp "Please set your new password: " passwd
				echo ""
				passwd_value="$passwd"
				log info both "Password has been changed"
			else
				echo -e "${RED}Wrong password, try again${NC}"
				exit 1
			fi
		else
			echo "Exiting"
			return 0
		fi
	else
		echo -e "${RED}An error has ocurred, deactivating password${NC}"
		passwd_active=0
	fi

	sed -i '6,7d' $CONFIG_FILE
	echo "PASSWD_ACTIVE=$passwd_active" >> "$CONFIG_FILE"
	echo "PASSWD_VALUE=$passwd_value" >> "$CONFIG_FILE"
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
	autoclean Eliminates old files in recycle bin
	stats Shows statistics about recycle bin
	config Opens config file for editing
	quota Checks if recycle bin exceeds quota
	preview <id> Allows to preview files by id 
	secure Allows setting a password to protect sensitive operations

EXAMPLES:
	$0 delete myfile.txt
	$0 list
	$0 restore 1696234567_abc123
	$0 search "*.pdf"
	$0 empty
	$0 autoclean
	$0 stats
	$0 quota
	$0 preview 1234567890_abc123
	$0 secure

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
			nano "$CONFIG_FILE"
			;;
		quota) 
			check_quota
			;; 
		preview) 
			file_preview "$2"
			;;
		secure)
			secure_operation
			;;
		*)
			echo "Invalid option. Use 'help' for usage information."
			exit 1
			;;
	esac
}

# Execute main function with all arguments
main "$@"
