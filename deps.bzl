"""Register default linker downloads"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_apple_linker_deps():
    http_archive(
        name = "rules_apple_linker_lld",
        build_file_content = 'filegroup(name = "lld_bin", srcs = ["ld64.lld"], visibility = ["//visibility:public"])',
        sha256 = "3824addd84e0f97360cbd92eea4e5b63fdd53cc8f82afca6a65a2d39d29ca51a",
        url = "https://github.com/keith/ld64.lld/releases/download/09-16-25/ld64.tar.xz",
    )

def _impl(_):
    rules_apple_linker_deps()

linker_deps = module_extension(implementation = _impl)
