const std = @import("std");
const output = @import("../../ui/output.zig");

pub fn run(io: std.Io, gpa: std.mem.Allocator, argv: []const []const u8, stdout: *std.Io.Writer) !void {
    if (argv.len < 2) {
        try output.printError(stdout, "cat", "missing file operand", .{});
        return;
    }

    const path = argv[1];
    const contents = std.Io.Dir.cwd().readFileAlloc(io, path, gpa, .unlimited) catch |err| {
        try output.printError(stdout, "cat", "{s}: {s}", .{ path, @errorName(err) });
        return;
    };
    defer gpa.free(contents);

    try stdout.print("{s}", .{contents});
    try stdout.flush();
}
