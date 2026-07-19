const std = @import("std");
const output = @import("../ui/output.zig");

pub fn run(io: std.Io, argv: []const []const u8, stdout: *std.Io.Writer) !void {
    const path = if (argv.len < 2) "." else argv[1];

    var dir = std.Io.Dir.cwd().openDir(io, path, .{ .iterate = true }) catch |err| {
        try output.printError(stdout, "ls", "{s}: {s}", .{ path, @errorName(err) });
        return;
    };
    defer dir.close(io);

    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        try stdout.print("{s}\n", .{entry.name});
    }
    try stdout.flush();
}
