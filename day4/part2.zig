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
    try out.print("count: {}\n", .{countPasswords(start, end)});
}

fn countPasswords(start: usize, end: usize) usize {
    var pos: usize = 0;
    var range: usize = end - start + 1;
    var count: usize = 0;
    while (pos < range) : (pos += 1) {
        const candidate = pos + start;
        if (checkAscending(candidate) and checkDoubleAdjacent(candidate)) {
            count += 1;
        }
    }
    return count;
}

fn checkDoubleAdjacent(candidate: usize) bool {
    var last_digit: usize = 10;
    var adj: usize = 1;
    var pos: usize = 1;
    while (pos < 1000000) : (pos *= 10) {
        const digit = candidate % (pos * 10) / pos;
        if (last_digit == digit) {
            adj += 1;
        } else {
            if (adj == 2) {
                return true;
            }
            last_digit = digit;
            adj = 1;
        }
    }
    return adj == 2;
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

test "checkDoubleAdjacent" {
    var candidate: usize = 123456;
    std.testing.expect(checkAscending(candidate));
    candidate = 223344;
    std.testing.expect(checkAscending(candidate));

    candidate = 123452;
    std.testing.expect(!checkAscending(candidate));
    candidate = 612345;
    std.testing.expect(!checkAscending(candidate));
}

test "fail checkDoubleAdjacent 6" {
    var candidate: usize = 111111;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 44" {
    var candidate: usize = 112311;
    std.testing.expect(checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 4" {
    var candidate: usize = 111123;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "checkDoubleAdjacent 2" {
    var candidate: usize = 112345;
    std.testing.expect(checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 1" {
    var candidate: usize = 123456;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 3" {
    var candidate: usize = 111345;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 5" {
    var candidate: usize = 111112;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 4a" {
    var candidate: usize = 122223;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 4b" {
    var candidate: usize = 123333;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "checkDoubleAdjacent 4c" {
    var candidate: usize = 331233;
    std.testing.expect(checkDoubleAdjacent(candidate));
}
test "checkDoubleAdjacent 2a" {
    var candidate: usize = 123345;
    std.testing.expect(checkDoubleAdjacent(candidate));
}
test "checkDoubleAdjacent 2b" {
    var candidate: usize = 123445;
    std.testing.expect(checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 1b" {
    var candidate: usize = 121212;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 1c" {
    var candidate: usize = 131456;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
test "fail checkDoubleAdjacent 2d" {
    var candidate: usize = 121210;
    std.testing.expect(!checkDoubleAdjacent(candidate));
}
