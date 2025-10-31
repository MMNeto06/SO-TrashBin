#!/bin/bash

# Test Suite for Recycle Bin System
SCRIPT="./recycle_bin.sh"
TEST_DIR="test_data"
CONFIG=~/.recycle_bin/config #necessary for some tests
METADATA_FILE=~/.recycle_bin/metadata.db # necessary for testcase 41 & 42 (get id)
PASS=0
FAIL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test Helper Functions
setup() {
	mkdir -p "$TEST_DIR"
	rm -rf ~/.recycle_bin
}

teardown() {
	rm -rf "$TEST_DIR"
	rm -rf ~/.recycle_bin
}

assert_success() {
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}✓ PASS${NC}: $1"
		((PASS++))
	else
		echo -e "${RED}✗ FAIL${NC}: $1"
		((FAIL++))
	fi
}

assert_fail() {
	if [ $? -ne 0 ]; then
		echo -e "${GREEN}✓ PASS${NC}: $1"
		((PASS++))
	else
		echo -e "${RED}✗ FAIL${NC}: $1"
		((FAIL++))
	fi
}

# Test Cases
#testcase 1
test_initialization() {
	echo "=== Testcase 1: Initialization ==="
	setup
	$SCRIPT help > /dev/null
	assert_success "Initialize recycle bin"
	[ -d ~/.recycle_bin ] && echo "✓ Directory created"
	[ -f ~/.recycle_bin/metadata.db ] && echo "✓ Metadata file created"
}

#testcase 2
test_delete_file() {
	echo "=== Testcase 2: Delete File ==="
	setup
	echo "test content" > "$TEST_DIR/test.txt"
	$SCRIPT delete "$TEST_DIR/test.txt"
	assert_success "Delete existing file"
	[ ! -f "$TEST_DIR/test.txt" ] && echo "✓ File removed from original location"
}

#testcase 3
test_delete_multiple_files(){ 
	echo "=== Testcase 3: Delete multiple files with one command ==="
	setup
	echo "test content" > "$TEST_DIR/test1.txt"
	echo "test content" > "$TEST_DIR/test2.txt"
	echo "test content" > "$TEST_DIR/test3.txt"
	$SCRIPT delete "$TEST_DIR/test1.txt" "$TEST_DIR/test2.txt" "$TEST_DIR/test3.txt"
	assert_success "Deleted existing files"
	[ ! -f "$TEST_DIR/test1.txt" ] && echo "✓ test1.txt removed from original location"
	[ ! -f "$TEST_DIR/test2.txt" ] && echo "✓ test2.txt removed from original location"
	[ ! -f "$TEST_DIR/test3.txt" ] && echo "✓ test3.txt removed from original location"
} 

#testcase 4
test_delete_empty_directory(){
	echo "=== Testcase 4: Delete an empty directory ==="
	setup
	mkdir -p "$TEST_DIR/test"
	$SCRIPT delete "$TEST_DIR/test"
	assert_success "Deleted directory"
	[ ! -d "$TEST_DIR/test" ] && echo "✓ Directory removed from original location"
	$SCRIPT "list" "--detailed"
	if $SCRIPT "list" "--detailed" | grep -q "test"; then
    	echo "✓ 'test' found in output"
	fi
}

#testcase 5
test_delete_directory(){
	return 0
}

#testcase 6
test_list_empty() {
	echo "=== Testcase 6: List Empty Bin ==="
	setup
	$SCRIPT list | grep -q "Empty"
	assert_success "List empty recycle bin"
}

#testcase 7
test_restore_file() {
	echo "=== Testcase 7: Restore File ==="
	setup
	echo "test" > "$TEST_DIR/restore_test.txt"
	$SCRIPT delete "$TEST_DIR/restore_test.txt"
	# Get file ID from list
	ID=$($SCRIPT list --detailed | grep "restore_test" | awk '{print $1}')
	$SCRIPT restore "$ID"
	assert_success "Restore file"
	[ -f "$TEST_DIR/restore_test.txt" ] && echo "✓ File restored"
}

