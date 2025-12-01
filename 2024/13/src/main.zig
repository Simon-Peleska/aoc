const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size: u8 = 23;
// const size = 10;

const ResultField = struct { character: u8 };

pub fn main() !void {
    var t = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    var is_2 = false;

    for (args) |arg| {
        if (std.mem.eql(u8, arg, "-2")) {
            is_2 = true;
            break;
        }
    }

    var file = try std.fs.cwd().openFile("input", .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [size + 1]u8 = undefined;

    var full_count: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const a_x: i64 = try parseInt(i64, line[0..2], 10);
        const a_y: i64 = try parseInt(i64, line[3..5], 10);
        const b_x: i64 = try parseInt(i64, line[6..8], 10);
        const b_y: i64 = try parseInt(i64, line[9..11], 10);
        const result_x: i64 = try parseInt(i64, line[12..17], 10) + 10000000000000;
        const result_y: i64 = try parseInt(i64, line[18..23], 10) + 10000000000000;

        full_count += testCalculation(a_x, a_y, b_x, b_y, result_x, result_y);
    }

    file.close();

    print("\n{d}\n", .{full_count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn testCalculation(a_x: i64, a_y: i64, b_x: i64, b_y: i64, result_x: i64, result_y: i64) u64 {
    const number1: f64 = @floatFromInt((b_x * result_y) - (b_y * result_x));
    const number2: f64 = @floatFromInt((b_x * a_y) - (a_x * b_y));
    const number3: f64 = @floatFromInt((a_y * result_x) - (a_x * result_y));
    const a: f64 = (number1 / number2);
    const b: f64 = (number3 / number2);

    if (@rem(a, 1) != 0 or @rem(b, 1) != 0 or a < 0 or b < 0) {
        return 0;
    }

    const a_int: u64 = @intFromFloat(a);
    const b_int: u64 = @intFromFloat(b);

    const cost = a_int * 3 + b_int;
    return cost;
}
