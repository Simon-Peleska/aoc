const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 20000;
// const size = 10;
const ArrayList = std.ArrayList;

const Coordinate = packed struct { length: u4, id: u8 };

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

    var buf: [20000]u8 = undefined;

    var count: u64 = 0;

    if (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var array = line[0 .. size - 1].*;

        var line_index_front: u64 = 0;
        var line_index_back: u64 = size - 2;
        var front_index_id: u64 = 0;
        array[line_index_front] -= '0';

        if (is_2) {
            for (1..(size - 1)) |i| {
                array[i] -= '0';
            }

            while (line_index_front < size - 1) {
                if (line_index_front % 2 == 0) {
                    var deleted = false;
                    if (array[line_index_front] >= 100) {
                        deleted = true;

                        array[line_index_front] -= 100;
                    }

                    for (0..(array[line_index_front])) |_| {
                        if (!deleted) {
                            count += front_index_id * @divFloor(line_index_front, 2);
                        }
                        front_index_id += 1;
                    }

                    array[line_index_front] = 0;

                    line_index_front += 1;
                } else {
                    line_index_back = 0;
                    var found = false;

                    for (1..@divFloor(size - 2, 2)) |i| {
                        if (line_index_front >= size - (i * 2)) {
                            break;
                        }

                        line_index_back = size - (i * 2);

                        if (array[line_index_front] >= array[line_index_back] and array[line_index_back] > 0) {
                            found = true;
                            break;
                        }
                    }
                    if (found) {
                        for (0..array[line_index_back]) |_| {
                            count += front_index_id * @divFloor(line_index_back, 2);
                            front_index_id += 1;
                        }

                        array[line_index_front] -= array[line_index_back];
                        array[line_index_back] += 100;

                        if (array[line_index_front] == 0) {
                            line_index_front += 1;
                        }
                    } else {
                        front_index_id += array[line_index_front];
                        line_index_front += 1;
                    }
                }
            }
        } else {
            array[line_index_back] -= '0';

            while (line_index_front <= line_index_back) {
                if (line_index_front % 2 == 0) {
                    for (0..(array[line_index_front])) |_| {
                        count += front_index_id * @divFloor(line_index_front, 2);
                        front_index_id += 1;
                    }

                    array[line_index_front] = 0;
                } else {
                    if (array[line_index_front] >= (array[line_index_back])) {
                        array[line_index_front] -= array[line_index_back];

                        for (0..(array[line_index_back])) |_| {
                            count += front_index_id * @divFloor(line_index_back, 2);

                            front_index_id += 1;
                        }

                        array[line_index_back] = 0;
                    } else {
                        array[line_index_back] -= array[line_index_front];

                        for (0..(array[line_index_front])) |_| {
                            count += front_index_id * @divFloor(line_index_back, 2);
                            front_index_id += 1;
                        }

                        array[line_index_front] = 0;
                    }
                }

                if (array[line_index_back] == 0) {
                    line_index_back -= 2;

                    if (array[line_index_back] >= '0') {
                        array[line_index_back] -= '0';
                    }
                }
            }

            if (array[line_index_front] == 0) {
                line_index_front += 1;
                if (array[line_index_front] >= '0') {
                    array[line_index_front] -= '0';
                }
            }
        }
    }

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
