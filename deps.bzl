"""Register default linker downloads"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_apple_linker_deps():
    http_archive(
        name = "rules_apple_linker_lld",
        build_file_content = 'filegroup(name = "lld_bin", srcs = ["ld64.lld"], visibility = ["//visibility:public"])',
        sha256 = "b54ea1d79ef6af94507fbc5832d1d56d1c4fc98df2010de6afedda6653067737",
        url = "https://github.com/keith/ld64.lld/releases/download/03-15-25/ld64.tar.xz",
    )

def _impl(_):
    rules_apple_linker_deps()

linker_deps = module_extension(implementation = _impl)
