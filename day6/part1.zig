const std = @import("std");

pub fn main() !void {
    var file = try std.fs.File.openRead("./input");
    defer file.close();
    const stream = &file.inStream().stream;

    const allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;
    var objects = std.StringHashMap([]const u8).init(allocator);

    var buf: [8]u8 = undefined;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const trimmed = std.mem.trim(u8, line, " \n\r\t");
        var it = std.mem.separate(trimmed, ")");
        const base = try std.mem.dupe(allocator, u8, it.next().?);
        const orbiter = try std.mem.dupe(allocator, u8, it.next().?);
        _ = try objects.put(orbiter, base);
    }

    var total_orbit: usize = 0;
    var it = objects.iterator();
    while (it.next()) |obj| {
        total_orbit += countOrbits(obj.key, objects);
    }
    std.debug.warn("{}\n", .{total_orbit});
}

fn countOrbits(obj: []const u8, objects: std.StringHashMap([]const u8)) usize {
    if (objects.getValue(obj)) |parent| {
        return 1 + countOrbits(parent, objects);
    }
    return 0;
}
