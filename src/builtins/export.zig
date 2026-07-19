const std = @import("std");
const output = @import("../ui/output.zig");

pub fn run(argv: []const []const u8, stdout: *std.Io.Writer, env: *std.process.Environ.Map) !void {
    if (argv.len < 2) {
        try output.printError(stdout, "export", "missing KEY=VALUE argument", .{});
        return;
    }

    const arg = argv[1];
    const eq_pos = std.mem.indexOfScalar(u8, arg, '=') orelse {
        try output.printError(stdout, "export", "invalid format, expected KEY=VALUE", .{});
        return;
    };

    const key = arg[0..eq_pos];
    const value = arg[eq_pos + 1 ..];
    try env.put(key, value);
}
