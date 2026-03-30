"""Register default linker downloads"""

load("@bazel_features//:features.bzl", "bazel_features")
load(":deps.bzl", "rules_apple_linker_deps")

def _impl(mctx):
    rules_apple_linker_deps(bzlmod = True)
    if bazel_features.external_deps.extension_metadata_has_reproducible:
        return mctx.extension_metadata(reproducible = True)

    return mctx.extension_metadata()

linker_deps = module_extension(implementation = _impl)
