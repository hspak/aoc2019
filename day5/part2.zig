const std = @import("std");

const Instruction = struct {
    opcode: isize,
    pos1_mode: isize,
    pos2_mode: ?isize,
    pos3_mode: ?isize,
};

pub fn main() !void {
    var file = try std.fs.File.openRead("./input");
    defer file.close();
    var stream = &file.inStream().stream;

    var buf: [4096]u8 = undefined;
    var prog: [4096]isize = undefined;
    var counter: usize = 0;
    while (try stream.readUntilDelimiterOrEof(&buf, ',')) |line| {
        const trimmed = std.mem.trim(u8, line, " \n\r\t");
        const val = try std.fmt.parseInt(isize, trimmed, 10);
        prog[counter] = val;
        counter += 1;
    }
    try execute(&prog, counter);
}

fn execute(prog: *[4096]isize, size: usize) !void {
    var counter: usize = 0;
    while (counter < size) {
        var inst = parseInstruction(prog[counter]);
        counter += 1;
        var pos1: isize = undefined;
        var pos2: isize = undefined;
        var pos3: isize = undefined;
        switch (inst.opcode) {
            1, 2 => {
                pos1 = prog[counter];
                counter += 1;
                pos2 = prog[counter];
                counter += 1;
                pos3 = prog[counter];
                counter += 1;
                const param1 = if (inst.pos1_mode == 0) prog[@intCast(usize, pos1)] else pos1;
                const param2 = if (inst.pos2_mode == null or inst.pos2_mode.? == 0) prog[@intCast(usize, pos2)] else pos2;
                if (inst.opcode == 1) {
                    prog[@intCast(usize, pos3)] = param1 + param2;
                } else if (inst.opcode == 2) {
                    prog[@intCast(usize, pos3)] = param1 * param2;
                }
            },
            3 => {
                const stdout = &std.io.getStdOut().outStream().stream;
                try stdout.print("Input: ");
                const file = std.io.getStdIn();
                const stream = &file.inStream().stream;
                var buf: [16]u8 = undefined;
                var line = try stream.readUntilDelimiterOrEof(&buf, '\n');
                const input = try std.fmt.parseInt(isize, line.?, 10);
                pos1 = prog[counter];
                counter += 1;
                prog[@intCast(usize, pos1)] = input;
            },
            4 => {
                pos1 = prog[counter];
                counter += 1;
                const stdout = &std.io.getStdOut().outStream().stream;
                try stdout.print("{}\n", prog[@intCast(usize, pos1)]);
            },
            5, 6 => {
                pos1 = prog[counter];
                counter += 1;
                pos2 = prog[counter];
                counter += 1;
                const param1 = if (inst.pos1_mode == 0) prog[@intCast(usize, pos1)] else pos1;
                const param2 = if (inst.pos2_mode == null or inst.pos2_mode.? == 0) prog[@intCast(usize, pos2)] else pos2;
                if (param1 != 0 and inst.opcode == 5) {
                    counter = @intCast(usize, param2);
                } else if (param1 == 0 and inst.opcode == 6) {
                    counter = @intCast(usize, param2);
                }
            },
            7, 8 => {
                pos1 = prog[counter];
                counter += 1;
                pos2 = prog[counter];
                counter += 1;
                pos3 = prog[counter];
                counter += 1;
                const param1 = if (inst.pos1_mode == 0) prog[@intCast(usize, pos1)] else pos1;
                const param2 = if (inst.pos2_mode == null or inst.pos2_mode.? == 0) prog[@intCast(usize, pos2)] else pos2;
                if (inst.opcode == 7) {
                    prog[@intCast(usize, pos3)] = if (param1 < param2) 1 else 0;
                } else if (inst.opcode == 8) {
                    prog[@intCast(usize, pos3)] = if (param1 == param2) 1 else 0;
                }
            },
            99 => return,
            else => {
                std.debug.warn("invalid instruction found: {}\n", inst);
                return error.InvalidInstruction;
            },
        }
    }
    return error.InvalidProgram;
}

fn parseInstruction(inst: isize) Instruction {
    var opcode: isize = @mod(inst, 100);
    var pos1_mode: isize = @divFloor(@mod(inst, 1000), 100);
    var pos2_mode: ?isize = if (inst > 1000) @divFloor(@mod(inst, 10000), 1000) else null;
    var pos3_mode: ?isize = if (inst > 10000) @divFloor(@mod(inst, 100000), 10000) else null;
    return Instruction{
        .opcode = opcode,
        .pos1_mode = pos1_mode,
        .pos2_mode = pos2_mode,
        .pos3_mode = pos3_mode,
    };
}
