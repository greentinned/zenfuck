const std = @import("std");

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const args = try std.process.argsAlloc(&arena.allocator);

    for (args) |arg, i| {
        try stdout.print("zenfuck> {}: {}\n", .{ i, arg });
    }

    // -----------------------------------------------------

    var tape = std.ArrayList(u8).init(&arena.allocator);
    try tape.append(@as(u8, 0));
    _ = run(&tape.items, ">><"[0..]);
}

var code_pos: u32 = 0;
var tape_pos: u32 = 0;

fn run(tape: *[]u8, code: []const u8) bool {
    while (tape_pos >= 0 and code_pos < code.len) : (code_pos += 1) {
        switch (code[code_pos]) {
            '+' => {
                // inc value on current tap_pos
            },
            '-' => {
                // dec value on current tap_pos
            },
            '.' => {
                // write to stdout
            },
            ',' => {
                // read from stdin
            },
            '>' => tape_pos += 1,
            '<' => tape_pos -= 1,
            else => break,
        }

        std.log.info("code_pos: {}, tape_pos: {}", .{ code_pos, tape_pos });
    }
    return false;
}
