"""Register default linker downloads"""

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
        sha256 = "a55344b2401700089a46f8573248e01d2450e69a2320fe17e65895c1b58cb306",
        url = "https://github.com/keith/ld64.lld/releases/download/12-22-22/ld64.tar.xz",
    )

    http_archive(
        name = "rules_apple_linker_mold",
        build_file_content = 'filegroup(name = "mold_bin", srcs = ["ld64.mold"], visibility = ["//visibility:public"])',
        sha256 = "2b1ab27d4ab0d6319cf79b6bc94710e8a515c069670191dea022c3dffaef64fd",
        url = "https://github.com/keith/ld64.mold/releases/download/11-7-22/ld64.tar.xz",
    )

def _impl(_):
    rules_apple_linker_deps()

linker_deps = module_extension(implementation = _impl)
