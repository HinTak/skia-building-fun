#!/bin/bash

# Copyright 2023 Hin-Tak Leung

# currently only works for "m87", "m88", "m98", "m103" and "m116" onwards.

ARG1=${1}

VER=${ARG1:-m116}

# Shallow clones to avoid a 600MB+ download.
git clone -b chrome/${VER} --depth 1 git@github.com:google/skia.git skia-${VER}

pushd skia-${VER}/

    # Stop uninteresting downloads, and disable emsdk
    patch -p1 < ../patches/skia-${VER}-minimize-download.diff

    # https://bugs.chromium.org/p/skia/issues/detail?id=14636
    # https://issues.skia.org/issues/40045538
    patch -p1 < ../patches/skia-${VER}-modules-symbols-svg.diff

    # This is a non-standard patch which adds one new
    # method, and make another protected method public.
    # It could have been be a bit shorter, except enum
    # typedef's cannot be forward-declared.
    patch -p1 < ../patches/skia-${VER}-colrv1-freetype.diff

    # Older versions of skia need small code fixes.
    [ -f ../patches/skia-${VER}-c++-code.diff ] && patch -p1 < ../patches/skia-${VER}-c++-code.diff

    # Official build process from here:
    python tools/git-sync-deps

    # is_official_build=true:     - Non-debug and use as many system libraries as appropriate.
    # is_component_build=true:    build shared libraries
    # skia_enable_svg=true:       want the svg module - first available in m91
    # - full-path clang/clang++   to avoid ccache
    bin/gn gen out/Shared --args='is_official_build=true is_component_build=true skia_enable_svg=true cc="/usr/bin/clang" cxx="/usr/bin/clang++"'

    # Static build presumably will be used for skia-python, which needs -frtti
    bin/gn gen out/Release --args='is_official_build=true skia_enable_svg=true cc="/usr/bin/clang" cxx="/usr/bin/clang++" extra_cflags_cc=["-frtti"]'

    # time the build, keep the log
    /usr/bin/time -v ninja -C out/Shared/ 2>&1 | tee -a ../skia-${VER}-build-log-shared
    /usr/bin/time -v ninja -C out/Release/ 2>&1 | tee -a ../skia-${VER}-build-log-release

    # zip up the interesting part of outcome.
    find out/Shared/ -type f -name '*.a' -or -name '*.so' -or -type f -executable >  ../skia-${VER}-bin-file-list
    find include/ src/ modules/ -type f -name '*.h'       >> ../skia-${VER}-bin-file-list

    cat ../skia-${VER}-bin-file-list | zip -@ ../skia-${VER}-bin.zip

    # skia-python needs the resources/ for testing.
    find out/Release/ -type f -name '*.a' -or -name '*.so' -or -type f -executable >  ../skia-${VER}-bin-file-list-static
    find include/ src/ modules/ -type f -name '*.h'       >> ../skia-${VER}-bin-file-list-static
    find resources/ -type f >> ../skia-${VER}-bin-file-list-static

    cat ../skia-${VER}-bin-file-list-static | zip -@ ../skia-${VER}-static-bin.zip

    # Keep the final combined diff as a record.
    git diff > ../skia-${VER}-final-total.diff
    git describe --always >> ../skia-${VER}-final-total.diff
popd
rm -rf skia-${VER}/
