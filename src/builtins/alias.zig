const std = @import("std");
const output = @import("../output.zig");

pub fn run(gpa: std.mem.Allocator, argv: []const []const u8, stdout: *std.Io.Writer, aliases: *std.StringHashMap([]const u8)) !void {
    if (argv.len < 2) {
        var it = aliases.iterator();
        while (it.next()) |entry| {
            try stdout.print("{s}={s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
        try stdout.flush();
        return;
    }

    const arg = argv[1];
    const eq_pos = std.mem.indexOfScalar(u8, arg, '=') orelse {
        try output.printError(stdout, "alias", "invalid format, expected NAME=VALUE", .{});
        return;
    };

    const name = arg[0..eq_pos];
    const value = arg[eq_pos + 1 ..];

    const name_owned = try gpa.dupe(u8, name);
    errdefer gpa.free(name_owned);
    const value_owned = try gpa.dupe(u8, value);
    errdefer gpa.free(value_owned);

    const existing = try aliases.fetchPut(name_owned, value_owned);
    if (existing) |kv| {
        gpa.free(name_owned);
        gpa.free(kv.value);
    }
}
