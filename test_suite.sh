#!/bin/bash

# Test Suite for Recycle Bin System
SCRIPT="./recycle_bin.sh"
TEST_DIR="test_data"
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
test_initialization() {
	echo "=== Test: Initialization ==="
	setup
	$SCRIPT help > /dev/null
	assert_success "Initialize recycle bin"
	[ -d ~/.recycle_bin ] && echo "✓ Directory created"
	[ -f ~/.recycle_bin/metadata.db ] && echo "✓ Metadata file created"
}

test_delete_file() {
	echo "=== Test: Delete File ==="
	setup
	echo "test content" > "$TEST_DIR/test.txt"
	$SCRIPT delete "$TEST_DIR/test.txt"
	assert_success "Delete existing file"
	[ ! -f "$TEST_DIR/test.txt" ] && echo "✓ File removed from original
	location"
}

test_list_empty() {
	echo "=== Test: List Empty Bin ==="
	setup
	$SCRIPT list | grep -q "Empty"
	assert_success "List empty recycle bin"
}

test_restore_file() {
	echo "=== Test: Restore File ==="
	setup
	echo "test" > "$TEST_DIR/restore_test.txt"
	$SCRIPT delete "$TEST_DIR/restore_test.txt"
	# Get file ID from list
	ID=$($SCRIPT list --detailed | grep "restore_test" | awk '{print $1}')
	$SCRIPT restore "$ID"
	assert_success "Restore file"
	[ -f "$TEST_DIR/restore_test.txt" ] && echo "✓ File restored"
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
	echo "=== Testcase 26: Missing required paramaters==="
	setup
	$SCRIPT "delete"
	assert_fail "MIssing parameters message was shown"
}

#testcase 27
test_corrupted_metadata(){
	echo "=== Testcase 26: Missing required paramaters==="
	setup
	rm ~/.recycle_bin/metadata.db
	$SCRIPT help
	assert_success "Metadata was repaired after being detected as corrupted"
}

test_performance_make_files(){
	for i in {1..100}; do
		touch "$TEST_DIR/file_$i"
		echo "This is file number $i" >> "$TEST_DIR/file_$i"
	done
	echo "All test files for performance created"
}

#all performance testcases in one
test_performace(){ #NOTA PARA SILVA: olá, eu fiz este teste numa única função por ser prático. P.S.: vandalismo
	setup
	echo "=== Performance Test: Delete 100 Files ==="
	test_performance_make_files
	start=$(date +%s.%N)
	for i in {1..100}; do
		$SCRIPT "delete" "$TEST_DIR/file_$i"
		[ ! -f "$TEST_DIR/file_$i" ] && echo "✓ File removed from original location"
	done;
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	assert_success "All files were successfully deleted"
	echo "Time to delete files: $elapsed_time s"

	echo "=== Performance Test: List 100 Files ==="
	start=$(date +%s.%N)
	$SCRIPT "list"
	assert_success "All files were successfully listed"
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	echo "Time to list recycle bin: $elapsed_time s"
	

	echo "=== Performance Test: Search in 100 Files ==="
	start=$(date +%s.%N)
	$SCRIPT "search" "1" #Change if needed
	assert_success "All files were successfully searched"
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	echo "Time to search recycle bin: $elapsed_time s"

	echo "=== Performance Test: Restore the last of 100 Files ==="
	start=$(date +%s.%N)
	$SCRIPT "restore" "file_100"
	assert_success "The file was successfully restored"
	[ -f "$TEST_DIR/file_100" ] && echo "✓ Last file restored"
	end=$(date +%s.%N)
	elapsed_time=$(echo $end - $start | bc)
	echo "Time to restore file_100: $elapsed_time s"
}



# Run all tests
echo "========================================="
echo " Recycle Bin Test Suite"
echo "========================================="
test_initialization
test_delete_file
test_list_empty
test_restore_file
# Add more test functions here
test_invalid_command
test_missing_parameters
test_performace
teardown
echo "========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "========================================="
[ $FAIL -eq 0 ] && exit 0 || exit 1
