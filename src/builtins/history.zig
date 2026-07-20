const std = @import("std");

pub fn run(stdout: *std.Io.Writer, history: []const []const u8) !void {
    for (history, 1..) |line, i| {
        try stdout.print("{d}  {s}\n", .{ i, line });
    }
    try stdout.flush();
}
