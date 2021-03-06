function write_setup() {
  local setup="$1"
  local nodes="$2"

  if [ "$setup" == "polar" ]; then
    write_polar_setup "$nodes"
  else
    # echo "No setup function for $setup"
    return 1
  fi
}

function write_polar_setup() {
  local nodes="$1"
  local np=$((nodes*1000000))
  cat << EOF
# input file for disc setup routine

# resolution
                  np =     ${np}    ! number of gas particles

# units
           dist_unit =          au    ! distance unit (e.g. au,pc,kpc,0.1pc)
           mass_unit =      solarm    ! mass unit (e.g. solarm,jupiterm,earthm)

# central object(s)/potential
            icentral =           1    ! use sink particles or external potential (0=potential,1=sinks)
              nsinks =           2    ! number of sinks
             ibinary =           0    ! binary orbit (0=bound,1=unbound [flyby])

# options for binary
                  m1 =       1.000    ! primary mass
                  m2 =       0.200    ! secondary mass
            binary_a =         10.    ! binary semi-major axis
            binary_e =       0.000    ! binary eccentricity
            binary_i =         45.    ! i, inclination (deg)
            binary_O =       0.000    ! Omega, PA of ascending node (deg)
            binary_w =        270.    ! w, argument of periapsis (deg)
            binary_f =        180.    ! f, initial true anomaly (deg,180=apastron)
               accr1 =       1.000    ! primary accretion radius
               accr2 =       0.500    ! secondary accretion radius

# options for multiple discs
      use_binarydisc =           T    ! setup circumbinary disc
     use_primarydisc =           F    ! setup circumprimary disc
   use_secondarydisc =           F    ! setup circumsecondary disc
      use_global_iso =           F    ! globally isothermal or Farris et al. (2014)

# options for circumbinary gas disc
       isetgasbinary =           0    ! how to set gas density profile (0=total disc mass,1=mass within annulus,2=surface density normalisation,3=surface density at reference radius,4=minimum Toomre Q)
     itapergasbinary =           F    ! exponentially taper the outer disc profile
    ismoothgasbinary =           F    ! smooth inner disc
         iwarpbinary =           F    ! warp disc
          R_inbinary =         25.    ! inner radius
         R_refbinary =         25.    ! reference radius
         R_outbinary =        125.    ! outer radius
        disc_mbinary =       0.050    ! disc mass
        pindexbinary =       1.000    ! p index
        qindexbinary =       0.250    ! q index
       posanglbinary =       0.000    ! position angle (deg)
          inclbinary =        135.    ! inclination (deg)
           H_Rbinary =       0.050    ! H/R at R=R_ref
             alphaSS =       0.005    ! desired alphaSS

# set planets
          setplanets =           0    ! add planets? (0=no,1=yes)

# thermal stratification
           discstrat =           0    ! stratify disc? (0=no,1=yes)

# timestepping
             norbits =         100    ! maximum number of binary orbits
              deltat =       0.100    ! output interval as fraction of orbital period

EOF
}
