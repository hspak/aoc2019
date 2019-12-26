const std = @import("std");

const ProgError = error{Finished};

pub fn main() !void {
    var file = try std.fs.File.openRead("./input");
    defer file.close();
    var stream = &file.inStream().stream;

    var buf: [4096]u8 = undefined;
    var prog: [4096]u32 = undefined;
    var counter: u32 = 0;
    while (try stream.readUntilDelimiterOrEof(&buf, ',')) |line| {
        const val = std.fmt.parseInt(u32, line[0..], 10) catch break;
        prog[counter] = val;
        counter += 1;
    }
    var orig: [4096]u32 = undefined;
    std.mem.copy(u32, orig[0..], prog[0..]);
    var val1: u32 = 0;
    while (val1 < 4000) {
        var val2: u32 = 0;
        while (val2 < 4000) {
            _ = execute(&prog, counter);
            if (prog[0] == 19690720) {
                std.debug.warn("{}{}\n", .{ prog[1], prog[2] });
                std.os.exit(0);
            }
            std.mem.copy(u32, prog[0..], orig[0..]);
            prog[1] = val1;
            val2 += 1;
            prog[2] = val2;
        }
        val1 += 1;
        prog[1] = val1;
    }
}

fn execute(prog: *[4096]u32, size: u32) u32 {
    var counter: u32 = 0;
    while (counter < size) {
        var inst = prog[counter];
        var pos1 = prog[counter + 1];
        var pos2 = prog[counter + 2];
        var pos_out = prog[counter + 3];
        const result = switch (inst) {
            1 => prog[pos1] + prog[pos2],
            2 => prog[pos1] * prog[pos2],
            99 => return prog[0],
            else => unreachable,
        };
        prog[pos_out] = result;
        counter += 4;
    }
    unreachable;
}
