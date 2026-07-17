const std = @import("std");
const cd = @import("cd.zig");
const exit = @import("exit.zig");

pub const Result = enum {
    not_builtin,
    handled,
    exit_shell,
};

pub fn dispatch(
    cmd: []const u8,
    argv: []const []const u8,
    io: std.Io,
    stdout: *std.Io.Writer,
) !Result {
    if (std.mem.eql(u8, cmd, "exit")) {
        exit.run();
        return .exit_shell;
    }
    if (std.mem.eql(u8, cmd, "cd")) {
        try cd.run(io, argv, stdout);
        return .handled;
    }
    return .not_builtin;
}
