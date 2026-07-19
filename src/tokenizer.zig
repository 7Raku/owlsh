const std = @import("std");

pub const QuoteState = enum {
    none,
    single,
    double,
};

pub fn tokenize(gpa: std.mem.Allocator, line: []const u8) ![][]const u8 {
    var tokens: std.ArrayListUnmanaged([]const u8) = .empty;
    errdefer {
        for (tokens.items) |token| gpa.free(token);
        tokens.deinit(gpa);
    }

    var current: std.ArrayListUnmanaged(u8) = .empty;
    errdefer current.deinit(gpa);

    var state: QuoteState = .none;
    var i: usize = 0;

    while (i < line.len) : (i += 1) {
        const c = line[i];
        switch (state) {
            .none => {
                if (c == ' ' or c == '\t') {
                    if (current.items.len > 0) {
                        try tokens.append(gpa, try current.toOwnedSlice(gpa));
                    }
                } else if (c == '\'') {
                    state = .single;
                } else if (c == '"') {
                    state = .double;
                } else {
                    try current.append(gpa, c);
                }
            },
            .single => {
                if (c == '\'') {
                    state = .none;
                } else {
                    try current.append(gpa, c);
                }
            },
            .double => {
                if (c == '"') {
                    state = .none;
                } else if (c == '\\' and i + 1 < line.len and line[i + 1] == '"') {
                    try current.append(gpa, '"');
                    i += 1;
                } else {
                    try current.append(gpa, c);
                }
            },
        }
    }

    if (state != .none) {
        return error.UnclosedQuote;
    }

    if (current.items.len > 0) {
        try tokens.append(gpa, try current.toOwnedSlice(gpa));
    }

    return tokens.toOwnedSlice(gpa);
}
