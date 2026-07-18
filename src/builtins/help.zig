const std = @import("std");

pub fn run(stdout: *std.Io.Writer) !void {
    try stdout.print(
        \\owlsh builtins:
        \\  cd       change directory (~, ~\path, -, no arg = home)
        \\  clear    clear the terminal screen
        \\  echo     print arguments
        \\  exit     exit the shell
        \\  help     show this help message
        \\  pwd      print the current working directory
        \\
    , .{});
    try stdout.flush();
}
