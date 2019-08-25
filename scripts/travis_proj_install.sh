#!/bin/sh
set -e

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

# Create build dir if not exists
if [ ! -d "$PROJBUILD" ]; then
    mkdir $PROJBUILD;
fi

if [ ! -d "$PROJINST" ]; then
    mkdir $PROJINST;
fi

echo "PROJ VERSION: $PROJVERSION FORCE_GDAL_BUILD: $FORCE_GDAL_BUILD" 

PROJ_DEB_NAME="proj_${PROJVERSION}-1_amd64_${DISTRIB_CODENAME}.deb"
PROJ_DEB_URL="https://rbuffat.github.io/gdal_builder/$PROJ_DEB_NAME"

echo "$PROJ_DEB_URL"

if ( curl -o/dev/null -sfI "$PROJ_DEB_URL" ) && [ "$FORCE_GDAL_BUILD" != "yes" ]; then

    # We install proj deb if available
    wget "$PROJ_DEB_URL"
    sudo dpkg -i "$PROJ_DEB_NAME"
    sudo chown -R travis:travis $PROJINST

# Otherwise we compile proj from source

    if [ ! -d "$PROJINST/proj-$PROJVERSION" ]; then
        cd $PROJBUILD

        wget -q http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
        tar -xzf proj-$PROJVERSION.tar.gz
        cd proj-$PROJVERSION
        ./configure --prefix=$PROJINST/proj-$PROJVERSION
        make -j 2
        make install
        rm -rf $PROJBUILD
    fi

fi

find $PROJINST

# change back to travis build dir
cd $TRAVIS_BUILD_DIR
