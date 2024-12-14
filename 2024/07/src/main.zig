const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 45;
const ArrayList = std.ArrayList;
// const size = 10;
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

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [size + 1]u8 = undefined;
    var count: u64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_iterator = std.mem.splitSequence(u8, line, ": ");
        const result = try parseInt(u64, line_iterator.next().?, 10);

        const numbers_string = line_iterator.next().?;
        var numbers_iterator = std.mem.splitScalar(u8, numbers_string, ' ');
        var numbers = try std.ArrayList(u16).initCapacity(allocator, 16);

        while (numbers_iterator.next()) |number_string| {
            numbers.appendAssumeCapacity(try parseInt(u16, number_string, 10));
        }

        // print("\n{s}\n", .{line});
        // print("\n{any:}", .{(try std.math.powi(u32, 3, @truncate(numbers.items.len - 1)))});

        for (0..(try std.math.powi(u32, 3, @truncate(numbers.items.len - 1)))) |i| {
            var calculated_result: u64 = @as(u64, numbers.items[0]);
            var i_2 = i;

            // print("{d}", .{numbers.items[0]});
            for (1..numbers.items.len) |j| {
                if (i_2 % 3 == 0) {
                    calculated_result *= numbers.items[j];
                    // print(" * {d} = {d}", .{ numbers.items[j], calculated_result });
                } else if (i_2 % 3 == 1) {
                    calculated_result += numbers.items[j];
                    // print(" + {d} = {d}", .{ numbers.items[j], calculated_result });
                } else {
                    var buf_number_string: [20]u8 = undefined;
                    const number_string = try std.fmt.bufPrint(&buf_number_string, "{}", .{numbers.items[j]});

                    calculated_result = calculated_result * (std.math.pow(u64, 10, number_string.len)) + numbers.items[j];
                    // print(" || {d} = {d}", .{ numbers.items[j], calculated_result });
                }

                if (calculated_result > result) {
                    break;
                }

                i_2 = @divFloor(i_2, 3);
            }
            // print(" = {d}\n", .{calculated_result});
            // print("result = {d}\n", .{result});

            if (calculated_result == result) {
                count += result;
                break;
            }
        }
    }

    file.close();

    print("{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
