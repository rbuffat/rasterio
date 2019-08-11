#!/bin/bash
#
# originally contributed by @rbuffat to Toblerity/Fiona
set -e

# TODO debug
rm -rf $GDALBUILD
rm -rf $GDALINST

GDALOPTS="  --with-ogr \
            --with-geos \
            --with-expat \
            --without-libtool \
            --with-libz=internal \
            --with-libtiff=internal \
            --with-geotiff=internal \
            --without-gif \
            --without-pg \
            --without-grass \
            --without-libgrass \
            --without-cfitsio \
            --without-pcraster \
            --with-netcdf \
            --with-png=internal \
            --with-jpeg=internal \
            --without-gif \
            --without-ogdi \
            --without-fme \
            --without-hdf4 \
            --with-hdf5 \
            --without-jasper \
            --without-ecw \
            --without-kakadu \
            --without-mrsid \
            --without-jp2mrsid \
            --without-bsb \
            --without-grib \
            --without-mysql \
            --without-ingres \
            --without-xerces \
            --without-odbc \
            --with-curl \
            --with-sqlite3 \
            --without-dwgdirect \
            --without-idb \
            --without-sde \
            --without-perl \
            --without-php \
            --without-ruby \
            --without-python
            --with-oci=no \
            --without-mrf \
            --with-webp=no"

# Create build dir if not exists
if [ ! -d "$GDALBUILD" ]; then
  mkdir $GDALBUILD;
fi

if [ ! -d "$GDALINST" ]; then
  mkdir $GDALINST;
fi

ls -l $GDALINST

# GDAL_DEB_PATH="gdal_${GDALVERSION}_proj_${PROJVERSION}-1_amd64_${DISTRIB_CODENAME}.deb"
# if ( curl -o/dev/null -sfI "https://rbuffat.github.io/gdal_builder/$GDAL_DEB_PATH" ); then
#   install deb when available
#   
#   wget "https://rbuffat.github.io/gdal_builder/$GDAL_DEB_PATH"
#   sudo dpkg -i "$GDAL_DEB_PATH"
if [ "$GDALVERSION" = "master" ]; then
    PROJOPT="--with-proj=$PROJINST/proj-$PROJVERSION"
    cd $GDALBUILD
    git clone --depth 1 https://github.com/OSGeo/gdal gdal-$GDALVERSION
    cd gdal-$GDALVERSION/gdal
    git rev-parse HEAD > newrev.txt
    BUILD=no
    # Only build if nothing cached or if the GDAL revision changed
    if test ! -f $GDALINST/gdal-$GDALVERSION/rev.txt; then
        BUILD=yes
    elif ! diff newrev.txt $GDALINST/gdal-$GDALVERSION/rev.txt >/dev/null; then
        BUILD=yes
    fi
    if test "$BUILD" = "yes"; then
        mkdir -p $GDALINST/gdal-$GDALVERSION
        cp newrev.txt $GDALINST/gdal-$GDALVERSION/rev.txt
        ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $PROJOPT
        make -s -j 2
        make install
    fi

else
    case "$GDALVERSION" in
        3*)
            PROJOPT="--with-proj=$PROJINST/proj-$PROJVERSION"
            ;;
        2.4*)
            PROJOPT="--with-proj=$PROJINST/proj-$PROJVERSION"
            ;;
        2.3*)
            PROJOPT="--with-proj=$PROJINST/proj-$PROJVERSION"
            ;;
        2.2*)
            PROJOPT="--with-static-proj4=$PROJINST/proj-$PROJVERSION"
            ;;
        2.1*)
            PROJOPT="--with-static-proj4=$PROJINST/proj-$PROJVERSION"
            ;;
        2.0*)
            PROJOPT="--with-static-proj4=$PROJINST/proj-$PROJVERSION"
            ;;
        1*)
            PROJOPT="--with-static-proj4=$PROJINST/proj-$PROJVERSION"
            ;;
    esac

    if [ ! -d "$GDALINST/gdal-$GDALVERSION/share/gdal" ]; then
        cd $GDALBUILD
        gdalver=$(expr "$GDALVERSION" : '\([0-9]*.[0-9]*.[0-9]*\)')
        wget -q http://download.osgeo.org/gdal/$gdalver/gdal-$GDALVERSION.tar.gz
        tar -xzf gdal-$GDALVERSION.tar.gz
        cd gdal-$gdalver
        
        echo $GDALOPTS
        echo $PROJOPT
        
        ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $PROJOPT
        make -s -j 2
        make install
    fi
fi

# change back to travis build dir
cd $TRAVIS_BUILD_DIR
