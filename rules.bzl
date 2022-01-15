"""
Rules for overridding the linker for Apple builds
"""

def _attrs(linker, extra_attrs):
    """
    Get the shared attributes for all the linker rules

    Args:
        linker: The default linker binary
        extra_attrs: Extra attributes For the specific rule
    """
    attrs = {
        "linker": attr.label(
            default = linker,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            doc = "The linker to use",
        ),
        "ld64_linkopts": attr.string_list(
            mandatory = False,
            doc = "The options to pass to ld64 if 'enable' is False",
        ),
        "linkopts": attr.string_list(
            mandatory = False,
            doc = "The options to pass to both the overriden linker and ld64",
        ),
        "enable": attr.bool(
            mandatory = False,
            default = True,
            doc = "Whether to enable the overriden linker, useful for disabling with select",
        ),
    }
    attrs.update(extra_attrs)
    return attrs

def _linker_override(ctx, overriden_linkopts):
    """Construct the providers to override the linker

    Args:
        ctx: The rule context, expected to have some shared attrs
        overriden_linkopts: Linker options to use with the custom linker
    """

    if not ctx.attr.linker:
        fail("error: linker not specified")

    # TODO: Disable on non macOS
    linkopts = list(ctx.attr.linkopts)
    if ctx.attr.enable:
        linker_inputs_depset = ctx.attr.linker.files
        linkopts.append(
            ctx.expand_location(
                "--ld-path=$(location {})".format(ctx.attr.linker.label),
                targets = [ctx.attr.linker],
            ),
        )
        linkopts.extend(overriden_linkopts)
    else:
        linker_inputs_depset = depset([])
        linkopts.extend(ctx.attr.ld64_linkopts)

    linkopts_depset = depset(direct = linkopts, order = "topological")
    return [
        CcInfo(
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([
                    cc_common.create_linker_input(
                        additional_inputs = linker_inputs_depset,
                        owner = ctx.label,
                        user_link_flags = linkopts_depset,
                    ),
                ]),
            ),
        ),
        apple_common.new_objc_provider(
            link_inputs = linker_inputs_depset,
            linkopt = linkopts_depset,
        ),
    ]

def _apple_linker_override_impl(ctx):
    return _linker_override(ctx, ctx.attr.overriden_linkopts)

apple_linker_override = rule(
    implementation = _apple_linker_override_impl,
    attrs = _attrs(
        None,
        {
            "overriden_linkopts": attr.string_list(
                mandatory = False,
                doc = "The options to pass to the custom linker, and not ld64",
            ),
        },
    ),
    provides = [apple_common.Objc, CcInfo],
)

def _zld_impl(ctx):
    return _linker_override(ctx, ctx.attr.zld_linkopts)

zld = rule(
    implementation = _zld_impl,
    attrs = _attrs(
        "@rules_apple_linker_zld//:zld_bin",
        {
            "zld_linkopts": attr.string_list(
                mandatory = False,
                doc = "The options to pass to zld, and not ld64",
            ),
        },
    ),
    provides = [apple_common.Objc, CcInfo],
)

def _lld_impl(ctx):
    return _linker_override(ctx, ctx.attr.lld_linkopts)

lld = rule(
    implementation = _lld_impl,
    attrs = _attrs(
        "@rules_apple_linker_lld//:lld_bin",
        {
            "lld_linkopts": attr.string_list(
                mandatory = False,
                doc = "The options to pass to lld, and not ld64",
            ),
        },
    ),
    provides = [apple_common.Objc, CcInfo],
)
