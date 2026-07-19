const std = @import("std");
const output = @import("../ui/output.zig");

pub fn run(gpa: std.mem.Allocator, argv: []const []const u8, stdout: *std.Io.Writer, aliases: *std.StringHashMap([]const u8)) !void {
    if (argv.len < 2) {
        try output.printError(stdout, "unalias", "missing alias name", .{});
        return;
    }

    if (aliases.fetchRemove(argv[1])) |kv| {
        gpa.free(kv.key);
        gpa.free(kv.value);
    }
}
