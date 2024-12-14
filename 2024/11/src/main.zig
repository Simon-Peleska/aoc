const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 50;
// const size = 10;
const ArrayList = std.ArrayList;
const SinglyLinkedList = std.SinglyLinkedList(u64);
const Node = SinglyLinkedList.Node;

const Coordinate = struct { x: u8, y: u8 };

pub fn main() !void {
    var t = try std.time.Timer.start();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var is_2 = false;

    var input = ArrayList(u8).init(allocator);
    try input.insertSlice(0, "input");
    defer input.deinit();

    for (args) |arg| {
        if (std.mem.startsWith(u8, arg, "--input=")) {
            input.clearRetainingCapacity();

            try input.insertSlice(0, arg[8..]);
        }
        if (std.mem.eql(u8, arg, "-2")) {
            is_2 = true;
            break;
        }
    }

    var file = try std.fs.cwd().openFile(input.items, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [40]u8 = undefined;

    if (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_array = std.mem.splitScalar(u8, line, ' ');

        var map = std.AutoHashMap(u64, u64).init(allocator);

        defer {}

        while (line_array.next()) |number_string| {
            try map.put(try parseInt(u64, number_string, 10), 1);
        }

        for (0..75) |_| {
            var new_map = std.AutoHashMap(u64, u64).init(allocator);

            var iterator = map.iterator();

            while (iterator.next()) |entry| {
                const number = entry.key_ptr.*;

                if (number == 0) {
                    if (new_map.get(1)) |local_value| {
                        try new_map.put(1, local_value + entry.value_ptr.*);
                    } else {
                        try new_map.put(1, entry.value_ptr.*);
                    }
                } else {
                    const number_string = try std.fmt.bufPrint(&buf, "{d}", .{number});

                    if (number_string.len % 2 == 0) {
                        const number1 = try parseInt(u64, number_string[0..(@divFloor(number_string.len, 2))], 10);
                        const number2 = try parseInt(u64, number_string[(@divFloor(number_string.len, 2))..number_string.len], 10);

                        if (new_map.get(number1)) |local_value| {
                            try new_map.put(number1, local_value + entry.value_ptr.*);
                        } else {
                            try new_map.put(number1, entry.value_ptr.*);
                        }

                        if (new_map.get(number2)) |local_value| {
                            try new_map.put(number2, local_value + entry.value_ptr.*);
                        } else {
                            try new_map.put(number2, entry.value_ptr.*);
                        }
                    } else {
                        if (new_map.get(number * 2024)) |local_value| {
                            try new_map.put(number * 2024, local_value + entry.value_ptr.*);
                        } else {
                            try new_map.put(number * 2024, entry.value_ptr.*);
                        }
                    }
                }
            }

            map.clearAndFree();

            map = try new_map.clone();

            new_map.clearAndFree();
        }

        var iterator = map.iterator();

        var count: u64 = 0;

        while (iterator.next()) |entry| {
            count += entry.value_ptr.*;
        }

        map.clearAndFree();

        print("{d}\n", .{count});
    }

    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
