#!/bin/bash

set -euo pipefail

readonly new_version=$1
readonly archive=$2
sha256=$(shasum -a 256 "$archive" | cut -d ' ' -f 1)
lld_version=$(sed -n 's|.*github.com/keith/ld64.lld/releases/download/\([^/]*\)/.*|\1|p' deps.bzl)

cat <<EOF
### MODULE.bazel Snippet

\`\`\`bzl
bazel_dep(name = "rules_apple_linker", version = "$new_version")
\`\`\`

### WORKSPACE Snippet

\`\`\`bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_apple_linker",
    sha256 = "$sha256",
    urls = [
        "https://github.com/keith/rules_apple_linker/releases/download/$new_version/rules_apple_linker.$new_version.tar.gz",
    ],
)

load("@rules_apple_linker//:deps.bzl", "rules_apple_linker_deps")

rules_apple_linker_deps()
\`\`\`

This release includes [\`lld\` $lld_version](https://github.com/keith/ld64.lld/releases/tag/$lld_version)
EOF