#testcase 8
test_restore_to_missing_path(){
	echo "=== Testcase 8: Restore File to missing path ==="
	setup
	mkdir "$TEST_DIR/testDir"
	touch "$TEST_DIR/testDir/testFile"
	$SCRIPT delete "$TEST_DIR/testDir/testFile"
	rmdir "$TEST_DIR/testDir"
	[ ! -d "$TEST_DIR/testDir" ] && echo "✓ Test Directory removed"
	$SCRIPT restore "testFile"
	assert_success "File restored"
	[ -f "$TEST_DIR/testDir/restore_test.txt" ] && echo "✓ File restored"
}

#tescase 9
test_empty_bin(){
	echo "=== Testcase 9: Empty recycle bin ==="
	setup
	echo "test content" > "$TEST_DIR/test1.txt"
	echo "test content" > "$TEST_DIR/test2.txt"
	echo "test content" > "$TEST_DIR/test3.txt"
	$SCRIPT delete "$TEST_DIR/test1.txt" "$TEST_DIR/test2.txt" "$TEST_DIR/test3.txt"
	[ ! -f "$TEST_DIR/test1.txt" ] && echo "✓ File removed from original location"
	[ ! -f "$TEST_DIR/test2.txt" ] && echo "✓ File removed from original location"
	[ ! -f "$TEST_DIR/test3.txt" ] && echo "✓ File removed from original location"
	if $SCRIPT "list" | grep -q "Number of Items in Recycle Bin: 3"; then
    	echo "✓ All files found in bin"
	fi
	$SCRIPT empty --force #done to skip confirmation
	assert_success "Recycle bin emptied"
	if $SCRIPT "list" | grep -q "The Recycle Bin is Currently Empty"; then
    	echo "✓ Metadata and files folder have been reset"
	fi
}

#testcase 10
test_search_success(){
	echo "=== Testcase 10: Search File (Success) ==="
	setup
	echo "test content" > "$TEST_DIR/testFile"
	$SCRIPT delete "$TEST_DIR/testFile"
	[ ! -f "$TEST_DIR/testFile" ] && echo "✓ File removed from original location"
	$SCRIPT search testFile
	assert_success "testFile was found with search"
}

#testcase 11
test_search_failure(){
	echo "=== Testcase 11: Search File (Failure) ==="
	setup
	echo "test content" > "$TEST_DIR/testFile"
	$SCRIPT delete "$TEST_DIR/testFile"
	[ ! -f "$TEST_DIR/testFile" ] && echo "✓ File removed from original location"
	$SCRIPT search nonExistentFile
	assert_fail "No files were found with pattern 'nonExistentFile' using search"
}

#testcase 12
test_help(){
	echo "=== Testcase 12: Display Help ==="
	setup
	$SCRIPT help
	assert_success "Display help"
	if $SCRIPT "help" | grep -q "Linux Recycle Bin - Usage Guide"; then
    	echo "✓ Help message was completely displayed"
	fi

}

#testcase 13
test_delete_non_existent_file(){
	echo "=== Testcase 13: Delete Non-Existent File ==="
	setup
	$SCRIPT delete "$TEST_DIR/nonExistentFile"
	assert_fail "File does not exist"
}

#testcase 14 
test_delete_file_without_permission(){
	echo "=== Testcase 14: Delete File Without Permissions ==="
	setup
	touch "$TEST_DIR/protectedFile"
	chmod 000 "$TEST_DIR/protectedFile"
	$SCRIPT delete "$TEST_DIR/protectedFile"
	assert_fail "Insufficient permissions"
}

#testcase 15 
test_restore_original_location_has_same_filename_success(){
	echo "=== Testcase 15: Original Location has Same Filename ==="
	setup
	touch "$TEST_DIR/testFile"
	$SCRIPT delete $TEST_DIR/testFile
	touch "$TEST_DIR/testFile"
	echo "assert_success when user selects Overwrite or Restore with modified name option"
	{ echo 1; } | $SCRIPT restore testFile
	assert_success "Overwrite/Modified name"
}

