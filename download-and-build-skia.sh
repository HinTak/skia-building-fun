#!/bin/bash

# Copyright 2023 Hin-Tak Leung

# currently only works for "m87", "m88", "m98", "m103" and "m116" onwards.

ARG1=${1}

VER=${ARG1:-m136}

# Shallow clones to avoid a 600MB+ download.
git clone -b chrome/${VER} --depth 1 https://github.com/google/skia.git skia-${VER}

pushd skia-${VER}/

    # Stop uninteresting downloads, and disable emsdk
    patch -p1 < ../patches/skia-${VER}-minimize-download.diff

    # https://bugs.chromium.org/p/skia/issues/detail?id=14636
    # https://issues.skia.org/issues/40045538
    patch -p1 < ../patches/skia-${VER}-modules-symbols-svg.diff
    # https://issues.skia.org/358587937 skparagraph has no public symbols in component build
    # https://issues.skia.org/307357528 Skparagraph component build (DLL/.so/as a dynamic library) broken on windows
    patch -p1 < ../patches/skia-${VER}-modules-symbols-skparagraph.diff
    # https://issues.skia.org/358587938 sk_isdir is not public in skia's component build; required by skresources across component boundary
    patch -p1 < ../patches/skia-${VER}-symbols-for-skresources.diff

    patch -p1 < ../patches/skia-${VER}-egl-runtime.diff

    # This is a non-standard patch which adds one new
    # method, and make another protected method public.
    # It could have been be a bit shorter, except enum
    # typedef's cannot be forward-declared.
    patch -p1 < ../patches/skia-${VER}-colrv1-freetype.diff

    # Older versions of skia need small code fixes.
    [ -f ../patches/skia-${VER}-c++-code.diff ] && patch -p1 < ../patches/skia-${VER}-c++-code.diff

    if [ "${VER}" = 'm87' ]; then
        patch -p1 < ../patches/8d921a16f835aa6da69bac16f77ac0305e478954.patch
        patch -p1 < ../patches/ed435953dfd6e277549f07bb2fa977130f0e29fc.patch
        patch -p1 < ../patches/skia-m87-use-system-gn.diff
    fi

    # m125 icu breakage
    # https://issues.skia.org/338570715 skunicode module's recent 'Reland "Fix defines for icu_subset"' commit in m125 broke skia_use_system_icu=true usage
    [ -f ../patches/skia-${VER}-skunicode-breakage.diff ] && patch -p1 < ../patches/skia-${VER}-skunicode-breakage.diff

    #patch -p1 < ../patches/0001-Hook-up-SkSVGOpenTypeSVGDecoder-Make-to-enable-OT-SV.patch

    # Official build process from here:
    python tools/git-sync-deps
    if [ "${VER}" = 'm87' ]; then
        rm bin/gn
    fi

    # is_official_build=true:     - Non-debug and use as many system libraries as appropriate.
    # is_component_build=true:    build shared libraries
    # skia_enable_svg=true:       want the svg module - first available in m91
    # skia_enable_tools=true:     required for skia.h (m87)
    # - experimental_svg_model    (m87)
    # - full-path clang/clang++   to avoid ccache
    bin/gn gen out/Shared --args='is_official_build=true is_component_build=true skia_enable_svg=true skia_use_vulkan=true cc="/usr/bin/clang" cxx="/usr/bin/clang++"'

    # Static build presumably will be used for skia-python, which needs -frtti
    bin/gn gen out/Release --args='is_official_build=true skia_enable_svg=true skia_use_vulkan=true cc="/usr/bin/clang" cxx="/usr/bin/clang++" extra_cflags_cc=["-frtti"]'
    if [ "${VER}" = 'm87' ]; then
        gn gen out/Release --args='is_official_build=true skia_enable_tools=true cc="/usr/bin/clang" cxx="/usr/bin/clang++" extra_cflags_cc=["-frtti"]'
    fi
    bin/gn gen out/REGL --args='is_official_build=true skia_enable_svg=true skia_use_vulkan=true skia_use_egl=true cc="/usr/bin/clang" cxx="/usr/bin/clang++" extra_cflags_cc=["-frtti"]'

    # time the build, keep the log
    /usr/bin/time -v ninja -C out/Shared/ 2>&1 | tee -a ../skia-${VER}-build-log-shared
    /usr/bin/time -v ninja -C out/Release/ 2>&1 | tee -a ../skia-${VER}-build-log-release
    if [ "${VER}" = 'm87' ]; then
        /usr/bin/time -v ninja -C out/Release/ skia.h experimental_svg_model 2>&1 | tee -a ../skia-${VER}-build-log-release
    fi
    /usr/bin/time -v ninja -C out/REGL/ 2>&1 | tee -a ../skia-${VER}-build-log-release

    # zip up the interesting part of outcome.
    find out/Shared/ -type f -name '*.a' -or -name '*.so' -or -type f -executable >  ../skia-${VER}-bin-file-list
    find include/ src/ modules/ -type f -name '*.h'       >> ../skia-${VER}-bin-file-list

    cat ../skia-${VER}-bin-file-list | zip -@ ../skia-${VER}-bin.zip

    # skia-python needs the resources/ for testing.
    find out/Release/ -type f -name '*.a' -or -name '*.so' -or -type f -executable >  ../skia-${VER}-bin-file-list-static
    if [ "${VER}" = 'm87' ]; then
        find out/Release/obj/experimental/svg/ -type f  >>  ../skia-${VER}-bin-file-list-static
        find out/Release/gen/ -type f >>  ../skia-${VER}-bin-file-list-static
    fi
    find out/REGL/ -type f -name '*.a' -or -name '*.so' -or -type f -executable >>  ../skia-${VER}-bin-file-list-static
    find include/ src/ modules/ -type f -name '*.h'       >> ../skia-${VER}-bin-file-list-static
    if [ "${VER}" = 'm87' ]; then
        find experimental/svg/ -type f -name '*.h'       >> ../skia-${VER}-bin-file-list-static
    fi
    find resources/ -type f >> ../skia-${VER}-bin-file-list-static

    cat ../skia-${VER}-bin-file-list-static | zip -@ ../skia-${VER}-static-bin.zip

    # Keep the final combined diff as a record.
    git diff > ../skia-${VER}-final-total.diff
    git describe --always >> ../skia-${VER}-final-total.diff

    # Want to know what 3rd-party stuff is needed:
    cat ../skia-${VER}-build-log-shared  | grep third_part | grep compile | cut -f 3 -d ' ' | cut -f 1-5 -d / | sort | uniq -c
    cat ../skia-${VER}-build-log-release | grep third_part | grep compile | cut -f 3 -d ' ' | cut -f 1-5 -d / | sort | uniq -c

    # Show exit status, as "| tee ..." doesn't.
    grep 'Exit status' ../*-log-*
popd

if [ "${VER}" = 'm87' ]; then
    ./build-skia-python-m87.sh
fi

# Test for result for failures, since popd does not.
if [ "${VER}" = 'm87' ]; then
    [ -f skia-${VER}/out/Release/libskia.a ] && rm -rf skia-${VER}/ && [ -f skia-python/dist/*.whl ]
else
    [ -f skia-${VER}/out/Release/libskia.a ] && rm -rf skia-${VER}/
fi
