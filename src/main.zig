const std = @import("std");
const builtin = @import("builtin");
const builtins = @import("builtins/mod.zig");
const tokenizer = @import("tokenizer.zig");

extern "kernel32" fn SetConsoleOutputCP(wCodePageID: std.os.windows.UINT) callconv(.winapi) std.os.windows.BOOL;

pub fn main(init: std.process.Init) !void {
    if (builtin.os.tag == .windows) {
        _ = SetConsoleOutputCP(65001);
    }

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
    var first_prompt = true;
    var skip_spacing = false;

    while (true) {
        if (first_prompt) {
            first_prompt = false;
        } else if (!skip_spacing) {
            try stdout.print("\n", .{});
        }
        skip_spacing = false;

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

        const argv = tokenizer.tokenize(gpa, clean_line) catch |err| {
            try stdout.print("parse error: {s}\n", .{@errorName(err)});
            try stdout.flush();
            continue;
        };
        defer {
            for (argv) |token| gpa.free(token);
            gpa.free(argv);
        }

        if (argv.len == 0) continue;
        const cmd = argv[0];

        switch (try builtins.dispatch(cmd, argv, io, stdout, home)) {
            .exit_shell => break,
            .handled => {
                if (std.mem.eql(u8, cmd, "clear")) skip_spacing = true;
                continue;
            },
            .not_builtin => {},
        }

        var proc = std.process.spawn(io, .{
            .argv = argv,
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
