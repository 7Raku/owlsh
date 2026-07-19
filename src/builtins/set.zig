const std = @import("std");

pub fn run(stdout: *std.Io.Writer, env: *const std.process.Environ.Map) !void {
    var it = env.iterator();
    while (it.next()) |entry| {
        try stdout.print("{s}={s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    try stdout.flush();
}