test_restore_original_location_has_same_filename_failure(){
	setup
	touch "$TEST_DIR/testFile"
	$SCRIPT delete "$TEST_DIR/testFile"
	touch "$TEST_DIR/testFile"
	echo "assert_fail when user selects Cancel operation option" 
	{ echo 3; } | $SCRIPT restore testFile
	assert_fail "Cancel Operation"
}

#testcase 16 
test_restore_nonexistent_fileid(){
	echo "=== Testcase 16: Restore Non-Existent File Id ==="
	setup
	$SCRIPT restore fakeid_1234
	assert_fail "No match found"
}

#testcase 17 
test_filename_with_spaces(){
	echo "=== Testcase 17: Handle Filename with Spaces ==="
	setup
	touch "$TEST_DIR"/"file name with spaces"
	$SCRIPT delete "$TEST_DIR"/"file name with spaces"
	assert_success "Filename with spaces was deleted"
	$SCRIPT restore "file name with spaces"
	assert_success "Filename with spaces was restored"
}

#testcase 18
test_filename_with_special_characters(){
	echo "=== Testcase 18: Handle Filename with Special Characters ==="
	setup
	touch "$TEST_DIR"/'file@#$%^&*()'
	$SCRIPT delete "$TEST_DIR"/'file@#$%^&*()'
	assert_success "Filename with special characters was deleted"
	$SCRIPT restore 'file@#$%^&*()'
	assert_success "Filename with special characters was restored"
}

#testcase 19 
test_long_filename(){
	echo "=== Testcase 19: Handle Very Long Filenames ==="
	setup
	touch "$TEST_DIR/"$(printf 'a%.0s' {1..250})""
	$SCRIPT delete "$TEST_DIR/"$(printf 'a%.0s' {1..250})""
	assert_success "Very long filename was deleted"
	$SCRIPT restore "$(printf 'a%.0s' {1..250})"
	assert_success "Very long filename was restored"
}

#testcase 20
test_very_large_file(){
	echo "=== Testcase 20: Handle Very Large Files ==="
	setup
	fallocate -l 150M "$TEST_DIR/largeTestFile"
	$SCRIPT delete "$TEST_DIR/largeTestFile"
	assert_success "Very large file was deleted"
	$SCRIPT restore largeTestFile
	assert_success "Very large file was restored"
}

#testcase 21
test_symbolic_links(){
	echo "=== Testcase 21: Handle Symbolic Links ==="
	setup
	touch "$TEST_DIR/testFile"
	ln -s "$TEST_DIR/testFile" "$TEST_DIR/linkToTestFile"

	$SCRIPT delete "$TEST_DIR/linkToTestFile"

	if [[ -e "$TEST_DIR/testFile" ]]
	then 
		assert_success "Link was not followed"
	fi

	$SCRIPT restore linkToTestFile

	if [[ -L "$TEST_DIR/linkToTestFile" ]]
	then 
		assert_success "Link was restored"
	fi 
}

#testcase 22 
test_hidden_file(){
	echo "=== Testcase 22: Handle Hidden Files ==="
	setup
	touch "$TEST_DIR/.hiddenFile"
	$SCRIPT delete "$TEST_DIR/.hiddenFile"
	assert_success "Hidden file was moved"
	$SCRIPT restore .hiddenFile
	assert_success "Hidden file was restored"
}

#testcase 23
test_delete_from_different_directories(){
	echo "=== Testcase 23: Delete Files from Different Directories ==="
	setup
	mkdir -p "$TEST_DIR/testDir1"
	mkdir -p "$TEST_DIR/testDir2"
	touch "$TEST_DIR/testDir1/testFile1" "$TEST_DIR/testDir2/testFile2"
	$SCRIPT delete "$TEST_DIR/testDir1/testFile1" "$TEST_DIR/testDir2/testFile2"
	assert_success "Files from different directories were moved"
	$SCRIPT restore testFile1
	$SCRIPT restore testFile2
	assert_success "Files from different directories were restored"
}

