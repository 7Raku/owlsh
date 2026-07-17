const std = @import("std");

pub fn run(stdout: *std.Io.Writer) !void {
    try stdout.print("\x1b[2J\x1b[H", .{});
    try stdout.flush();
}
