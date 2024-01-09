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
            executable = True,
            cfg = "exec",
            doc = "The linker to use",
        ),
        "ld64_linkopts": attr.string_list(
            doc = "The options to pass to ld64 if 'enable' is False",
        ),
        "linkopts": attr.string_list(
            doc = "The options to pass to both the overriden linker and ld64",
        ),
        "enable": attr.bool(
            default = True,
            doc = "Whether to enable the overriden linker, useful for disabling with select",
        ),
    }
    attrs.update(extra_attrs)
    return attrs

def _linker_override(ctx, override_linkopts):
    """Construct the providers to override the linker

    Args:
        ctx: The rule context, expected to have some shared attrs
        override_linkopts: Linker options to use with the custom linker
    """

    if not ctx.attr.linker:
        fail("error: linker not specified")

    linkopts = list(ctx.attr.linkopts)
    if ctx.attr.enable:
        linker_inputs_depset = ctx.attr.linker[DefaultInfo].files
        linkopts.append("--ld-path={}".format(ctx.attr.linker[DefaultInfo].files_to_run.executable.path))
        linkopts.extend(override_linkopts)
    else:
        linker_inputs_depset = depset([])
        linkopts.extend(ctx.attr.ld64_linkopts)

    linkopts_depset = depset(direct = linkopts, order = "topological")

    objc_provider_kwargs = {}
    if hasattr(apple_common.new_objc_provider(), "linkopt"):
        objc_provider_kwargs = {
            "linkopt": linkopts_depset,
            "link_inputs": linker_inputs_depset,
        }

    return [
        apple_common.new_objc_provider(**objc_provider_kwargs),
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
    ]

def _apple_linker_override(ctx):
    return _linker_override(ctx, ctx.attr.override_linkopts)

apple_linker_override = rule(
    implementation = _apple_linker_override,
    attrs = _attrs(
        None,
        {
            "override_linkopts": attr.string_list(
                mandatory = False,
                doc = "The options to pass to the custom linker, and not ld64 (see enable)",
            ),
        },
    ),
    provides = [apple_common.Objc, CcInfo],
)

def _lld_override(ctx):
    return _linker_override(ctx, ctx.attr.lld_linkopts)

lld_override = rule(
    implementation = _lld_override,
    attrs = _attrs(
        "@rules_apple_linker_lld//:lld_bin",
        {
            "lld_linkopts": attr.string_list(
                mandatory = False,
                doc = "The options to pass to lld, and not ld64 (see enable)",
            ),
        },
    ),
    provides = [apple_common.Objc, CcInfo],
)
