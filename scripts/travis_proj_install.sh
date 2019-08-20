#!/bin/sh
set -e

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

# Create build dir if not exists
if [ ! -d "$PROJBUILD" ]; then
    mkdir $PROJBUILD;
fi

if [ ! -d "$GDALINST" ]; then
    mkdir $GDALINST;
fi


echo "PROJ VERSION: $PROJVERSION FORCE_GDAL_BUILD: $FORCE_GDAL_BUILD" 

GDAL_DEB_PATH="gdal_${GDALVERSION}_proj_${PROJVERSION}_${DISTRIB_CODENAME}.deb"
if ( curl -o/dev/null -sfI "https://rbuffat.github.io/gdal_builder/$GDAL_DEB_PATH" ) && [ $FORCE_GDAL_BUILD!="yes" ]; then
#     We do nothing if deb is available
    echo "deb available, skip installation of proj"

else

# Otherwise we compile proj from source

    if [ ! -d "$PROJINST/gdal-$GDALVERSION/share/proj" ] || [ $FORCE_GDAL_BUILD="yes" ]; then
        cd $PROJBUILD

        wget -q http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
        tar -xzf proj-$PROJVERSION.tar.gz
        cd proj-$PROJVERSION
        ./configure --prefix=$GDALINST/gdal-$GDALVERSION
        make -j 2
        make install
        rm -rf $PROJBUILD
    fi

fi

# change back to travis build dir
cd $TRAVIS_BUILD_DIR
