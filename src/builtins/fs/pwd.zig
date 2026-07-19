const std = @import("std");
const output = @import("../../ui/output.zig");

pub fn run(io: std.Io, stdout: *std.Io.Writer) !void {
    var buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const len = std.process.currentPath(io, &buf) catch |err| {
        try output.printError(stdout, "pwd", "{s}", .{@errorName(err)});
        return;
    };
    try stdout.print("{s}\n", .{buf[0..len]});
    try stdout.flush();
}
