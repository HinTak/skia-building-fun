# How to build Skia m116+ with ~80MB download and ~300MB disk space!

## Building Skia on a shoe-string budget

The official procedure for building Skia tries to download ~3.5 GB and spats 7.1 GB+ onto your
hard disk before even compiling the first source file. This is a script plus a patch set to
do it with ~80MB download and ~300MB disk space usage, without compromising on any functionality.

It takes about 40 minutes on dual-cores, or about 70 minutes on single CPU. Works for m116 and Linux
only.

Skia is facinating in both a bad and good way. The official build procedure does a 900MB clone,
then fetch 1.6GB swiftshader (Mac OS X only), 1GB icu (available on Linux), 400MB angle2
(used only for windows builds); that's 5.3GB of thirdparty stuff in total. Then it goes and
fetch another 400 MB via `emsdk activate` and dump 1.1GB on the hard disk. That's only useful for
building skia for WebAassembly. So it eats up 900MB + 5.3GB + 1.1GB ~ 7.3GB before
you even start to build a single line.

If you do shallow clone, only care about linux, and use system libraries as appropriate, you
can cut the 7.1GB disk usage down to about 270MB. And the network usage from
600MB + ~3.0GB + 400MB ~ 4.0GB to about 80MB download.

Here is the script. You run it like this, with the milestone as argument (only m116 is supported at
the moment!):

```
./download-and-build-skia.sh m116
```

It takes about 40 minutes on dual-cores and 300MG disk space in total. Generates three files,
`skia-m116-build-log-shared`, `skia-m116-bin-file-list`, `skia-m116-bin.zip`.

This bundle is used in building the Skia-enabled FreeType2-demos
( https://github.com/HinTak/harfbuzz-python-demos/tree/master/skia-adventure/ ), which
reads OT-SVG fonts in 4 different ways, as well as the new COLRv1 font format.
