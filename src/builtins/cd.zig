const std = @import("std");

pub fn run(io: std.Io, argv: []const []const u8, stdout: *std.Io.Writer) !void {
    if (argv.len < 2) {
        try stdout.print("cd: missing argument\n", .{});
        try stdout.flush();
        return;
    }
    const target = argv[1];

    var dir = std.Io.Dir.cwd().openDir(io, target, .{}) catch |err| {
        try stdout.print("cd: {s}: {s}\n", .{ target, @errorName(err) });
        try stdout.flush();
        return;
    };
    defer dir.close(io);

    std.process.setCurrentDir(io, dir) catch |err| {
        try stdout.print("cd: {s}: {s}\n", .{ target, @errorName(err) });
        try stdout.flush();
        return;
    };
}
