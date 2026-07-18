const std = @import("std");

pub fn render(stdout: *std.Io.Writer) !void {
    try stdout.print(
        \\owlsh v0.0.0 — tiny, fast, customizable shell for Windows
        \\Type 'help' to see available commands.
        \\
        \\
    , .{});
    try stdout.flush();
}