#testcase 24
test_restore_to_readonly_directory(){
	echo "=== Testcase 24: Restore Files to Read-Only Directories ==="
	setup
	mkdir -p "$TEST_DIR/testDir"
	touch "$TEST_DIR/testDir/testFile"
	$SCRIPT delete "$TEST_DIR/testDir/testFile"
	chmod -wx "$TEST_DIR/testDir"
	$SCRIPT restore testFile
	assert_fail "File was not restored to Read-Only Directory"
}

#testcase 25
test_invalid_command(){
	echo "=== Testcase 25: Invalid command ==="
	setup
	$SCRIPT "nonexistentcommand" "abc" "123"
	assert_fail "Invalid command message was shown"
}

#testcase 26
test_missing_parameters(){
	echo "=== Testcase 26: Missing required paramaters ==="
	setup
	$SCRIPT "delete"
	assert_fail "Missing parameters message was shown"
}

#testcase 27
test_corrupted_metadata(){
	echo "=== Testcase 27: Corrupted metadata ==="
	setup
	$SCRIPT #initialize script
	rm ~/.recycle_bin/metadata.db
	$SCRIPT help
	assert_success "Metadata was repaired after being detected as corrupted"
}

#testcase 28
test_insufficient_disk_space(){
	echo "=== Testcase 28: Insufficient disk space ==="
	setup
	$SCRIPT list #enough to initialize
	source $CONFIG
	available_space=$(df --output=avail -BG . | tail -1) #gets available space in GB
	available_space_mb=$(df --output=avail -BM . | tail -1) #gets available space in MB
	avail_gb=${available_space%G} #removes the g
	large_size=$((avail_gb / 2 + avail_gb / 10)) #makes the siz ehalf of the avilable +  a tenth. change this as necessary
	fallocate -l "${large_size}G" "$TEST_DIR/largefile.bin"
	$SCRIPT delete "$TEST_DIR/largefile.bin"
	assert_fail "Large file was not moved as it exceeds quota"
	avail_mb=${available_space_mb%M} #cuts the M
	sed -i '5d' $CONFIG
	sed -i "5i\MAX_SIZE_MB=${avail_mb}" $CONFIG #makes the max size mb as the full disk availability
	$SCRIPT delete "$TEST_DIR/largefile.bin"
	$SCRIPT list
	$SCRIPT restore "largefile.bin"
	assert_fail "Large file was not restored due to lack of space"
}

#testcase 29
test_permission_denied_errors(){
	echo "=== Testcase 29: Permission denied errors ==="
	setup
	mkdir "$TEST_DIR/testDir"
	touch "$TEST_DIR/testDir/test"
	chmod 0 "$TEST_DIR/testDir"
	echo "✓ File without permission created"
	$SCRIPT delete "$TEST_DIR/testDir/test"
	assert_fail "Test file failed to be deleted due to lack of permission"
	$SCRIPT delete "$TEST_DIR/testDir"
	assert_fail "Test directory failed to be deleted due to lack of permission"
	chmod 755 "$TEST_DIR/testDir"
}

#testcase 30
test_delete_recycle_bin_itself(){
	echo "=== Testcase 30: Delete recycle bin itself ==="
	setup
	$SCRIPT
	$SCRIPT delete ~/.recycle_bin
	assert_fail "Recycle bin itself was not deleted"
}

#testcase 31
#Note: Either one of the processes could be blocked, it is random.
test_concurrent_operations(){
	echo "=== Testcase 31: Handle Concurrent Operations ==="
	setup
	touch "$TEST_DIR/testFile1" "$TEST_DIR/testFile2"
	$SCRIPT delete "$TEST_DIR/testFile1" &
	$SCRIPT delete "$TEST_DIR/testFile2" &
	wait

	if [[ -f "$TEST_DIR/testFile1" ]]
	then 
		assert_success "Concurrent operations were denied"
	elif [[ -f "$TEST_DIR/testFile2" ]]
	then
		assert_success "Concurrent operations were denied"
	else 
		echo "${RED}Both files were moved.${NC}"
	fi
}

