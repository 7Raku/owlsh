const std = @import("std");

pub fn run(argv: []const []const u8, stdout: *std.Io.Writer) !void {
    for (argv[1..], 0..) |arg, i| {
        if (i > 0) try stdout.print(" ", .{});
        try stdout.print("{s}", .{arg});
    }

    try stdout.print("\n", .{});
    try stdout.flush();
}
