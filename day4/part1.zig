const std = @import("std");

pub fn main() anyerror!void {
    const allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;
    const out = &std.io.getStdOut().outStream().stream;

    const limit = 1 * 1024 * 1024 * 1024;
    const range = try std.fs.cwd().readFileAlloc(allocator, "input", limit);

    var it = std.mem.separate(range, "-");
    var start: usize = undefined;
    var end: usize = undefined;
    var first = true;
    while (it.next()) |val| {
        const trimmed = std.mem.trim(u8, val, " \n\r\t");
        if (first) {
            start = try std.fmt.parseInt(usize, trimmed, 10);
            first = false;
        } else {
            end = try std.fmt.parseInt(usize, trimmed, 10);
        }
    }
    try out.print("count: {}\n", countPasswords(start, end));
}

fn countPasswords(start: usize, end: usize) usize {
    var pos: usize = 0;
    var range: usize = end - start + 1;
    var count: usize = 0;
    while (pos < range) : (pos += 1) {
        const candidate = pos + start;
        if (checkTwoAdjacent(candidate) and checkAscending(candidate)) {
            count += 1;
        }
    }
    return count;
}

fn checkTwoAdjacent(candidate: usize) bool {
    var last_digit: usize = 10;
    var pos: usize = 1;
    while (pos < 1000000) : (pos *= 10) {
        const digit = candidate % (pos * 10) / pos;
        if (last_digit == digit) {
            return true;
        }
        last_digit = digit;
    }
    return false;
}

fn checkAscending(candidate: usize) bool {
    var last_digit: usize = 10;
    var pos: usize = 1;
    while (pos < 1000000) : (pos *= 10) {
        const digit = candidate % (pos * 10) / pos;
        if (digit > last_digit) {
            return false;
        }
        last_digit = digit;
    }
    return true;
}