#all performance testcases in one so testcase 32-35
test_performace(){ 
	echo "=== Performance Tests ==="
	setup
	echo "=== Testcase 32: Delete 100 Files ==="
	#making the files
	for i in {1..100}; do
		touch "$TEST_DIR/file_$i"
		echo "This is file number $i" >> "$TEST_DIR/file_$i"
	done
	echo "All test files for performance created"
	start=$(date +%s.%N)
	for i in {1..100}; do
		$SCRIPT "delete" "$TEST_DIR/file_$i"
		[ ! -f "$TEST_DIR/file_$i" ] && echo "✓ File removed from original location"
	done;
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	assert_success "All files were successfully deleted"
	echo "Time to delete files: $elapsed_time s"

	echo "=== Testcase 33: List 100 Files ==="
	start=$(date +%s.%N)
	$SCRIPT "list"
	assert_success "All files were successfully listed"
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	echo "Time to list recycle bin: $elapsed_time s"
	

	echo "=== Testcase 34: Search in 100 Files ==="
	start=$(date +%s.%N)
	$SCRIPT "search" "1" #Change if needed
	assert_success "All files were successfully searched"
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	echo "Time to search recycle bin: $elapsed_time s"

	echo "=== Testcase 35: Restore the last of 100 Files ==="
	start=$(date +%s.%N)
	$SCRIPT "restore" "file_100"
	assert_success "The file was successfully restored"
	[ -f "$TEST_DIR/file_100" ] && echo "✓ Last file restored"
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	echo "Time to restore file_100: $elapsed_time s"
}

#testcase 36
test_autoclean(){
	echo "=== Testcase 36: Autoclean the recycle bin ==="
	setup
	source $CONFIG
	sed -i '4d' $CONFIG
	sed -i '4i\RETENTION_DAYS=30' $CONFIG
	touch "$TEST_DIR/test.txt"
	$SCRIPT delete "$TEST_DIR/test.txt"
	[ ! -f "$TEST_DIR/test.txt" ] && echo "✓ File removed from original location"
	$SCRIPT autoclean
	assert_success "Recycle bin was autocleaned"
}

#testcase 37
test_stats(){
	echo "=== Testcase 37: Show statistics about the recycle bin ==="
	setup
	echo "test content" > "$TEST_DIR/test1.txt"
	echo "test content" > "$TEST_DIR/test2.txt"
	echo "test content" > "$TEST_DIR/test3.txt"
	fallocate -l 1G "$TEST_DIR/large.bin"
	$SCRIPT delete "$TEST_DIR/test1.txt" "$TEST_DIR/test2.txt" "$TEST_DIR/test3.txt" "$TEST_DIR/large.bin"
	[ ! -f "$TEST_DIR/test1.txt" ] && echo "✓ test1.txt removed from original location"
	[ ! -f "$TEST_DIR/test2.txt" ] && echo "✓ test2.txt removed from original location"
	[ ! -f "$TEST_DIR/test3.txt" ] && echo "✓ test3.txt removed from original location"
	[ ! -f "$TEST_DIR/large.bin" ] && echo "✓ large.bin removed from original location"
	$SCRIPT stats
	assert_success "Statistics have been shown"
	if $SCRIPT "stats" | grep -q "=== Statistics ==="; then
    	echo "✓ Stats have been shown"
	fi
}

#auxiliary function for test_password
test_password_delete_file(){
	echo "test content" > "$TEST_DIR/test"
	$SCRIPT delete "$TEST_DIR/test"
}

