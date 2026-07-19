const std = @import("std");
const colors = @import("colors.zig");

pub fn printError(stdout: *std.Io.Writer, source: []const u8, comptime fmt: []const u8, args: anytype) !void {
    try stdout.print("{s}{s}: ", .{ colors.red, source });
    try stdout.print(fmt, args);
    try stdout.print("{s}\n", .{colors.reset});
    try stdout.flush();
}
