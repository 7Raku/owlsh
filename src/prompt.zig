const std = @import("std");

pub fn render(io: std.Io, stdout: *std.Io.Writer, username: []const u8, hostname: []const u8, home: ?[]const u8) !void {
    var cwd_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const cwd_len = try std.process.currentPath(io, &cwd_buf);
    const cwd = cwd_buf[0..cwd_len];

    if (home) |h| {
        if (std.mem.eql(u8, cwd, h)) {
            try stdout.print("{s}@{s} ~\n", .{ username, hostname });
        } else if (std.mem.startsWith(u8, cwd, h) and cwd.len > h.len and cwd[h.len] == '\\') {
            try stdout.print("{s}@{s} ~{s}\n", .{ username, hostname, cwd[h.len..] });
        } else {
            try stdout.print("{s}@{s} {s}\n", .{ username, hostname, cwd });
        }
    } else {
        try stdout.print("{s}@{s} {s}\n", .{ username, hostname, cwd });
    }
    try stdout.print("➜ ", .{});
    try stdout.flush();
}
