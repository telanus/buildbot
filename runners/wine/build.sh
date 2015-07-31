#!/bin/bash

set -e

sudo apt-get install -y flex bison libfreetype6-dev \
                        libpulse-dev libattr1-dev libtxc-dxtn-dev \
                        libva-dev libva-drm1


root_dir=$(pwd)
source_dir="${root_dir}/wine-src"
build_dir="${root_dir}/wine"
version="1.7.48"
arch=$(uname -m)

dest_dir="${version}-${arch}"

if [ -d ${source_dir} ]; then
    cd ${source_dir}
    git checkout master
    git pull
else
    git clone git://source.winehq.org/git/wine.git $source_dir
    cd $source_dir
fi
git checkout wine-${version}

if [ $STAGING ]; then
    wget https://github.com/wine-compholio/wine-staging/archive/v${version}.tar.gz
    tar xvzf v${version}.tar.gz --strip-components 1
    ./patches/patchinstall.sh DESTDIR="$(pwd)" --all
    configure_opts="--with-xattr"
fi

mkdir -p $build_dir
cd $build_dir
$source_dir/configure ${configure_opts} --prefix=${root_dir}/${dest_dir}
make -j4
make install

cd ${root_dir}
find . -type f -exec strip {} \;
tar cvzf wine-${version}-${arch}.tar.gz ${dest_dir}
rm -rf ${build_dir} ${source_dir}
