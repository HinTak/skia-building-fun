#!/bin/bash

git clone --mirror --no-single-branch --depth 1 git@github.com:google/skia.git
pushd skia.git
#
# m87 Branch point:
#
#     commit a0c82f08df58dcd0e1d143db9ccab38f8d823b95
#     Author: Brian Osman <brianosman@google.com>
#     Date:   Thu Oct 1 08:56:53 2020 -0400
#
# 'Thu Oct 1 00:00:00 2020 +0000' includes 3 more autoroll commits.
#
    git fetch --update-shallow --shallow-since='Thu Oct 1 00:00:00 2020 +0000'
    git branch | grep chrome/m1 | xargs -n 1 git fetch --update-shallow --shallow-since='Thu Oct 1 00:00:00 2020 +0000' origin
    git branch | grep chrome/m9 | xargs -n 1 git fetch --update-shallow --shallow-since='Thu Oct 1 00:00:00 2020 +0000' origin
    git branch | grep 'chrome/m8[789]' | xargs -n 1 git fetch --update-shallow --shallow-since='Thu Oct 1 00:00:00 2020 +0000' origin
popd
