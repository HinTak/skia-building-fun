#!/bin/bash

git clone --mirror --no-single-branch --depth 1 git@github.com:google/skia.git
pushd skia.git
#
# m70 Branch point:
#
#     commit 7ed0eae0cd13d3d687f7855b0620a0faad2ab5b3
#     Author: Brian Osman <brianosman@google.com>
#     Date:   Thu Aug 30 13:46:36 2018 +0000
#
#         Revert "Remove lazy image color space hacks for gray"
#
# 'Thu Aug 30 00:00:00 2018 -0000' includes a few more commits.
#
    # git fetch --all # seen to do a lot of fetch
    git fetch --update-shallow --shallow-since='Thu Aug 30 00:00:00 2018 -0000' origin main
    git branch | grep chrome/m1 | xargs -n 1 git fetch --update-shallow --shallow-since='Thu Aug 30 00:00:00 2018 -0000' origin
    git branch | grep 'chrome/m[789]' | xargs -n 1 git fetch --update-shallow --shallow-since='Thu Aug 30 00:00:00 2018 -0000' origin
    git gc
popd
