const std = @import("std");

var allocator: *std.mem.Allocator = undefined;

const ProgError = error{Finished};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();
    allocator = &arena.allocator;

    var file = try std.fs.File.openRead("./input1");
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
    try execute(&prog, counter);
    print(prog, counter);
}

fn execute(prog: *[4096]u32, size: u32) !void {
    var inst: u32 = undefined;
    var pos1: u32 = undefined;
    var pos2: u32 = undefined;
    var pos_out: u32 = undefined;
    var result: u32 = undefined;
    var full = false;
    var counter: u32 = 0;
    while (counter < size) {
        if (counter % 4 == 0) {
            if (full) {
                result = try subtask(prog, inst, pos1, pos2);
                prog[pos_out] = result;
                full = false;
            }
            inst = prog[counter];
        } else if (counter % 4 == 1) {
            pos1 = prog[counter];
        } else if (counter % 4 == 2) {
            pos2 = prog[counter];
        } else if (counter % 4 == 3) {
            pos_out = prog[counter];
            full = true;
        } else {
            unreachable;
        }
        counter += 1;
    }
}

fn subtask(prog: *[4096]u32, inst: u32, pos1: u32, pos2: u32) !u32 {
    var result: u32 = undefined;
    if (inst == 1) {
        result = prog[pos1] + prog[pos2];
    } else if (inst == 2) {
        result = prog[pos1] * prog[pos2];
    } else if (inst == 99) {
        return ProgError.Finished;
    } else {
        unreachable;
    }
    return result;
}

fn print(prog: [4096]u32, size: u32) void {
    var i: u32 = 0;
    while (i < size) {
        std.debug.warn("{}: {}\n", i, prog[i]);
        i += 1;
    }
}
