![Status](https://github.com/NOAA-EMC/NCEPLIBS-sp/workflows/Build%20and%20Test/badge.svg)

# BACIO

This library performs binary I/O for the NCEP models, processing
unformatted byte-addressable data records, and transforming the little
endian files and big endian files.

This is part of the [NCEPLIBS](https://github.com/NOAA-EMC/NCEPLIBS)
project.

For more detailed documentation see
https://noaa-emc.github.io/NCEPLIBS-bacio/.

### Users

The NCEPLIBS-bacio library is used by:
* [NCEPLIBS-g2](https://github.com/NOAA-EMC/NCEPLIBS-g2)
* [NCEPLIBS-grib_util](https://github.com/NOAA-EMC/NCEPLIBS-grib_util)
* [UFS_UTILS](https://github.com/NOAA-EMC/UFS_UTILS)
* [UPP](https://github.com/NOAA-EMC/UPP)
* [ufs-weather-model](https://github.com/ufs-community/ufs-weather-model)
* [UFS Short-Range Weather Application](https://github.com/ufs-community/ufs-srweather-app)

### Authors

Robert Grumbine, Mark Iredell, Jun Wang, Dexin Zhang, other NCEP/EMC
Developers

Code Manager: Hang Lei, Ed Hartnett

### Installing

```
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/path/to/install ..
make -j2
make install
```

## Disclaimer

The United States Department of Commerce (DOC) GitHub project code is
provided on an "as is" basis and the user assumes responsibility for
its use. DOC has relinquished control of the information and no longer
has responsibility to protect the integrity, confidentiality, or
availability of the information. Any claims against the Department of
Commerce stemming from the use of its GitHub project will be governed
by all applicable Federal law. Any reference to specific commercial
products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by the Department of
Commerce. The Department of Commerce seal and logo, or the seal and
logo of a DOC bureau, shall not be used in any manner to imply
endorsement of any commercial product or activity by DOC or the United
States Government.
