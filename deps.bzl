"""
Register default linker downloads
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_apple_linker_deps():
    http_archive(
        name = "rules_apple_linker_zld",
        build_file_content = 'filegroup(name = "zld_bin", srcs = ["zld"], visibility = ["//visibility:public"])',
        sha256 = "dee657c070e9553a47a09f55800a24f978887929eef7ab27472af48bf068f566",
        url = "https://github.com/michaeleisel/zld/releases/download/1.3.3/zld.zip",
    )

    http_archive(
        name = "rules_apple_linker_lld",
        build_file_content = 'filegroup(name = "lld_bin", srcs = ["ld64.lld"], visibility = ["//visibility:public"])',
        sha256 = "26ae462084eb65400ac0cfeae597875b29d895a8ecb2003579ae45b9f3c65796",
        url = "https://github.com/keith/ld64.lld/releases/download/5-19-22/ld64.tar.xz",
    )
