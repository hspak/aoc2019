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
    var total_fuel: i32 = 0;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const mass = try std.fmt.parseInt(i32, line[0..], 10);
        const fuel_for_module = @divFloor(mass, 3) - 2;
        total_fuel += fuel_for_module;

        var fuel_for_fuel: i32 = fuel_for_module;
        while (true) {
            fuel_for_fuel = @divFloor(fuel_for_fuel, 3) - 2;
            if (fuel_for_fuel <= 0) {
                break;
            }
            total_fuel += fuel_for_fuel;
        }
    }
    warn("{}\n", total_fuel);
}
