"""
Register default linker downloads
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_apple_linker_deps():
    http_archive(
        name = "rules_apple_linker_zld",
        build_file_content = 'filegroup(name = "zld_bin", srcs = ["zld"], visibility = ["//visibility:public"])',
        sha256 = "b1897fbe2a2e27241d993d1ae55b5622efd9725139e8b9486b5d6e86cc291415",
        url = "https://github.com/michaeleisel/zld/releases/download/1.3.7/zld.zip",
    )

    http_archive(
        name = "rules_apple_linker_lld",
        build_file_content = 'filegroup(name = "lld_bin", srcs = ["ld64.lld"], visibility = ["//visibility:public"])',
        sha256 = "1370b2f7fc26e7a08cde91a3564cc0447335b5667c7f83f3bce760d550e11c7b",
        url = "https://github.com/keith/ld64.lld/releases/download/9-21-22/ld64.tar.xz",
    )
