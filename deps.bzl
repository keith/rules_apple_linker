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
        sha256 = "8c5ca2d04e694ff79eb94003e9350828deb6401235d1cfcb950e2695bc6ec0e3",
        url = "https://github.com/keith/ld64.lld/releases/download/c5fef77bc35d/lld.tar.bz2",
    )
