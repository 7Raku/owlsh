const std = @import("std");
const builtin = @import("builtin");
const builtins = @import("builtins/mod.zig");
const tokenizer = @import("tokenizer.zig");
const output = @import("ui/output.zig");
const prompt = @import("ui/prompt.zig");
const banner = @import("ui/banner.zig");

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
    var last_exit_code: u8 = 0;

    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();

    var aliases: std.StringHashMap([]const u8) = .init(gpa);
    defer {
        var it = aliases.iterator();
        while (it.next()) |entry| {
            gpa.free(entry.key_ptr.*);
            gpa.free(entry.value_ptr.*);
        }
        aliases.deinit();
    }

    var history: std.ArrayListUnmanaged([]const u8) = .empty;
    defer {
        for (history.items) |line| gpa.free(line);
        history.deinit(gpa);
    }

    var stdin_buf: [1024]u8 = undefined;
    var stdin_file = std.Io.File.stdin();
    var stdin_reader = stdin_file.reader(io, &stdin_buf);
    const stdin = &stdin_reader.interface;

    var stdout_buf: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(io, &stdout_buf);
    const stdout = &stdout_writer.interface;

    try banner.render(stdout);

    var first_prompt = true;
    var skip_spacing = false;

    while (true) {
        _ = arena_state.reset(.retain_capacity);
        const arena = arena_state.allocator();

        if (first_prompt) {
            first_prompt = false;
        } else if (!skip_spacing) {
            try stdout.print("\n", .{});
        }
        skip_spacing = false;

        try prompt.render(io, stdout, username, hostname, home, last_exit_code);

        const bare_line = try stdin.takeDelimiter('\n');
        const line = bare_line orelse break;
        const clean_line = std.mem.trim(u8, line, "\r");

        if (clean_line.len == 0) continue;

        const line_copy = try gpa.dupe(u8, clean_line);
        try history.append(gpa, line_copy);

        const argv = tokenizer.tokenize(arena, clean_line) catch |err| {
            try output.printError(stdout, "owlsh", "parse error: {s}", .{@errorName(err)});
            continue;
        };

        if (argv.len == 0) continue;
        var effective_argv = argv;
        var cmd = argv[0];

        if (aliases.get(cmd)) |expansion| {
            const expansion_tokens = tokenizer.tokenize(arena, expansion) catch |err| {
                try output.printError(stdout, "owlsh", "alias parse error: {s}", .{@errorName(err)});
                continue;
            };
            const combined = try arena.alloc([]const u8, expansion_tokens.len + (argv.len - 1));
            @memcpy(combined[0..expansion_tokens.len], expansion_tokens);
            @memcpy(combined[expansion_tokens.len..], argv[1..]);

            if (combined.len == 0) continue;

            effective_argv = combined;
            cmd = combined[0];
        }

        switch (try builtins.dispatch(cmd, effective_argv, io, gpa, stdout, home, init.environ_map, &aliases, history.items)) {
            .exit_shell => break,
            .handled => {
                last_exit_code = 0;
                if (std.mem.eql(u8, cmd, "clear") or std.mem.eql(u8, cmd, "cls")) skip_spacing = true;
                continue;
            },
            .not_builtin => {},
        }

        var proc = std.process.spawn(io, .{
            .argv = effective_argv,
            .environ_map = init.environ_map,
        }) catch |err| {
            try output.printError(stdout, cmd, "{s}", .{@errorName(err)});
            last_exit_code = 1;
            continue;
        };

        const term = try proc.wait(io);
        switch (term) {
            .exited => |code| {
                last_exit_code = code;
                if (code != 0) {
                    try stdout.print("[exit code {d}]\n", .{code});
                    try stdout.flush();
                }
            },
            else => last_exit_code = 1,
        }
    }
}
