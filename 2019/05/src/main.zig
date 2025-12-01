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

    var memory_list = List([]u8).init(allocator);

    var it = std.mem.split(u8, input[0 .. input.len - 1], ",");

    while (it.next()) |number| {
        try memory_list.append(number);
    }

    var memory: []u64 = undefined;

    var i: u64 = 0;
    // var noun: u64 = 0;
    // var verb: u64 = 0;

    const local_memory_list = try memory_list.clone();
    memory = local_memory_list.items;
    i = 0;
    var stack = List(u64).init(allocator);

    while (true) {
        if (i >= memory.len) return Error.InstructionPointerTooBig;

        const inst = memory[i] % 10;

        if (inst.len == 2 and inst[0] == '9' and inst[1] == '9') break;

        std.debug.print("inst {d} {d}\n", .{ inst, memory[0] });
        i += 1;

        switch (inst[inst.len - 1]) {
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
            3 => {
                const number1 = memory[i];
                i += 1;

                memory[number1] = stack.pop();
            },
            4 => {
                const number1 = memory[i];
                i += 1;

                stack.append(memory[number1]);
            },
            9 => break,
            else => return Error.InvalidInstruction,
        }
    }
    std.debug.print("a\n", .{});

    std.debug.print("count {d}\n", .{noun * 100 + verb});
    std.debug.print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
