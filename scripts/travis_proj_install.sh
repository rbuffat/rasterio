#!/bin/sh
set -e

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

# TODO debug
rm -rf $PROJBUILD
rm -rf $PROJINST

# Create build dir if not exists
if [ ! -d "$PROJBUILD" ]; then
    mkdir $PROJBUILD;
fi

if [ ! -d "$PROJINST" ]; then
    mkdir $PROJINST;
fi

ls -l $PROJINST

echo "PROJ VERSION: $PROJVERSION"

PROJ_DEB_PATH="proj_${PROJVERSION}-1_amd64_${DISTRIB_CODENAME}.deb"
if ( curl -o/dev/null -sfI "https://rbuffat.github.io/gdal_builder/$PROJ_DEB_PATH" ); then
    We install proj deb if available

    wget "https://rbuffat.github.io/gdal_builder/$PROJ_DEB_PATH"
    sudo dpkg -i "$PROJ_DEB_PATH"

else
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

# fi

ls -l $PROJINST

# change back to travis build dir
cd $TRAVIS_BUILD_DIR
