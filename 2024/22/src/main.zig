const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
const StringMap = std.StringArrayHashMap;
var allocator: std.mem.Allocator = undefined;

const input = "input";

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

    var buf: [10]u8 = undefined;
    var map = Map(u32, u32).init(allocator);
    defer map.clearAndFree();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var secret: u24 = try parseInt(u24, line, 10);

        var prev_price = secret % 10;

        var sequence: u32 = 0x00000000;
        var map2 = Map(u32, u32).init(allocator);
        defer map2.clearAndFree();

        for (0..2000) |i| {
            secret ^= (secret << 6);
            secret ^= (secret >> 5);
            secret ^= (secret << 11);

            const price = secret % 10;

            sequence <<= 8;

            const diff = 9 + price - prev_price;

            sequence += diff;

            if (i >= 1 and map2.get(sequence) == null) {
                try map2.put(sequence, price);
            }

            prev_price = price;
        }

        var iter = map2.iterator();

        while (iter.next()) |entry| {
            const key = entry.key_ptr.*;
            const value2 = entry.value_ptr.*;

            if (map.get(key)) |value| {
                try map.put(key, value + value2);
            } else {
                try map.put(key, value2);
            }
        }
    }

    var count: u64 = 0;
    for (map.keys()) |key| {
        if (map.get(key).? > 1600) print("{x:0>8} {d}\n", .{ key, map.get(key).? });
    }

    for (map.values()) |value| {
        if (value > count) {
            count = value;
        }
    }

    file.close();

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
