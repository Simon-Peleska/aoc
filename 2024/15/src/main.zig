const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
// const input = "input2";
// const input = "input3";
// const size = 10;
// const instruction_size = 700;
const input = "input";
const size: u8 = 50;
const instruction_size = 20000;
var robot_x: u64 = 0;
var robot_y: u64 = 0;

const Coordinate = struct { x: u8, y: u8 };

pub fn main() !void {
    var t = try std.time.Timer.start();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

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

    var buf: [size * 2 + 1]u8 = undefined;
    var array: [size][size * 2]u8 = undefined;

    for (0..size) |i| {
        var line = (try in_stream.readUntilDelimiterOrEof(&buf, '\n')).?;
        array[i] = line[0 .. size * 2].*;

        if (robot_x == 0) {
            for (array[i], 0..) |field, j| {
                if (field == '@') {
                    robot_x = j;
                    robot_y = i;

                    break;
                }
            }
        }
    }

    _ = try in_stream.readUntilDelimiterOrEof(&buf, '\n');

    var instruction_buf: [instruction_size + 1]u8 = undefined;

    const instructions: [instruction_size]u8 = (try in_stream.readUntilDelimiterOrEof(&instruction_buf, '\n')).?[0..instruction_size].*;

    file.close();

    for (instructions) |direction| {
        print("{c}\n", .{direction});
        for (array) |line| {
            print("{s}\n", .{line});
        }

        _ = move(&array, robot_x, robot_y, direction, '.', false, false);
    }

    var count: u64 = 0;

    for (0..size) |y| {
        for (0..(size * 2)) |x| {
            if ('[' == array[y][x]) {
                // const a: u64 = if (x >= size) 1 else 0;
                count += y * 100 + x; // + a;
            }
        }
    }

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn move(array: *[size][size * 2]u8, x: u64, y: u64, direction: u8, new_character: u8, probe: bool, is_other_half: bool) bool {
    print("x:{d}y:{d}", .{ x, y });
    // for (array) |line| {
    //     print("{s}\n", .{line});
    // }

    var is_moving = false;

    switch (array[y][x]) {
        '#' => {},
        '.' => is_moving = true,
        '[', ']', '@' => {
            switch (direction) {
                '^' => {
                    if (is_other_half) {
                        is_moving = move(array, x, y - 1, direction, array[y][x], probe, false);
                    } else {
                        switch (array[y][x]) {
                            '[' => {
                                const other_side_can_move = move(array, x + 1, y, direction, '.', true, true);

                                if (other_side_can_move and move(array, x, y - 1, direction, array[y][x], true, false)) {
                                    is_moving = true;

                                    if (!probe) {
                                        _ = move(array, x + 1, y, direction, '.', false, true);
                                        _ = move(array, x, y - 1, direction, array[y][x], false, false);
                                    }
                                }
                            },
                            ']' => {
                                const other_side_can_move = move(array, x - 1, y, direction, '.', true, true);

                                if (other_side_can_move and move(array, x, y - 1, direction, array[y][x], true, false)) {
                                    is_moving = true;

                                    if (!probe) {
                                        _ = move(array, x - 1, y, direction, '.', false, true);
                                        _ = move(array, x, y - 1, direction, array[y][x], false, false);
                                    }
                                }
                            },
                            else => is_moving = move(array, x, y - 1, direction, array[y][x], probe, false),
                        }
                    }
                },
                '>' => is_moving = move(array, x + 1, y, direction, array[y][x], false, false),
                'v' => {
                    if (is_other_half) {
                        is_moving = move(array, x, y + 1, direction, array[y][x], probe, false);
                    } else {
                        switch (array[y][x]) {
                            '[' => {
                                const other_side_can_move = move(array, x + 1, y, direction, '.', true, true);

                                if (other_side_can_move and move(array, x, y + 1, direction, array[y][x], true, false)) {
                                    is_moving = true;

                                    if (!probe) {
                                        _ = move(array, x + 1, y, direction, '.', false, true);
                                        _ = move(array, x, y + 1, direction, array[y][x], false, false);
                                    }
                                }
                            },
                            ']' => {
                                const other_side_can_move = move(array, x - 1, y, direction, '.', true, true);

                                if (other_side_can_move and move(array, x, y + 1, direction, array[y][x], true, false)) {
                                    is_moving = true;

                                    if (!probe) {
                                        _ = move(array, x - 1, y, direction, '.', false, true);
                                        _ = move(array, x, y + 1, direction, array[y][x], false, false);
                                    }
                                }
                            },
                            else => is_moving = move(array, x, y + 1, direction, array[y][x], probe, false),
                        }
                    }
                },
                '<' => is_moving = move(array, x - 1, y, direction, array[y][x], false, false),
                else => unreachable,
            }
        },
        else => unreachable,
    }

    // print("{any}\n", .{is_moving});
    // print("{c}\n", .{direction});
    // print("{c}\n", .{new_character});
    if (is_moving and !probe) {
        array[y][x] = new_character;

        if (new_character == '@') {
            robot_x = x;
            robot_y = y;
        }
    }

    return is_moving;
}
