const std = @import("std");
const output = @import("../ui/output.zig");

pub fn run(io: std.Io, gpa: std.mem.Allocator, argv: []const []const u8, stdout: *std.Io.Writer) !void {
    const path = if (argv.len < 2) "." else argv[1];

    var dir = std.Io.Dir.cwd().openDir(io, path, .{ .iterate = true }) catch |err| {
        try output.printError(stdout, "ls", "{s}: {s}", .{ path, @errorName(err) });
        return;
    };
    defer dir.close(io);

    var entries: std.ArrayListUnmanaged([]const u8) = .empty;
    defer {
        for (entries.items) |name| gpa.free(name);
        entries.deinit(gpa);
    }

    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        const suffix = if (entry.kind == .directory) "/" else "";
        const name = try std.fmt.allocPrint(gpa, "{s}{s}", .{ entry.name, suffix });
        try entries.append(gpa, name);
    }

    std.mem.sort([]const u8, entries.items, {}, lessThan);

    for (entries.items) |name| {
        try stdout.print("{s}\n", .{name});
    }
    try stdout.flush();
}

fn lessThan(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.lessThan(u8, a, b);
}