#testcase 38-41
test_password(){
	setup
	echo "=== Password Tests ==="
	echo "=== Testcase 38: Set password ==="
	test_password_delete_file
	{ echo Y; echo 1234; } | $SCRIPT secure
	assert_success "Password has been set"
	if { echo Y; echo 1234; } | $SCRIPT empty | grep -q "password to continue"; then
    	echo "✓ Bin emptied, asked for password"
	fi

	echo "=== Testcase 39: Change password ==="
	test_password_delete_file
	{ echo 2; echo 1234; echo 0000; } | $SCRIPT secure
	assert_success "Password has been changed"
	if { echo Y; echo 0000; } | $SCRIPT empty | grep -q "password to continue"; then
    	echo "✓ Bin emptied, asked for password"
	fi

	echo "=== Testcase 41: Wrong password error ==="
	test_password_delete_file
	{ echo Y; echo 1234; } | $SCRIPT empty
	assert_fail "Wrong password has been checked"

	echo "=== Testcase 40: Disable password ==="
	{ echo 1; echo 0000; } | $SCRIPT secure
	assert_success "Password has been disabled"
	if { echo Y; } | $SCRIPT empty | grep -q "Recycle Bin emptied"; then
    	echo "✓ Bin emptied, did not ask for password"
	fi

}

#testcase 42
test_preview_txt(){
	echo "=== Testcase 42: Preview First 10 Lines of File ==="
	setup
	local n=1
	local deleted_file_id=""

	while ((n < 13))
	do 
		echo "linha $n" >> "$TEST_DIR/testFile"
		n=$(($n+1))
	done

	$SCRIPT delete "$TEST_DIR/testFile"
	
	while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner
	do 
		deleted_file_id=$file_id
	done < <(tail -n +3 "$METADATA_FILE")

	$SCRIPT preview "$deleted_file_id"
	
	assert_success "First 10 lines are displayed"
}

#testcase 43
test_preview_binary(){
	echo "=== Testcase 43: View Information of a Binary File ==="
	setup
	echo -ne "\x00\x01\x02\x03" > "$TEST_DIR/testBinaryFile"

	$SCRIPT delete "$TEST_DIR/testBinaryFile"
	
	while IFS='|' read -r file_id original_name original_path deletion_date file_size file_type permissions owner
	do 
		deleted_file_id=$file_id
	done < <(tail -n +3 "$METADATA_FILE")

	$SCRIPT preview "$deleted_file_id"
	
	assert_success "Binary file information is displayed"
}

#testcase 44 
#Note: User must agree to space clearance
test_quota(){
	echo "=== Testcase 44: Check Recycle Bin Size is Within Limits ==="
	setup
	fallocate -l 5M "$TEST_DIR/testFile"
	$SCRIPT delete "$TEST_DIR/testFile"
	sed -i '5d' $CONFIG
	sed -i '5i\MAX_SIZE_MB=0' $CONFIG
	sed -i '5i\RETENTION_DAYS=0' $CONFIG

	{ echo Y; } | $SCRIPT quota

	assert_success "Quota check was successful"
}

# Run all tests
echo "========================================="
echo " Recycle Bin Test Suite"
echo "========================================="
test_initialization
test_delete_file
test_delete_multiple_files
test_delete_empty_directory
test_delete_directory
test_list_empty
test_restore_file
test_restore_to_missing_path
test_empty_bin
test_search_success
test_search_failure
test_help
test_delete_non_existent_file
test_delete_file_without_permission
test_restore_original_location_has_same_filename_success
test_restore_original_location_has_same_filename_failure
test_restore_nonexistent_fileid
test_filename_with_spaces
test_filename_with_special_characters
test_long_filename
test_very_large_file
test_symbolic_links
test_hidden_file
test_delete_from_different_directories
test_restore_to_readonly_directory
test_invalid_command
test_missing_parameters
test_corrupted_metadata
test_insufficient_disk_space
test_permission_denied_errors
test_delete_recycle_bin_itself
test_concurrent_operations
test_performace
test_autoclean
test_stats
test_password
test_preview_txt
test_preview_binary
test_quota
teardown
echo "========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "========================================="
[ $FAIL -eq 0 ] && exit 0 || exit 1 #tem que dar 44 passed!
