function ispowerof2() {
  local number=$1
  local result remainder divisible
  while true; do
    if ((number==2)); then
      divisible=true
      break
    fi
    result=$((number/2))
    remainder=$((number%2))
    if ((result==1)) || ((number==0)) || ((remainder!=0)); then
      divisible=false
      break
    fi
    if ((result==2)); then
      divisible=true
      break
    fi
    number=$result
  done

  echo $divisible

}

function loop() {
  local max_nodes=16
  local max_cpus_per_node=32
  local func=$1

  for nodes in $(seq $max_nodes); do
    for ntasks_per_node in $(seq $max_cpus_per_node); do
      for cpus_per_task in $(seq $max_cpus_per_node); do
        N=$((ntasks_per_node*cpus_per_task))
        ntasks=$((nodes*ntasks_per_node))
        if ((N!=max_cpus_per_node)); then
          continue
        elif ((ntasks>1)) && [ $(ispowerof2 $ntasks) != true ]; then
          continue
        else
          $func $nodes $ntasks_per_node $cpus_per_task
        fi
      done
    done
  done
}
