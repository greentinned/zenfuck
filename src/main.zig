const std = @import("std");

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const args = try std.process.argsAlloc(&arena.allocator);
    var input = std.ArrayList(u8).init(&arena.allocator);

    // read file

    if (args.len > 1) {
        const file = try std.fs.openFileAbsolute(args[1], .{ .read = true });
        defer file.close();

        try file.reader().readAllArrayList(&input, 30_000);
    } else {
        _ = try stdin.readAllArrayList(&input, 30_000);
    }

    try stdout.print("program: \n\n{}\n", .{input.items});

    // run input

    var tape = std.ArrayList(u8).init(&arena.allocator);
    try tape.append(0);

    _ = try run(false, &tape, input.items);
}

var code_pos: u32 = 0;
var tape_pos: u32 = 0;

const RunError = error{ Invalid, InvalidOp };

fn run(skip: bool, tape: *std.ArrayList(u8), code: []const u8) RunError!bool {
    while (tape_pos >= 0 and code_pos < code.len) : (code_pos += 1) {

        // grow tape
        if (tape_pos >= tape.items.len) {
            try tape.append(0) catch |_| error.Invalid;
        }

        if (code[code_pos] == '[') {
            code_pos += 1;
            const old_code_pos = code_pos;

            while (try run(tape.items[tape_pos] == 0, tape, code)) {
                code_pos = old_code_pos;
            }
        } else if (code[code_pos] == ']') {
            return tape.items[tape_pos] != 0;
        } else if (!skip) {
            switch (code[code_pos]) {
                '+' => {
                    // inc value on current tap_pos
                    tape.items[tape_pos] = tape.items[tape_pos] + 1;
                },
                '-' => {
                    // dec value on current tap_pos
                    tape.items[tape_pos] = tape.items[tape_pos] - 1;
                },
                '.' => {
                    // write to stdout
                    try stdout.print("{c}", .{tape.items[tape_pos]}) catch |_| error.Invalid;
                },
                ',' => {
                    // read from stdin
                    tape.items[tape_pos] = try stdin.readByte() catch |_| error.Invalid;
                },
                '>' => tape_pos += 1,
                '<' => tape_pos -= 1,
                else => continue,
            }
        }
    }
    return false;
}
