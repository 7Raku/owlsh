const std = @import("std");
const builtin = @import("builtin");
const builtins = @import("builtins/mod.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const home = init.environ_map.get("USERPROFILE");
    const username = init.environ_map.get("USERNAME") orelse "user";
    const hostname = init.environ_map.get("COMPUTERNAME") orelse "host";

    var stdin_buf: [1024]u8 = undefined;
    var stdin_file = std.Io.File.stdin();
    var stdin_reader = stdin_file.reader(io, &stdin_buf);
    const stdin = &stdin_reader.interface;

    var stdout_buf: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(io, &stdout_buf);
    const stdout = &stdout_writer.interface;

    var cwd_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;

    while (true) {
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

        const bare_line = try stdin.takeDelimiter('\n');
        const line = bare_line orelse break;
        const clean_line = std.mem.trim(u8, line, "\r");

        if (clean_line.len == 0) continue;

        var it = std.mem.tokenizeAny(u8, clean_line, " \t");

        var argv: std.ArrayList([]const u8) = .empty;
        defer argv.deinit(gpa);

        while (it.next()) |token| {
            try argv.append(gpa, token);
        }

        if (argv.items.len == 0) continue;
        const cmd = argv.items[0];

        switch (try builtins.dispatch(cmd, argv.items, io, stdout)) {
            .exit_shell => break,
            .handled => continue,
            .not_builtin => {},
        }

        var proc = std.process.spawn(io, .{
            .argv = argv.items,
        }) catch |err| {
            try stdout.print("{s}: {s}\n", .{ cmd, @errorName(err) });
            try stdout.flush();
            continue;
        };

        const term = try proc.wait(io);
        switch (term) {
            .exited => |code| {
                if (code != 0) {
                    try stdout.print("[exit code {d}]\n", .{code});
                    try stdout.flush();
                }
            },
            else => {},
        }
    }
}
