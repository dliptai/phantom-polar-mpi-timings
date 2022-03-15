#!/usr/bin/env bash

set -eu
source ./loop.sh
source ./modules

PHANTOM_DIR=/home/dliptai/repos/phantom
$PHANTOM_DIR/scripts/writemake.sh disc > Makefile
make SYSTEM=gfortran MPI=yes

rm -f ./job.names

function generate_run(){
  local nodes=$1
  local ntasks_per_node=$2
  local cpus_pertask=$3
  local ntasks=$((ntasks_per_node*nodes))
  local id="${nodes}x${ntasks_per_node}x${cpus_pertask}"
  local jobname="${id}${TAG:-}${SBATCH_PARTITION:-}"

  echo $jobname >> job.names

  local d="run-${id}"
  local qscript="run-${id}.q"

  mkdir -p $d
  cp polar_00000 $d/.
  cp polar.in $d/.
  cp phantom $d/.

  # WRITE qscript
  cat <<-EOF > "$d/$qscript"
#!/bin/bash
#SBATCH --nodes=${nodes}
#SBATCH --ntasks-per-node=${ntasks_per_node}
#SBATCH --cpus-per-task=${cpus_pertask}
#SBATCH --job-name=${jobname}
#SBATCH --output=polar.in.qout
#SBATCH --time=0-0:10:00
#SBATCH --mem=16G
#SBATCH --account=oz999
echo "HOSTNAME = \$HOSTNAME"
echo "HOSTTYPE = \$HOSTTYPE"
echo Time is \`date\`
echo Directory is \`pwd\`

ulimit -s unlimited
export OMP_SCHEDULE="dynamic"
export OMP_NUM_THREADS=\$SLURM_CPUS_PER_TASK
export OMP_STACKSIZE=1024m

ml gni/2020.0

echo "starting phantom run..."
export outfile=\`grep logfile "polar.in" | sed "s/logfile =//g" | sed "s/\\\!.*//g" | sed "s/\s//g"\`
echo "writing output to \$outfile"
srun ./phantom polar.in >& \$outfile
EOF

  # SUBMIT job
  echo "Submitting $d"
  cd $d; sbatch $qscript; cd -

}

loop generate_run
