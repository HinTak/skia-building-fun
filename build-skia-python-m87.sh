#!/bin/bash

# Copyright 2025 Hin-Tak Leung

git clone -b m87 --depth 1 https://github.com/kyamagu/skia-python.git skia-python

pushd skia-python
    patch -p1 < ../patches/m87-separate-lib.diff
    pushd skia
        unzip ../../skia-m87-static-bin.zip
    popd
    python -m build --wheel
    python -m pip install dist/*.whl
    pytest
popd

ls -l skia-python/dist/*.whl

[ -f skia-python/dist/*.whl ]
