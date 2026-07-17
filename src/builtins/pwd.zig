const std = @import("std");

pub fn run(io: std.Io, stdout: *std.Io.Writer) !void {
    var buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const len = std.process.currentPath(io, &buf) catch |err| {
        try stdout.print("pwd: {s}\n", .{@errorName(err)});
        try stdout.flush();
        return;
    };
    try stdout.print("{s}\n", .{buf[0..len]});
    try stdout.flush();
}
