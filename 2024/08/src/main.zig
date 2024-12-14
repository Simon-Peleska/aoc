const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 50;
// const size = 10;
const ArrayList = std.ArrayList;
const SinglyLinkedList = std.SinglyLinkedList;

const Coordinate = struct { x: u8, y: u8 };

pub fn main() !void {
    var t = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
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

        var number_list = SinglyLinkedList(u64){};
        while (line_array.next()) |number_string| {
            var number_node = SinglyLinkedList(u64).Node{ .data = try parseInt(u64, number_string, 10) };
            number_list.prepend(&number_node);
        }

        const node = number_list.first;
        for (0..25) |_| {
            while (node) |number_node_pointer| {
                var number_node = number_node_pointer.*;
                if (number_node.data == 0) {
                    number_node.data = 1;
                    break;
                }

                const number_string = try std.fmt.bufPrint(&buf, "{d}", .{number_node.data});

                if (number_string.len % 2 == 0) {
                    number_node.data = try parseInt(u64, number_string[0..(@divFloor(number_string.len, 2))], 10);

                    var new_node = SinglyLinkedList(u64).Node{ .data = try parseInt(u64, number_string[(@divFloor(number_string.len, 2))..number_string.len], 10) };
                    number_list.prepend(&new_node);
                } else {
                    number_node.data *= 2024;
                }
            }
        }

        print("{d}\n", .{number_list.len()});
    }

    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

pub fn charToDigit(c: u8) u8 {
    const value = switch (c) {
        '0'...'9' => c - '0',
        'A'...'Z' => c - 'A' + 10,
        'a'...'z' => c - 'a' + 36,
        else => unreachable,
    };

    return value;
}
