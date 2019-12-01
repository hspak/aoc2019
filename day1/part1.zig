const std = @import("std");

pub fn main() !void {
    var file = try std.fs.File.openRead("./input");
    defer file.close();
    var stream = &file.inStream().stream;

    var buf: [4096]u8 = undefined;
    var total_fuel: u32 = 0;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const mass = try std.fmt.parseInt(u32, line[0..], 10);
        total_fuel += mass / 3 - 2;
    }
    std.debug.warn("{}\n", total_fuel);
}
