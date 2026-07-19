const std = @import("std");

pub fn run(gpa: std.mem.Allocator, argv: []const []const u8, aliases: *std.StringHashMap([]const u8)) !void {
    if (argv.len < 2) return;

    if (aliases.fetchRemove(argv[1])) |kv| {
        gpa.free(kv.key);
        gpa.free(kv.value);
    }
}
