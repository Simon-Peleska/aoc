const std = @import("std");
const List = std.ArrayList;
const input = @embedFile("./input");
const parseInt = std.fmt.parseInt;
const Error = error{ InstructionPointerTooBig, InvalidInstruction };

pub fn main() !void {
    var t = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var memory_list = List(u64).init(allocator);

    var it = std.mem.split(u8, input[0 .. input.len - 1], ",");

    while (it.next()) |n| {
        const number = try parseInt(u64, n, 10);
        try memory_list.append(number);
    }

    var memory: []u64 = undefined;

    var i: u64 = 0;
    var noun: u64 = 0;
    var verb: u64 = 0;

    for (0..100) |j| {
        for (0..100) |k| {
            const local_memory_list = try memory_list.clone();
            memory = local_memory_list.items;
            i = 0;
            memory[1] = k;
            memory[2] = j;

            while (true) {
                if (i >= memory.len) {
                    break;
                }

                const inst = memory[i];
                std.debug.print("inst {d} {d} {d} {d}\n", .{ inst, j, k, memory[0] });
                i += 1;

                switch (inst) {
                    1 => {
                        const number1 = memory[i];
                        i += 1;
                        const number2 = memory[i];
                        i += 1;
                        const number3 = memory[i];
                        i += 1;

                        memory[number3] = memory[number1] + memory[number2];
                    },
                    2 => {
                        const number1 = memory[i];
                        i += 1;
                        const number2 = memory[i];
                        i += 1;
                        const number3 = memory[i];
                        i += 1;

                        memory[number3] = memory[number1] * memory[number2];
                    },
                    99 => break,
                    else => break,
                }
            }
            std.debug.print("a\n", .{});

            if (memory[0] == 19690720 and memory[i - 1] == 99) {
                std.debug.print("noun {d}\n", .{k});
                noun = k;
                break;
            }
        }

        if (memory[0] == 19690720 and memory[i - 1] == 99) {
            std.debug.print("verb {d}\n", .{j});
            verb = j;
            break;
        }
    }

    std.debug.print("count {d}\n", .{noun * 100 + verb});
    std.debug.print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
