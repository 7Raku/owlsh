const std = @import("std");

pub fn run(stdout: *std.Io.Writer) !void {
    try stdout.print(
        \\owlsh builtins:
        \\  cd       change directory (~, ~\path, -, no arg = home)
        \\  clear    clear the terminal screen
        \\  echo     print arguments
        \\  exit     exit the shell
        \\  export   set an environment variable (KEY=VALUE)
        \\  help     show this help message
        \\  pwd      print the current working directory
        \\  set      list all environment variables
        \\  unset    remove an environment variable
        \\
    , .{});
    try stdout.flush();
}
