
function spawn_vms {
    echo "Spawning VMs: $1"
}

function run_benchmark {
    DESC=$1
    shift
    echo "Running benchmark '$DESC':"
    echo "$*"
}

function destroy_all_vms {
    echo "Destroying all VMs"
}
