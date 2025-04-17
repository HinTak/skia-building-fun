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

or (there is only one annotated tag, `initial-commit`):

```
$ git describe 981f46c64d14
initial-commit-1774-g981f46c6
$ git describe fe330c0ae1ec
initial-commit-2082-gfe330c0a
$ git describe 7a8aa3a08a13
initial-commit-2221-g7a8aa3a0
```

Skia's source code contains `bin/fetch-gn`, which has a hard-coded rev it tries to fetch:

```
# in skia repo:
$ git show chrome/m87:bin/fetch-gn | grep rev
  rev = '9e993e3da82a9f4bc5c50c190afbcffd61e3d9e0'
  url = 'https://chrome-infra-packages.appspot.com/dl/gn/gn/{}/+/git_revision:{}'.format(pkg,rev)
```

| Milestone | GN Version |
| ---  | --- |
| m136 | 2175 |
| m131 | 2175 |
| m128 | 2175 |
| m127 | 2082 |
| m126 | 2082 |
| m116 | 2082 |
| fe330c0ae1ec29db30b6f830e50771a335e071fb | 2082 |
| ---  | --- |
| m87  | 1793 |
981f46c64d1456d2083b1a2fa1367e753e0cdc1b | 1774 |

<!--
commit 981f46c64d1456d2083b1a2fa1367e753e0cdc1b
Author: Harley Li <hhli@chromium.org>
Date:   Wed Jun 3 10:33:23 2020 -0400
-->

<!--
commit 63c32297733f5d95a9155335117a290b078a9beb
Author: Kota Yamaguchi <KotaYamaguchi1984@gmail.com>
Date:   Tue Jun 9 17:05:33 2020 +0900

    Set gn to specific commit
-->


m87 does not have a `bin/fetch-ninja`, but m116 does; but `bin/fetch-ninja`

```
$ git show chrome/m116:bin/fetch-ninja | grep -A 1 'url ='
  url = 'https://chrome-infra-packages.appspot.com/dl/infra/3pp/tools/ninja/%s/+/%s' % (
      platform, desired_version)
```

ninja's `desired_version` is read from `DEPS`.

| Milestone | Ninja Version |
| ---  | --- |
| m136 | version:2@1.12.1.chromium.4 |
| m128 | version:2@1.12.1.chromium.4 |
| m127 | version:2@1.8.2.chromium.3 |
| m126 | version:2@1.8.2.chromium.3 |
| m116 | version:2@1.8.2.chromium.3 |


`bin/fetch-ninja` was introduced in [commit](https://github.com/google/skia/commit/46900fb0816d77448bf0c8fe9918761bc1be04b9) in Nov 18, 2022.

`bin/fetch-gn` was [updated](https://github.com/google/skia/commits/main/bin/fetch-gn), with somewhat breaking changes on
Mar 21, 2023 and Jun 18, 2020 (both involves reverts):

| Commit | Date | Version Change |
| ---  | --- | --- |
| [Roll GN commit](https://github.com/google/skia/commit/adf6da3b1f52bf976887ecd6ef045ef0c8115efe)           | Jun 26, 2024 | 2082 to 2175 |
<!-- 'fe330c0ae1ec29db30b6f830e50771a335e071fb'
     'b2afae122eeb6ce09c52d63f67dc53fc517dbdc8' -->
| [Reland: Roll GN revision](https://github.com/google/skia/commit/7c7977e4859ba07c3e65be035296e1a50901cf97) | Mar 21, 2023 | 1880 to 2082 |
<!-- 'd62642c920e6a0d1756316d225a90fd6faa9e21e'
     'fe330c0ae1ec29db30b6f830e50771a335e071fb' -->
| [roll gn to latest](https://github.com/google/skia/commit/4f4c064d5b749f139eb69d6e7f3852cb0fd53d4f)        | Jan 15, 2021 | 1793 to 1880 |
<!-- '9e993e3da82a9f4bc5c50c190afbcffd61e3d9e0'
     'd62642c920e6a0d1756316d225a90fd6faa9e21e' -->
| [Roll gn.](https://github.com/google/skia/commit/3890d3d76511f53726f04c705b8a657ce8bc38e3)                 | Jun 18, 2020 | 1733 to 1793 |
<!-- '82d673acb802cee21534c796a59f8cdf26500f53'
     '9e993e3da82a9f4bc5c50c190afbcffd61e3d9e0' -->
| [roll GN](https://github.com/google/skia/commit/bfc09267bdb446fb31110099f029a846adc001fe)                  | Apr 1, 2020  | sha1 to 1733 |
<!-- from sha1 based to
 rev = '82d673acb802cee21534c796a59f8cdf26500f53' -->


`chrome/m87` was branched between Oct 1, 2020 and Oct 9, 2020. Last commit on Feb 22, 2021.

`chrome/m88` was branched between Nov 11, 2020 and Nov 24, 2020. Last commit on Feb 22, 2021.
