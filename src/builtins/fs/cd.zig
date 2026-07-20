const std = @import("std");
const output = @import("../../ui/output.zig");

pub fn run(io: std.Io, argv: []const []const u8, stdout: *std.Io.Writer, home: ?[]const u8, env: *std.process.Environ.Map) !void {
    var target: []const u8 = if (argv.len < 2) "~" else argv[1];
    var expanded_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;

    if (std.mem.eql(u8, target, "~") or std.mem.startsWith(u8, target, "~\\") or std.mem.startsWith(u8, target, "~/")) {
        const h = home orelse {
            try output.printError(stdout, "cd", "~: HOME not set", .{});
            return;
        };
        target = if (std.mem.eql(u8, target, "~"))
            h
        else
            try std.fmt.bufPrint(&expanded_buf, "{s}{s}", .{ h, target[1..] });
    } else if (std.mem.eql(u8, target, "-")) {
        target = env.get("OLDPWD") orelse {
            try output.printError(stdout, "cd", "-: no previous directory", .{});
            return;
        };
    }

    var cwd_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const cwd_len = try std.process.currentPath(io, &cwd_buf);
    const cwd = cwd_buf[0..cwd_len];

    var dir = std.Io.Dir.cwd().openDir(io, target, .{}) catch |err| {
        try output.printError(stdout, "cd", "{s}: {s}", .{ target, @errorName(err) });
        return;
    };
    defer dir.close(io);

    std.process.setCurrentDir(io, dir) catch |err| {
        try output.printError(stdout, "cd", "{s}: {s}", .{ target, @errorName(err) });
        return;
    };

    try env.put("OLDPWD", cwd);
}
