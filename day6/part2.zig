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

    var san_list = std.ArrayList([]const u8).init(allocator);
    var you_list = std.ArrayList([]const u8).init(allocator);
    var it = objects.iterator();
    while (it.next()) |obj| {
        try countOrbits(&san_list, "SAN", obj.key, objects);
        try countOrbits(&you_list, "YOU", obj.key, objects);
    }

    var counter = std.StringHashMap(usize).init(allocator);
    {
        var i: usize = 0;
        while (i < you_list.len) : (i += 1) {
            _ = try counter.put(you_list.items[i], 1);
        }
    }
    {
        var i: usize = 0;
        while (i < san_list.len) : (i += 1) {
            if (counter.getValue(san_list.items[i])) |val| {
                _ = try counter.put(san_list.items[i], val + 1);
            } else {
                _ = try counter.put(san_list.items[i], 1);
            }
        }
    }
    var iter = counter.iterator();
    var total: usize = 0;
    while (iter.next()) |item| {
        if (item.value == 1) {
            total += 1;
        }
    }
    std.debug.warn("{}\n", .{total});
}

fn countOrbits(list: *std.ArrayList([]const u8), find: []const u8, obj: []const u8, objects: std.StringHashMap([]const u8)) !void {
    if (objects.getValue(obj)) |parent| {
        countOrbits(list, find, parent, objects) catch unreachable;
        if (std.mem.eql(u8, obj, find)) {
            try list.append(parent);
            var par = parent;
            while (objects.getValue(par)) |pp| {
                try list.append(pp);
                countOrbits(list, find, pp, objects) catch unreachable;
                par = pp;
            }
            return;
        }
    }
}
