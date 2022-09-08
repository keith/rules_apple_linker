# rules_apple_linker

This is a set of [bazel][bazel] rules for overriding the default linker
for builds targeting Apple platforms.

# Why use a different linker?

The primary reason to use a different linker is to decrease link times.
With large projects you may reach a point where the time it takes to
link your binary is a frustrating bottleneck in your iteration cycle. In
some cases replacing the default linker can result in a decrease of 85%
of your link times. For example here are some real world benchmarks (see
[this issue][issue] for more info on the tests):

![benchmarks showing that zld is faster than ld64 and lld is faster than both](https://user-images.githubusercontent.com/283886/149881398-33aa618b-392b-44e1-95d4-7258d17a4ab6.png)

## Linker options

The default linker for MachO binaries is maintained by Apple and
generally referred to as `ld64` (even though the binary is still `ld`).
Currently there are 2 primary alternatives:

### zld

[`zld`][zld] is a fork of `ld64` that optimizes performance. This means
you likely get output that is very similar to what `ld64` produces.
Unfortunately the base of `zld` naturally lags behind changes in `ld64`
because Apple doesn't often push their changes. This means theoretically
some features could be a bit behind what you get with Xcode's version.

### lld

[`lld`][lld] is LLVM's linker. It is a completely separate
implementation of a MachO linker, meaning behavior can differ
significantly from `ld64`, but should still be correct. See [the
docs][llddocs] for some known differences. `lld`'s MachO support is
evolving quickly and is being used in production to link Chrome today.

# Usage

By default `rules_apple_linker` provides targets for `zld`
(`@rules_apple_linker//:zld`) and `lld` (`@rules_apple_linker//:lld`)
for you to use. To enable them add one of the rules to the `deps` of
your targets:

```bzl
objc_library(
    name = "main",
    ...
    deps = [..., "@rules_apple_linker//:lld"],
)
```

To make sure you're always using the override, even if you have multiple
apps or test targets that don't all have the same libraries in their
dependency trees, you can add it directly to the `deps` of your
[`rules_apple`][rules_apple] packaging target. For example in a custom
macro:

```bzl
def my_custom_ios_unit_test(**kwargs):
    deps = kwargs.pop("deps", []) + ["@rules_apple_linker//:zld"]
    ios_unit_test(
        deps = deps,
        **kwargs
    )
```

## Custom linkopts

Using bazel's [`--linkopt=`][linkopt] flag you can pass whatever custom
options you want to the linker. If you need to customize this more based
on other conditions, you can create your own linker target:

```bzl
load("@rules_apple_linker//:rules.bzl", "lld_override")

lld_override(
    name = "lld"
    lld_linkopts = select({
        "//:release": ["-Wl,-icf=all"], # Using a custom config_setting
        "//conditions:default": ["-Wl,-icf=none"],
    }),
)
```

Then you reference your target directly in your `deps` such as
`//bazel:lld` (or the label for wherever you create the target).

The rules also allow you to customize if the linker override is enabled,
and options for either case. For example maybe you want to disable the
custom linker for release mode:

```bzl
load("@rules_apple_linker//:rules.bzl", "lld_override")

lld_override(
    name = "lld"
    lld_linkopts = [...], # Only applies to lld
    ld64_linkopts = [...], # Only applies to ld64
    linkopts = ["-Wl,-fatal_warnings"], # Applies to both linkers
    enable = select({
        "//:release": False, # Using a custom config_setting
        "//conditions:default", True,
    }),
)
```

## Custom linkers

If you'd like to provide your own binary or bazel rule for the linker
you want to use, you can pass the `linker` option when creating your own
target:

```bzl
load("@rules_apple_linker//:rules.bzl", "zld_override")

zld_override(
    name = "zld",
    linker = "@zld//:my-newer-zld",
)
```

You can also use the `apple_linker_override` rule directly if
you don't want `zld` or `lld` specific parameters.

```bzl

load("@rules_apple_linker//:rules.bzl", "apple_linker_override")

apple_linker_override(
    name = "linker",
    linker = "//:my-custom-linker",
    override_linkopts = [...],
)
```

# Installation

See [the releases][releases] for installation instructions.

Note this repo currently requires bazel 4.x+ and Xcode 13.x+, if you'd
like to use this with an older version please [open an issue][newissue]!

[bazel]: https://bazel.build
[issue]: https://github.com/keith/rules_apple_linker/issues/1
[linkopt]: https://docs.bazel.build/versions/main/command-line-reference.html#flag--linkopt
[lld]: https://lld.llvm.org/
[llddocs]: https://github.com/llvm/llvm-project/blob/main/lld/docs/MachO/ld64-vs-lld.rst
[newissue]: https://github.com/keith/rules_apple_linker/issues/new
[releases]: https://github.com/keith/rules_apple_linker/releases
[rules_apple]: https://github.com/bazelbuild/rules_apple
[zld]: https://github.com/michaeleisel/zld
