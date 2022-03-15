# Phantom timings
Template directory containing scripts for generating a suite of phantom-MPI timings on OzSTAR, using the `polar` benchmark test.

```
cp -R phantom-polar-mpi-timings/template_dir polar128
cd polar128
TAG=tag ./generate.sh
```

Submits all full-node combinations of MPI and OMP jobs, up to max 4 nodes. (Edit loop.sh to increase/decrease this). Job names are output to `job.names`. You can quickly cancel all the jobs with `./cancel.sh`.

Once all the jobs finish, collect the timing results:
```
./collect.sh
```

And make the plots
```
./make plots.sh
```
