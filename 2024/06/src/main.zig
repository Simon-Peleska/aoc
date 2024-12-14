const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 130;
// const size = 10;

const Coordinate = struct { x: u8, y: u8 };

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
    var array: [size][size]u8 = undefined;
    var line_index: u8 = 0;
    var initial_position: ?Coordinate = null;
    var direction: u8 = '^';

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (line_index += 1) {
        const line_array = line[0..size].*;
        if (initial_position == null) {
            for (0..size) |j| {
                if (line_array[j] == '^') {
                    initial_position = Coordinate{ .x = @truncate(j), .y = line_index };
                }
            }
        }

        array[line_index] = line_array;
    }

    file.close();

    var position = initial_position.?;

    var count: u32 = 0;

    if (!is_2) {
        count += 1;
    }

    while (true) {
        const old_position = position;
        position = getNextPosition(position, direction);

        if (position.x >= size or position.y >= size) {
            break;
        }

        var test_array: [size][size]u8 = undefined;
        switch (array[position.y][position.x]) {
            '#' => {
                direction = turn(direction);
                position = old_position;
            },
            '.', '^', '>', 'v', '<' => {
                if (array[position.y][position.x] == '.') {
                    if (!is_2) {
                        count += 1;
                    } else if (is_2) {
                        @memcpy(&test_array, &array);
                        test_array[position.y][position.x] = 'O';

                        var old_test_position: Coordinate = undefined;
                        var test_position = old_position;
                        var test_direction = direction;

                        while (true) {
                            old_test_position = test_position;
                            test_position = getNextPosition(test_position, test_direction);

                            if (test_position.x >= size or test_position.y >= size) {
                                break;
                            }

                            switch (test_array[test_position.y][test_position.x]) {
                                '.', '^', '>', 'v', '<' => {
                                    if (test_array[test_position.y][test_position.x] == test_direction) {
                                        count += 1;
                                        break;
                                    }
                                    test_array[test_position.y][test_position.x] = test_direction;
                                },
                                '#', 'O' => {
                                    test_direction = turn(test_direction);
                                    test_position = old_test_position;
                                },
                                else => {},
                            }
                        }
                    }
                }

                array[position.y][position.x] = direction;
            },
            else => unreachable,
        }
    }

    print("{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn turn(direction: u8) u8 {
    return switch (direction) {
        '^' => '>',
        '>' => 'v',
        'v' => '<',
        '<' => '^',
        else => unreachable,
    };
}

fn getNextPosition(position: Coordinate, direction: u8) Coordinate {
    return switch (direction) {
        '^' => Coordinate{ .x = position.x, .y = position.y -% 1 },
        '>' => Coordinate{ .x = position.x +% 1, .y = position.y },
        'v' => Coordinate{ .x = position.x, .y = position.y +% 1 },
        '<' => Coordinate{ .x = position.x -% 1, .y = position.y },
        else => unreachable,
    };
}
