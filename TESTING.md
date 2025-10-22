# MANUAL TESTING

## Basic Functionality Tests

### Test Case 1: Initialize Recycle Bin Structure
**Objective:** Verify that the recycle bin structure is initialized correctly.

**Steps:**
1. Run the main script with an option of your choice: `./recycle_bin.sh help`
2. Verify the following message is written on the terminal: `echo "Recycle bin initialized at ~/.recycle_bin"`
3. Run `ls ~/.recycle_bin`
4. Verify `config`, `metadata.db` and `recyclebin.log` files are there, aswell as `files` directory.

**Expected Result:**
- ~/.recycle_bin directory is created
- config, metadata.db and recyclebin.log files are created
- files directory is created
- Success message is displayed

**Actual Result:** 
- Sucess message displayed: "Recycle bin initialized at ~/.recycle_bin"
- Files and directoried are created: config, metadata.db, recyclebin.log, files/

**Status:** ✅ Pass

**Screenshots:** 
- Success message displayed: 
![Success message](screenshots/testcase1_initialization_message.png)

- Recycle bin structure: 
![Recycle bin structure](screenshots/testcase1_recycle_bin_structure.png)

### Test Case 2: Delete Single File
**Objective:** Verify that a single file can be deleted successfully

**Steps:**
1. Create test file: `touch testFile`
2. Run: `./recycle_bin.sh delete testFile`
3. Verify file is removed from current directory
4. Run: `./recycle_bin.sh list`
5. Verify file appears in recycle bin
**Expected Result:**
- File is moved to ~/.recycle_bin/files/
- Metadata entry is created
- Success message is displayed
- File appears in list output
**Actual Result:** 
- Success message is displayed: "File moved as: 1761143792_w5fmrh"
- File is removed from current directory
- Metadata entry is created: "1761143792_w5fmrh|testFile|/home/dsilva/Desktop/SO-TrashBin/testFile|2025-10-22_15-36-32|4|regular file|664|dsilva:dsilva"
- File appears in list output

**Status:** ✅ Pass

**Screenshots:** 
- Success message displayed:
![Success message](screenshots/testcase2_file_moved_message.png)

- Metadata entry: 
![Metadata entry](screenshots/testcase2_metadata_entry.png)

- List output: 
![List output](screenshots/testcase2_list_output.png)

### Test Case 3: Delete Multiple Files in One Command
**Objective:** Verify that multiple files can be deleted successfully

**Steps:**
1. Create multiple test files: `touch testFile1 testFile2 testFile3`
2. Run: `./recycle_bin.sh delete testFile1 testFile2 testFile3`
3. Verify files are removed from current directory
4. Run: `./recycle_bin.sh list`
5. Verify files appear in recycle bin

**Expected Result:**
- Files are moved to ~/.recycle_bin/files/
- Metadata entries are created
- Success messages are displayed
- Files appear in list output

**Actual Result:** 
- Success messages are displayed: "File moved as: 1761144530_sr1jzu", "File moved as: 1761144530_1e1ph2", "File moved as: 1761144531_fkuhhq".
- Files are removed from current directory
- Metadata entries are created: "1761144530_sr1jzu|testFile1|/home/dsilva/Desktop/SO-TrashBin/testFile1|2025-10-22_15-48-50|0|regular empty file|664|dsilva:dsilva", "1761144530_1e1ph2|testFile2|/home/dsilva/Desktop/SO-TrashBin/testFile2|2025-10-22_15-48-50|0|regular empty file|664|dsilva:dsilva", "1761144531_fkuhhq|testFile3|/home/dsilva/Desktop/SO-TrashBin/testFile3|2025-10-22_15-48-51|0|regular empty file|664|dsilva:dsilva"
- Files appear in list output

**Status:** ✅ Pass

**Screenshots:** 
- Success messages displayed:
![Success messages](screenshots/testcase3_files_moved_messages.png)

- Metadata entries: 
![Metadata entries](screenshots/testcase3_metadata_entries.png)

- List output: 
![List output](screenshots/testcase3_list_output.png)

### Test Case 4: TODO (Delete Empty Directory) -> EU 

### Test Case 5: TODO (Delete Directory with Contents (recursive)) -> EU

### Test Case 6: TODO (List Empty Recycle Bin)

### Test Case 7: Restore Single File
**Objective:** Verify that a single file can be restored successfully

**Pre-condition:** File must already exist in recycle bin (follow Test Case 2: Delete Single File).

**Steps:**
1. Run: `./recycle_bin.sh restore testFile` or `./recycle_bin.sh restore [file_id]`
2. Verify file is back at original directory
3. Run: `./recycle_bin.sh list`
4. Verify restored file does not appear in recycle bin

**Expected Result:**
- File is moved to original directory
- Metadata entry is erased
- Success message is displayed
- File does not appear in list output

**Actual Result:** 
- Success message is displayed: "Restore complete!"
- File is moved to original directory
- Metadata entry is erased
- File does not appear in list output

**Status:** ✅ Pass

**Screenshots:** 
- Success message displayed:
![Success message](screenshots/testcase4_restore_message.png)

- Metadata file has no entries: 
![Metadata file entries](screenshots/testcase4_metadata_entries.png)

