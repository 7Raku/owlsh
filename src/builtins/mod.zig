const std = @import("std");
const cd = @import("cd.zig");
const clear = @import("clear.zig");
const pwd = @import("pwd.zig");
const echo = @import("echo.zig");
const help = @import("help.zig");
const export_cmd = @import("export.zig");
const set = @import("set.zig");
const unset = @import("unset.zig");

pub const CommandType = enum {
    not_builtin,
    handled,
    exit_shell,
};

pub const DirHistory = cd.DirHistory;

pub fn dispatch(cmd: []const u8, argv: []const []const u8, io: std.Io, stdout: *std.Io.Writer, home: ?[]const u8, prev_dir: *DirHistory, env: *std.process.Environ.Map) !CommandType {
    if (std.mem.eql(u8, cmd, "exit")) {
        return .exit_shell;
    }
    if (std.mem.eql(u8, cmd, "cd")) {
        try cd.run(io, argv, stdout, home, prev_dir);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "clear")) {
        try clear.run(stdout);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "pwd")) {
        try pwd.run(io, stdout);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "echo")) {
        try echo.run(argv, stdout);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "help")) {
        try help.run(stdout);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "export")) {
        try export_cmd.run(argv, stdout, env);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "set")) {
        try set.run(stdout, env);
        return .handled;
    }
    if (std.mem.eql(u8, cmd, "unset")) {
        try unset.run(argv, stdout, env);
        return .handled;
    }
    return .not_builtin;
}
