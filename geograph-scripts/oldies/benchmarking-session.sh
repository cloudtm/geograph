. ./benchmarking-functions.sh

spawn_vms 2
run_benchmark "read-intensive.2m" "write-100k-posts" "read_only"
destroy_all_vms 

spawn_vms 4
run_benchmark "read-intensive.4m" "write-100k-posts" "read_only"
destroy_all_vms
