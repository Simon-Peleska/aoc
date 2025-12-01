const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
var allocator: std.mem.Allocator = undefined;
const input = "input5";

const Coordinate = packed struct { x: u8, y: u8 };

pub fn main() !void {
    var t = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    allocator = arena.allocator();

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // allocator = gpa.allocator();
    // defer _ = gpa.deinit();

    // const args = try std.process.argsAlloc(allocator);
    // var is_2 = false;

    // for (args) |arg| {
    //     if (std.mem.eql(u8, arg, "-2")) {
    //         is_2 = true;
    //         break;
    //     }
    // }

    var file = try std.fs.cwd().openFile(input, .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    const array_size = 0xfeffff;
    var array: [array_size]?bool = .{null} ** array_size;
    var buf: [40]u8 = undefined;

    const x = std.crypto.random.int(u45) >> 1;
    const y = std.crypto.random.int(u45) >> 1;

    const z: u45 = x + y;
    print("x: {b}\n", .{x});
    print("y: {b}\n", .{y});
    for (0..45) |i| {
        const index: u45 = @intCast(i);
        const power = try std.math.powi(u45, 2, index);

        const x_key_str: []u8 = try std.fmt.bufPrint(&buf, "x{d:0>2}", .{i});
        const x_key: u24 = @bitCast(x_key_str[0..3].*);
        array[x_key] = x & power == power;
        print("{s} {d}\n", .{ x_key_str, x & power });

        const y_key_str: []u8 = try std.fmt.bufPrint(&buf, "y{d:0>2}", .{i});
        const y_key: u24 = @bitCast(y_key_str[0..3].*);
        array[y_key] = y & power == power;
        // print("{s} {d}\n", .{ y_key_str, y & power });
    }

    var list = List([18]u8).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) continue;

        try list.append(line[0..18].*);
    }

    var i: u64 = 0;

    while (list.items.len > i) : (i += 1) {
        var line = list.items[i];

        const id1: u24 = @bitCast(line[0..3].*);
        const id2: u24 = @bitCast(line[8..11].*);
        const id3: u24 = @bitCast(line[15..18].*);

        const command: u8 = line[4];

        if (array[id1] != null and array[id2] != null) {
            array[id3] = switch (command) {
                'A' => array[id1].? and array[id2].?,
                'O' => array[id1].? or array[id2].?,
                'X' => array[id1].? != array[id2].?,
                else => unreachable,
            };
            print("{s} {s} {s} -> {s}\n", .{ line[0..3], line[4..7], line[8..11], line[15..18] });
        } else {
            std.time.sleep(std.time.ns_per_ms * 100);
            print("failed: {s}\n", .{line});

            try list.append(line);
        }
    }

    // const z01 = "z01";

    var number: u64 = 0;

    for (0..46) |j| {
        var buf1: [3]u8 = undefined;

        const a = try std.fmt.bufPrint(&buf1, "z{d:0>2}", .{45 - j});
        const b: u24 = @bitCast(a[0..3].*);
        number <<= 1;
        number += @intFromBool(array[b].?);
    }
    const diff: u64 = number ^ z;

    file.close();

    print("count {b} {b} {d}\n", .{ diff, number, number });
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
