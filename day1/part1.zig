const std = @import("std");
const fs = std.fs;
const io = std.io;
const warn = std.debug.warn;

var allocator: *std.mem.Allocator = undefined;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();
    allocator = &arena.allocator;

    var file = try fs.File.openRead("./input");
    defer file.close();
    var stream = &file.inStream().stream;

    var buf: [4096]u8 = undefined;
    var total_fuel: u32 = 0;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const mass = try std.fmt.parseInt(u32, line[0..], 10);
        total_fuel += @divFloor(mass, 3) - 2;
    }
    warn("{}\n", total_fuel);
}
