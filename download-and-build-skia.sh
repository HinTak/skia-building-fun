#!/bin/bash

# Copyright 2023 Hin-Tak Leung

# currently only works for "m116"!

VER=${1}

# Shallow clones to avoid a 600MB+ download.
git clone -b chrome/${VER} --depth 1 git@github.com:google/skia.git skia-${VER}

pushd skia-${VER}/

    # Stop uninteresting downloads, and disable emsdk
    patch -p1 < ../patches/skia-${VER}-minimize-download.diff

    # https://bugs.chromium.org/p/skia/issues/detail?id=14636
    patch -p1 < ../patches/skia-${VER}-modules-symbols-svg.diff

    # Official build process from here:
    python tools/git-sync-deps

    # is_component_build=true:    build shared libraries
    # skia_enable_svg=true:       want the svg module
    # - full-path clang/clang++   to avoid ccache
    bin/gn gen out/Shared --args='is_official_build=true is_component_build=true skia_enable_svg=true cc="/usr/bin/clang" cxx="/usr/bin/clang++"'

    # time the build, keep the log
    /usr/bin/time -v ninja -C out/Shared/ 2>&1 | tee ../skia-${VER}-build-log-shared

    # zip up the interesting part of outcome.
    find out/Shared/ -type f -name '*.a' -or -name '*.so' >  ../skia-${VER}-bin-file-list
    find include/ src/ modules/ -type f -name '*.h'       >> ../skia-${VER}-bin-file-list

    cat ../skia-${VER}-bin-file-list | zip -@ ../skia-${VER}-bin.zip

popd
rm -rf skia-${VER}/
