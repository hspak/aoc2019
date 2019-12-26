const std = @import("std");
const math = std.math;

// TODO: need to figure out how to allocate a 2D array
// currently ulimit hacking to give me massive stacks
const XLen = 15000;
const YLen = 24000;
const XOrigin = 8000;
const YOrigin = 14000;

const Grid = struct {
    // X, y
    slots: [XLen][YLen]u1,
    x: u32 = XOrigin,
    y: u32 = YOrigin,

    pub fn init() Grid {
        var intermediate: [XLen][YLen]u1 = undefined;
        var x: u32 = 0;
        while (x < XLen) {
            var y: u32 = 0;
            while (y < YLen) {
                intermediate[x][y] = 0;
                y += 1;
            }
            x += 1;
        }
        return Grid{
            .slots = intermediate,
        };
    }

    pub fn markLine(self: *Grid, path: Path) void {
        switch (path.direction) {
            'U' => {
                var i: u32 = 0;
                while (i < path.length) {
                    self.y += 1;
                    self.mark();
                    i += 1;
                }
            },
            'D' => {
                var i: u32 = 0;
                while (i < path.length) {
                    self.y -= 1;
                    self.mark();
                    i += 1;
                }
            },
            'L' => {
                var i: u32 = 0;
                while (i < path.length) {
                    self.x -= 1;
                    self.mark();
                    i += 1;
                }
            },
            'R' => {
                var i: u32 = 0;
                while (i < path.length) {
                    self.x += 1;
                    self.mark();
                    i += 1;
                }
            },
            else => unreachable,
        }
    }

    fn mark(self: *Grid) void {
        std.debug.warn("mark: ({}, {})\n", .{ self.x, self.y });
        self.slots[self.x][self.y] = 1;
    }
};

const Wire = struct {
    paths: [4096]Path,
    size: u32,
};

const Path = struct {
    length: u32,
    direction: u8,
};

pub fn main() !void {
    var file = try std.fs.File.openRead("./input");
    defer file.close();
    var stream = &file.inStream().stream;

    var buf: [4096]u8 = undefined;
    var first = true;
    var wire1: Wire = undefined;
    var wire2: Wire = undefined;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (first) {
            try parsePath(&wire1, line);
            first = false;
        } else {
            try parsePath(&wire2, line);
        }
    }
    var dist = findCentralIntersectionDist(wire1, wire2);
    std.debug.warn("{}\n", .{dist});
}

fn parsePath(wire: *Wire, line: []u8) !void {
    var line_it = std.mem.separate(line, ",");
    var i: u32 = 0;
    while (line_it.next()) |path| {
        wire.paths[i] = Path{
            .length = try std.fmt.parseInt(u32, path[1..], 10),
            .direction = path[0],
        };
        i += 1;
    }
    wire.size = i;
}

fn findCentralIntersectionDist(wire1: Wire, wire2: Wire) u32 {
    var grid1 = Grid.init();
    var i: u32 = 0;
    while (i < wire1.size) {
        grid1.markLine(wire1.paths[i]);
        i += 1;
    }
    var grid2 = Grid.init();
    i = 0;
    while (i < wire2.size) {
        grid2.markLine(wire2.paths[i]);
        i += 1;
    }
    var candidate: u32 = math.maxInt(u32);
    var x: u32 = 0;
    while (x < XLen) {
        var y: u32 = 0;
        while (y < YLen) {
            if (grid1.slots[x][y] == 1 and grid2.slots[x][y] == 1) {
                var dist = distFromOrigin(x, y);
                std.debug.warn("candidate: ({}, {}): {} vs {}\n", .{ x, y, candidate, dist });
                if (dist < candidate) {
                    candidate = dist;
                }
            }
            y += 1;
        }
        x += 1;
    }
    return candidate;
}

fn distFromOrigin(x: u32, y: u32) u32 {
    const y_half = if (y > YOrigin) y - YOrigin else YOrigin - y;
    const x_half = if (x > XOrigin) x - XOrigin else XOrigin - x;
    return x_half + y_half;
}
