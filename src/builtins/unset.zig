const std = @import("std");
const output = @import("../output.zig");

pub fn run(argv: []const []const u8, stdout: *std.Io.Writer, env: *std.process.Environ.Map) !void {
    if (argv.len < 2) {
        try output.printError(stdout, "unset", "missing variable name", .{});
        return;
    }
    _ = env.orderedRemove(argv[1]);
}
