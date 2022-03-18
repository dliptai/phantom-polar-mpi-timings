#!/usr/bin/env bash

# Defaults
weak_scaling=0
setup="polar"

while [[ "$1" == --* ]]; do
  case "$1" in
    --weak)
      weak_scaling=1;
      ;;

   --setup)
      shift
      setup="$1"
      break;
      ;;

    *)
      badflag="$1"
      ;;
  esac
  shift
done

if [[ "$badflag" != "" ]]; then
   echo "ERROR: Unknown flag $badflag"
   exit
fi

set -eu
source ./loop.sh
source ./modules

if [ "$setup" == "polar" ]; then
  SETUP=disc
  STARTDUMP=polar_00000
  INFILE=polar.in
elif [ "$setup" == "passy" ]; then
  SETUP=star
  STARTDUMP=Passy700k_14222
  INFILE=Passy700k.in
else
  echo "ERROR: No setup for ${setup}"
  exit 1
fi

PHANTOM_DIR=/home/dliptai/repos/phantom
"$PHANTOM_DIR/scripts/writemake.sh" "$SETUP" > Makefile
make SYSTEM=gfortran MPI=yes MAXP=16000000 phantom phantomsetup

rm -f ./job.names

function generate_run() {
  local nodes="$1"
  local ntasks_per_node="$2"
  local cpus_pertask="$3"
  local ntasks=$((ntasks_per_node*nodes))
  local id="${nodes}x${ntasks_per_node}x${cpus_pertask}"
  local jobname="${id}${TAG:-}${SBATCH_PARTITION:-}"

  echo "$jobname" >> job.names

  local d="run-${id}"
  local qscript="run-${id}.q"

  mkdir -p "$d"
  cp phantom "$d/."

  if [[ "$weak_scaling" == 1 ]]; then
    source ./setups.sh
    cp phantomsetup "$d/."
    cd "$d"
    write_setup "${setup}" "$nodes" > "${setup}.setup" || ( echo "Could not write .setup for ${setup}"; rm -f "${setup}.setup"; exit 1 )
    echo "Running phantomsetup for $d"
    ./phantomsetup "${setup}" > /dev/null
    rm "${setup}.in"
    cd - > /dev/null
    cp "${INFILE}" "$d/."
    sed -i "s/${STARTDUMP}/${setup}_00000\.tmp/g" "$d/${INFILE}"
  else
    cp "${STARTDUMP}" "$d/."
    cp "${INFILE}" "$d/."
  fi

  # WRITE qscript
  cat <<-EOF > "$d/$qscript"
#!/bin/bash
#SBATCH --nodes=${nodes}
#SBATCH --ntasks-per-node=${ntasks_per_node}
#SBATCH --cpus-per-task=${cpus_pertask}
#SBATCH --job-name=${jobname}
#SBATCH --output=${INFILE}.qout
#SBATCH --time=0-0:10:00
#SBATCH --mem=180G
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
export outfile=\`grep logfile "${INFILE}" | sed "s/logfile =//g" | sed "s/\\\!.*//g" | sed "s/\s//g"\`
echo "writing output to \$outfile"
srun ./phantom ${INFILE} >& \$outfile
EOF

  # SUBMIT job
  echo "Submitting $d"
  cd "$d"; sbatch "$qscript"; cd - > /dev/null

}

loop generate_run
