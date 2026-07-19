const std = @import("std");
const build_options = @import("build_options");

pub fn render(stdout: *std.Io.Writer) !void {
    try stdout.print(
        \\owlsh v{s} — tiny, fast, customizable shell for Windows
        \\Type 'help' to see available commands.
        \\
        \\
    , .{build_options.version});
    try stdout.flush();
}
