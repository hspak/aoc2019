const std = @import("std");

pub fn main() !void {
    var file = try std.fs.File.openRead("./input");
    defer file.close();
    var stream = &file.inStream().stream;

    var buf: [4096]u8 = undefined;
    var total_fuel: u32 = 0;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const mass = try std.fmt.parseInt(u32, line[0..], 10);
        const fuel_for_module = mass / 3 - 2;
        total_fuel += fuel_for_module;

        var fuel_for_fuel: u32 = fuel_for_module;
        while (fuel_for_fuel > 6) {
            fuel_for_fuel = fuel_for_fuel / 3 - 2;
            total_fuel += fuel_for_fuel;
        }
    }
    std.debug.warn("{}\n", .{total_fuel});
}
