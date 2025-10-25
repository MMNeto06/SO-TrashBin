#!/bin/bash
#NOTE: run this file with SO-TrashBin as pwd (or whatver directory recycle_bin.sh is in)
cd ./testingMdScripts
recycle_bin_script="../recycle_bin.sh"
test_dir="../.testdir"

mkdir $test_dir

for i in {1..100}; do
    touch "$test_dir/file_$i"
    echo "This is file number $i" >> "$test_dir/file_$i"
done

echo "All files created, starting time"
echo ""
start=$(date +%s.%N)
for i in {1..100}; do
    $recycle_bin_script "delete" "$test_dir/file_$i"
done;
end=$(date +%s.%N)
elapsed_time=$(echo $end - $start | bc)
echo "Time to delete files: $elapsed_time s"
echo ""

echo "Starting time for listing bin"
start=$(date +%s.%N)
$recycle_bin_script "list"
end=$(date +%s.%N)
elapsed_time=$(echo $end - $start | bc)
echo "Time to list recycle bin: $elapsed_time s"
echo ""

echo "Starting time for search command" #We will be searching for all files with a 0 in its name
start=$(date +%s.%N)
$recycle_bin_script "search" "1"
end=$(date +%s.%N)
elapsed_time=$(echo $end - $start | bc)
echo "Time to search recycle bin: $elapsed_time s"
echo ""

echo "Starting time to restore command" #We will be restoring the last file, aka file_100
start=$(date +%s.%N)
$recycle_bin_script "restore" "file_100"
end=$(date +%s.%N)
elapsed_time=$(echo $end - $start | bc)
echo "Time to restore file_100: $elapsed_time s"
echo ""

$recycle_bin_script "empty" "--force"
rm -r $test_dir
echo "All auxilliary files deleted"