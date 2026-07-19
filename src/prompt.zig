const std = @import("std");

const color_user = "\x1b[36m"; // cyan
const color_path = "\x1b[94m"; // blue
const color_arrow_ok = "\x1b[32m"; // green
const color_arrow_err = "\x1b[31m"; // red
const color_reset = "\x1b[0m";

pub fn render(io: std.Io, stdout: *std.Io.Writer, username: []const u8, hostname: []const u8, home: ?[]const u8, last_exit_code: u8) !void {
    var cwd_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const cwd_len = try std.process.currentPath(io, &cwd_buf);
    const cwd = cwd_buf[0..cwd_len];

    try stdout.print("{s}{s}@{s}{s} ", .{ color_user, username, hostname, color_reset });

    if (home) |h| {
        if (std.mem.eql(u8, cwd, h)) {
            try stdout.print("{s}~{s}\n", .{ color_path, color_reset });
        } else if (std.mem.startsWith(u8, cwd, h) and cwd.len > h.len and cwd[h.len] == '\\') {
            try stdout.print("{s}~{s}{s}\n", .{ color_path, cwd[h.len..], color_reset });
        } else {
            try stdout.print("{s}{s}{s}\n", .{ color_path, cwd, color_reset });
        }
    } else {
        try stdout.print("{s}{s}{s}\n", .{ color_path, cwd, color_reset });
    }
    const arrow_color = if (last_exit_code == 0) color_arrow_ok else color_arrow_err;
    try stdout.print("{s}➜{s} ", .{ arrow_color, color_reset });
    try stdout.flush();
}
