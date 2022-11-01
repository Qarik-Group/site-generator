load("@bazel_skylib//lib:paths.bzl", "paths")

def _aip_site_build_impl(ctx):
    site = ctx.actions.declare_directory(ctx.label.name)

    workdir = ctx.actions.declare_directory("_" + ctx.label.name)
    script = ctx.actions.declare_file(ctx.label.name + ".sh")

    cmds = [
        "mkdir -p $(dirname {dest}); cp -L {src} {dest}".format(
            dirname = workdir.path + "/" + f.dirname,
            src = f.path,
            dest = workdir.path + "/" + f.short_path,
        ) for f in ctx.files.srcs
    ]
    
    ctx.actions.write(
        output = script,
        content = "\n".join(["#!/bin/sh"] + cmds) + "\n",
        is_executable = True,
    )

    ctx.actions.run(
        executable = script,
        inputs = [script] + ctx.files.srcs,
        outputs = [workdir],
    )

    # Action to call the script.
    ctx.actions.run(
        inputs = [workdir],
        outputs = [site],
        arguments = ["publish", workdir.path + "/" + paths.dirname(ctx.build_file_path), site.path],
        progress_message = "Generating AIP static site with generator",
        executable = ctx.executable.generator,
    )

    return [DefaultInfo(files = depset([site]))]

aip_site_build = rule(
    implementation = _aip_site_build_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "generator": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
    },
)