- List output: 
![List output](screenshots/testcase4_list_output.png)

### Test Case 8: Restore to Non-existent Original Path -> VAI SOFRER ALTERAÇÕES, TODO
**Objective:** Verify that a file can be restored to a non-existent original path successfully

**Important:** Be careful with file names (it is safer to use file ids) or make sure that recycle bin is empty.

**Steps:**
1. Run (Create test directory): `mkdir -p testDir`
2. Run (Create test file inside test directory): `touch testDir/testFile`
3. Run: `./recycle_bin.sh delete testDir/testFile`
4. Verify that testFile is not inside testDir anymore
5. Run: `rmdir testDir`
6. Verify testDir does not exist anymore
7. Run: `./recycle_bin.sh restore testFile`
8. Verify that testDir (original directory) is created and that testFile is inside it.

**Expected Result:**
- File is moved to ~/.recycle_bin/files/
- Success deletion message is displayed
- Original directory is created
- File is moved to original directory
- Metadata entry is erased
- Success restore message is displayed
- File does not appear in list output

**Actual Result:** 
- Success deletion message is displayed: "File moved as: "
- File is moved to original directory
- Metadata entry is erased
- File does not appear in list output

**Status:** ✅ Pass

**Screenshots:** 
- Success message displayed:
![Success message](screenshots/testcase4_restore_message.png)

- Metadata file has no entries: 
![Metadata file entries](screenshots/testcase4_metadata_entries.png)

- List output: 
![List output](screenshots/testcase4_list_output.png)

### Test Case 9: TODO (Empty Entire Recycle Bin)

### Test Case 10: Search Existing File
**Objective:** Verify that a search for an existing file can be done successfully

**Pre-condition:** File must already exist in recycle bin (follow Test Case 2: Delete Single File).

**Steps:**
1. Run: `./recycle_bin.sh search testFile`
2. Verify that file information is displayed

**Expected Result:**
- File information is displayed

**Actual Result:** 
- File information is displayed, including file id, original name, original path, deletion date, size, type, permissions and owner.

**Status:** ✅ Pass

**Screenshots:** 
- File informations: 
![File informations](screenshots/testcase10_file_informations.png)

### Test Case 11: Search Non-Existent File
**Objective:** Verify that a search for a non-existent file can not be performed

**Steps:**
1. Run: `./recycle_bin.sh search nonExistentFile`
2. Verify that an error message is displayed

**Expected Result:**
- Error message is displayed

**Actual Result:** 
- Error message is displayed: "Error: No file with 'nonExistentFile' pattern was found."

**Status:** ✅ Pass

**Screenshots:** 
- Error message: 
![Error message](screenshots/testcase11_error_message.png)

### Test Case 12: Display Help Information (Vai faltar print, falta completar a função)
**Objective:** Verify that help information is displayed successfully

**Steps:**
1. Run: `./recycle_bin.sh help` or `./recycle_bin.sh --help` or `./recycle_bin.sh -h`
2. Verify that help message is displayed

**Expected Result:**
- Help message is displayed

**Actual Result:** 
- Help message displays information regarding every executable option of the program

**Status:** ✅ Pass

**Screenshots:** FALTA ISTO
- Help message: 
![Help message](screenshots/testcase11_error_message.png)

## Edge Cases

### Test Case 13: Delete Non-Existent File
**Objective:** Verify that it is not possible to delete a non-existent file

**Steps:**
1. Run: `./recycle_bin.sh delete nonExistentFile`
2. Verify that an error message is displayed

**Expected Result:**
- Error message is displayed

**Actual Result:** 
- Error message is displayed: "Error: File 'nonExistentFile' does not exist"

**Status:** ✅ Pass

**Screenshots:** 
- Error message: 
![Error message](screenshots/testcase13_error_message.png)

### Test Case 14: Delete File Without Permissions (TODO) -> EU 

### Test Case 15: Restore when Original Location has same Filename (TODO) -> EU

### Test Case 16: Restore with Non-Existent File Id (TODO) -> EU 

### Test Case 17: Handle Filenames with Spaces (TODO) -> EU 

### Test Case 18: Handle Filenames with Special Characters (TODO) -> EU 

### Test Case 19: Handle Very Long Filenames (TODO)

### Test Case 20: Handle Very Large Files (TODO) -> EU 

### Test Case 21: Handle Symbolical Links (TODO) -> EU 

### Test Case 22: Handle Hidden Files (TODO) -> EU 

### Test Case 23: Delete Files from Different Directories (TODO) -> EU

### Test Case 24: Restore Files to Read-Only Directories (TODO) -> EU 

## Error Handling

### Test Case 25: Invalid Command Line Arguments

### Test Case 26: Missing Required Parameters

### Test Case 27: Corrupted Metadata File

### Test Case 28: Insufficient Disk Space

### Test Case 29: Permission Denied Errors

### Test Case 30: Attempting to Delete Recycle Bin Itself

### Test Case 31: Concurrent Operations

## Performance Tests

### Test Case 32: Delete 100+ Files

### Test Case 33: List Recycle Bin with 100+ Files

### Test Case 34: Search in Large Metadata File

### Test Case 35: Restore from Recycle Bin with Many Items

## Optional Features Tests

### TODO 
