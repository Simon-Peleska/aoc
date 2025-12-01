const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
var allocator: std.mem.Allocator = undefined;

const Error = error{
    OutOfInstructions,
    InvalidInstruction,
};

const Inst = enum(u8) {
    Adv = 0,
    Blx,
    Bst,
    Jnz,
    Bxc,
    Out,
    Bdv,
    Cdv,
};

var a: u64 = 0;
var b: u64 = 0;
var c: u64 = 0;

var inst_ptr: u64 = 0;

var prog = [_]u8{ 2, 4, 1, 1, 7, 5, 4, 7, 1, 4, 0, 3, 5, 5, 3, 0 };
var output: List(u8) = undefined;

pub fn main() !void {
    var t = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    allocator = arena.allocator();

    output = List(u8).init(allocator);
    var i: u64 = 0; //36050000000;
    const add: u64 = 134217728;
    var len: u64 = 1;
    while (true) : (i += add) {
        const number_list = [_]u64{ 112208426, 112208429, 112208431 };
        for (number_list) |number| {
            a = number + i;
            b = 0;
            c = 0;

            output.clearAndFree();

            while (true) {
                b = a % 8;
                b ^= 1;
                const b_2: u6 = @truncate(b);
                c = a >> b_2;
                b ^= c;
                b ^= 4;
                a >>= 3;
                output.append(@truncate(b % 8)) catch unreachable;

                // runInst2();

                if (!std.mem.startsWith(u8, &prog, output.items)) {
                    break;
                } else if (output.items.len >= len) {
                    len = output.items.len + 1;

                    print("output: {any}\ni: {d}\n\n", .{ output.items, i + number });
                    // std.time.sleep(1 * std.time.ns_per_s);
                }
            }

            if (std.mem.eql(u8, &prog, output.items)) {
                break;
            }
        }
    }

    print("{s}\n", .{output.items});

    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn runInst2() void {
    while (a != 0) {
        b = a ^ 1;
        c = a >> b;
        b ^= c;
        b ^= 4;
        a >>= 3;
        output.append(b % 8) catch unreachable;
    }
}

fn runInst() Error!void {
    if (inst_ptr >= prog.len) return Error.OutOfInstructions;

    if (prog[inst_ptr] >= 8) return Error.InvalidInstruction;

    const inst: Inst = @enumFromInt(prog[inst_ptr]);

    // print("inst_ptr: {d}\ninst: {d}\nlit: {d}\ncombo: {d}\nA: {d}\nB: {d}\nC: {d}\noutput: {s}\n\n", .{ inst_ptr, @intFromEnum(inst), getLit() catch 999999999, getCombo() catch 999999999, a, b, c, output.items });

    switch (inst) {
        Inst.Adv => {
            const shift: u6 = @truncate(try getCombo());
            a >>= shift;

            inst_ptr += 2;
        },
        Inst.Blx => {
            b ^= try getLit();

            inst_ptr += 2;
        },
        Inst.Bst => {
            b = try getCombo() % 8;

            inst_ptr += 2;
        },
        Inst.Jnz => {
            if (a != 0) {
                inst_ptr = try getLit();
            } else {
                inst_ptr += 2;
            }
        },
        Inst.Bxc => {
            _ = try getLit();

            b ^= c;
            inst_ptr += 2;
        },
        Inst.Out => {
            const out: u8 = @truncate(try getCombo() % 8);

            // out += '0';

            // if (output.items.len != 0) {
            //     output.append(',') catch unreachable;
            // }

            output.append(out) catch unreachable;
            inst_ptr += 2;
        },
        Inst.Bdv => {
            const shift: u6 = @truncate(try getCombo());
            b = a >> shift;

            inst_ptr += 2;
        },
        Inst.Cdv => {
            const shift: u6 = @truncate(try getCombo());
            c = a >> shift;

            inst_ptr += 2;
        },
    }
}

fn getLit() Error!u64 {
    const lit_ptr = inst_ptr + 1;

    if (lit_ptr >= prog.len) return Error.OutOfInstructions;

    return @intCast(prog[lit_ptr]);
}

fn getCombo() Error!u64 {
    const combo_ptr = inst_ptr + 1;

    if (combo_ptr >= prog.len) return Error.OutOfInstructions;

    switch (prog[combo_ptr]) {
        0...3 => |lit| return lit,
        4 => return a,
        5 => return b,
        6 => return c,
        else => return Error.InvalidInstruction,
    }
}
