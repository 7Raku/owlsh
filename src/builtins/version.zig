const std = @import("std");
const build_options = @import("build_options");

pub fn run(stdout: *std.Io.Writer) !void {
    try stdout.print("owlsh v{s}\n", .{build_options.version});
    try stdout.flush();
}
