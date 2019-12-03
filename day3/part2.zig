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
    steps: u32 = 0,

    // I'm cheating lol
    candidates_x: [7]u16 = [_]u16{ 6820, 6994, 7007, 7122, 7122, 7900, 8232 },
    candidates_y: [7]u16 = [_]u16{ 13656, 13656, 13656, 13492, 13506, 13473, 13473 },
    candidates_steps: [7]u32 = undefined,

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
        self.steps += 1;
        self.slots[self.x][self.y] = 1;

        var i: u8 = 0;
        while (i < 7) {
            if (self.x == self.candidates_x[i] and self.y == self.candidates_y[i]) {
                std.debug.warn("({}, {}) steps: {}\n", self.x, self.y, self.steps);
                self.candidates_steps[i] = self.steps;
                break;
            }
            i += 1;
        }
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
    var dist = findFastestIntersection(wire1, wire2);
    std.debug.warn("{}\n", dist);
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

fn findFastestIntersection(wire1: Wire, wire2: Wire) u32 {
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
    i = 0;
    while (i < 7) {
        var newcomer = grid1.candidates_steps[i] + grid2.candidates_steps[i];
        std.debug.warn("new {}\n", newcomer);
        if (newcomer < candidate) {
            candidate = newcomer;
        }
        i += 1;
    }
    return candidate;
}
