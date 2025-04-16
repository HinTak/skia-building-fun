# GN Versioning

Here is what `ninja` and `gn` reports, on Fedora 41:

```
$ ninja --version
1.12.1

$ gn --version
2221 (7a8aa3a08a13)
```

`gn`'s versioning is simply by 1 version per commit (the first commit is presumably version 0):

```
# in gn repo:
$ git log --format=oneline | tac | grep -n 7a8aa3a08a13
2222:7a8aa3a08a13521336853a28c46537ec04338a2d Remove deps from rust executable to module's pcm files
```

Skia's source code contains `bin/fetch-gn`, which has a hard-coded rev it tries to fetch:

```
# in skia repo:
$ git show chrome/m87:bin/fetch-gn | grep rev
  rev = '9e993e3da82a9f4bc5c50c190afbcffd61e3d9e0'
  url = 'https://chrome-infra-packages.appspot.com/dl/gn/gn/{}/+/git_revision:{}'.format(pkg,rev)
```

m136 | 2175
m131 | 2175
m128 | 2175
m127 | 2082
m126 | 2082
m116 | 2082
fe330c0ae1ec29db30b6f830e50771a335e071fb | 2082

m87  | 1793
981f46c64d1456d2083b1a2fa1367e753e0cdc1b | 1774

m87 does not have a `bin/fetch-ninja`, but m116 does; but `bin/fetch-ninja`

```
$ git show chrome/m116:bin/fetch-ninja | grep -A 1 'url ='
  url = 'https://chrome-infra-packages.appspot.com/dl/infra/3pp/tools/ninja/%s/+/%s' % (
      platform, desired_version)
```

ninja's `desired_version` is read from `DEPS`.

m136 | version:2@1.12.1.chromium.4
m128 | version:2@1.12.1.chromium.4
m127 | version:2@1.8.2.chromium.3
m126 | version:2@1.8.2.chromium.3
m116 | version:2@1.8.2.chromium.3

