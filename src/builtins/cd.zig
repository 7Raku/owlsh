const std = @import("std");

pub fn run(io: std.Io, argv: []const []const u8, stdout: *std.Io.Writer, home: ?[]const u8) !void {
    if (argv.len < 2) {
        try stdout.print("cd: missing argument\n", .{});
        try stdout.flush();
        return;
    }
    var target = argv[1];
    var expanded_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;

    if (std.mem.eql(u8, target, "~")) {
        target = home orelse {
            try stdout.print("cd: ~: HOME not set\n", .{});
            try stdout.flush();
            return;
        };
    } else if (std.mem.startsWith(u8, target, "~\\") or std.mem.startsWith(u8, target, "~/")) {
        const h = home orelse {
            try stdout.print("cd: ~: HOME not set\n", .{});
            try stdout.flush();
            return;
        };
        target = try std.fmt.bufPrint(&expanded_buf, "{s}{s}", .{ h, target[1..] });
    }

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
