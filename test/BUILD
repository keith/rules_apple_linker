load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")
load("@rules_apple_linker//:rules.bzl", "lld_override")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_command_line_application")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load(":rules.bzl", "action_command_line_test")

lld_override(
    name = "lld_disabled",
    enable = False,
    ld64_linkopts = ["-Wl,-add_empty_section,LD64,ENABLED"],
    linkopts = ["-Wl,-sectcreate,SHARED,LINKOPT,/dev/null"],
)

lld_override(
    name = "lld",
    ld64_linkopts = ["-Wl,-add_empty_section,LD64,ENABLED"],
    linkopts = ["-Wl,-sectcreate,SHARED,LINKOPT,/dev/null"],
    lld_linkopts = ["-Wl,-sectcreate,LLD,ENABLED,/dev/null"],
)

cc_test(
    name = "default_test",
    srcs = ["main.c"],
)

cc_test(
    name = "lld_test",
    srcs = ["main.c"],
    deps = ["@rules_apple_linker//:lld"],
)

cc_test(
    name = "lld_disabled_test",
    srcs = ["main.c"],
    deps = [":lld_disabled"],
)

cc_test(
    name = "lld_linkopts_test",
    srcs = ["main.c"],
    deps = [":lld"],
)

cc_library(
    name = "binary_lib",
    srcs = ["main.c"],
    deps = ["@rules_apple_linker//:lld"],
)

swift_binary(
    name = "swift_binary",
    deps = [":binary_lib"],
)

objc_library(
    name = "objc_binary_lib",
    srcs = ["main.c"],
)

macos_command_line_application(
    name = "command_line_tool",
    minimum_os_version = "10.15",
    deps = [
        ":objc_binary_lib",
        "@rules_apple_linker//:lld",
    ],
)

ios_unit_test(
    name = "ios_unit_test",
    minimum_os_version = "10.0",
    tags = ["manual"],
    deps = [
        ":lld",
        ":objc_binary_lib",
    ],
)

action_command_line_test(
    name = "use_lld_test",
    expected_argv = ["--ld-path=external/$(BZLMOD)rules_apple_linker_lld/ld64.lld"],
    mnemonics = ["CppLink"],
    target_under_test = ":lld_test",
)

action_command_line_test(
    name = "lld_swift_binary_test",
    expected_argv = ["--ld-path=external/$(BZLMOD)rules_apple_linker_lld/ld64.lld"],
    mnemonics = ["CppLink"],
    target_under_test = ":swift_binary",
)

action_command_line_test(
    name = "command_line_tool_test",
    expected_argv = ["--ld-path=external/$(BZLMOD)rules_apple_linker_lld/ld64.lld"],
    mnemonics = [
        "CppLink",
        "ObjcLink",
    ],  # TODO: Remove CppLink once we support bazel 5.x+ only
    target_under_test = ":command_line_tool",
)

action_command_line_test(
    name = "ios_unit_test_test",
    expected_argv = [
        "--ld-path=external/$(BZLMOD)rules_apple_linker_lld/ld64.lld",
        "-Wl,-sectcreate,LLD,ENABLED,/dev/null",
    ],
    mnemonics = [
        "CppLink",
        "ObjcLink",
    ],  # TODO: Remove CppLink once we support bazel 5.x+ only
    target_under_test = ":ios_unit_test.__internal__.__test_bundle",  # Internal binary rule does the link
)

action_command_line_test(
    name = "disable_lld_test",
    expected_argv = [
        "-Wl,-add_empty_section,LD64,ENABLED",
        "-Wl,-sectcreate,SHARED,LINKOPT,/dev/null",
    ],
    mnemonics = ["CppLink"],
    not_expected_argv = ["--ld-path=external/$(BZLMOD)rules_apple_linker_lld/ld64.lld"],
    target_under_test = ":lld_disabled_test",
)

action_command_line_test(
    name = "lld_linkopts_args_test",
    expected_argv = [
        "-Wl,-sectcreate,LLD,ENABLED,/dev/null",
        "-Wl,-sectcreate,SHARED,LINKOPT,/dev/null",
    ],
    mnemonics = ["CppLink"],
    not_expected_argv = ["-Wl,-add_empty_section,LD64,ENABLED"],
    target_under_test = ":lld_linkopts_test",
)

action_command_line_test(
    name = "default_linker_test",
    mnemonics = ["CppLink"],
    not_expected_argv = [
        "--ld-path=external/$(BZLMOD)rules_apple_linker_lld/ld64.lld",
    ],
    target_under_test = ":default_test",
)
