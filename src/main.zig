const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

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
        try stdout.print("{s}> ", .{cwd});
        try stdout.flush();

        const bare_line = try stdin.takeDelimiter('\n');
        const line = bare_line orelse break;
        const clean_line = std.mem.trim(u8, line, "\r");

        if (clean_line.len == 0) continue;

        var it = std.mem.tokenizeAny(u8, clean_line, " \t");
        const cmd = it.next() orelse continue;

        if (std.mem.eql(u8, cmd, "exit")) {
            break;
        }
    }
}
