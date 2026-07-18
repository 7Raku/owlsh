const std = @import("std");

pub fn printError(stdout: *std.Io.Writer, source: []const u8, comptime fmt: []const u8, args: anytype) !void {
    try stdout.print("{s}: ", .{source});
    try stdout.print(fmt, args);
    try stdout.print("\n", .{});
    try stdout.flush();
}
