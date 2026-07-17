const std = @import("std");
const cd = @import("cd.zig");
const exit = @import("exit.zig");
const clear = @import("clear.zig");

pub const CommandType = enum {
    not_builtin,
    handled,
    exit_shell,
};

pub fn dispatch(
    cmd: []const u8,
    argv: []const []const u8,
    io: std.Io,
    stdout: *std.Io.Writer,
) !CommandType {
    if (std.mem.eql(u8, cmd, "exit")) {
        exit.run();
        return .exit_shell;
    }
    if (std.mem.eql(u8, cmd, "cd")) {
        try cd.run(io, argv, stdout);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "clear")) {
        try clear.run(stdout);
        return .handled;
    }
    return .not_builtin;
}
