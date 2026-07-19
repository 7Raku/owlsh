const std = @import("std");
const colors = @import("colors.zig");

pub fn render(io: std.Io, stdout: *std.Io.Writer, username: []const u8, hostname: []const u8, home: ?[]const u8, last_exit_code: u8) !void {
    var cwd_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const cwd_len = try std.process.currentPath(io, &cwd_buf);
    const cwd = cwd_buf[0..cwd_len];

    try stdout.print("{s}{s}@{s}{s} ", .{ colors.cyan, username, hostname, colors.reset });

    if (home) |h| {
        if (std.mem.eql(u8, cwd, h)) {
            try stdout.print("{s}~{s}\n", .{ colors.bright_blue, colors.reset });
        } else if (std.mem.startsWith(u8, cwd, h) and cwd.len > h.len and cwd[h.len] == '\\') {
            try stdout.print("{s}~{s}{s}\n", .{ colors.bright_blue, cwd[h.len..], colors.reset });
        } else {
            try stdout.print("{s}{s}{s}\n", .{ colors.bright_blue, cwd, colors.reset });
        }
    } else {
        try stdout.print("{s}{s}{s}\n", .{ colors.bright_blue, cwd, colors.reset });
    }
    const arrow_color = if (last_exit_code == 0) colors.green else colors.red;
    try stdout.print("{s}➜{s} ", .{ arrow_color, colors.reset });
    try stdout.flush();
}
