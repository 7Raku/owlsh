const std = @import("std");

const color_err = "\x1b[31m";
const color_reset = "\x1b[0m";

pub fn printError(stdout: *std.Io.Writer, source: []const u8, comptime fmt: []const u8, args: anytype) !void {
    try stdout.print("{s}{s}: ", .{ color_err, source });
    try stdout.print(fmt, args);
    try stdout.print("{s}\n", .{color_reset});
    try stdout.flush();
}
