"""Register default linker downloads"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_apple_linker_deps(bzlmod = False):
    if not bzlmod:
        maybe(
            http_archive,
            name = "rules_cc",
            urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.17/rules_cc-0.0.17.tar.gz"],
            sha256 = "abc605dd850f813bb37004b77db20106a19311a96b2da1c92b789da529d28fe1",
            strip_prefix = "rules_cc-0.0.17",
        )

    http_archive(
        name = "rules_apple_linker_lld",
        build_file_content = 'filegroup(name = "lld_bin", srcs = ["ld64.lld"], visibility = ["//visibility:public"])',
        sha256 = "902c6efa126915ca5433f01ce610edfb4d47b5207836c4277e969932f6ba88af",
        url = "https://github.com/keith/ld64.lld/releases/download/04-08-26/ld64.tar.xz",
    )
