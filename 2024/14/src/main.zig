const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 500;
const width: i64 = 101;
const height: i64 = 103;
// const size = 10;

const Robot = struct { x: i64, y: i64, x_velocity: i64, y_velocity: i64 };

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

    var buf: [16 + 1]u8 = undefined;
    var line_index: u16 = 0;

    const history_length: u64 = 10000;

    var robots: [size]Robot = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (line_index += 1) {
        robots[line_index] = Robot{
            .x = try parseInt(i64, line[0..3], 10),
            .x_velocity = try parseInt(i64, line[8..11], 10),
            .y = try parseInt(i64, line[4..7], 10),
            .y_velocity = try parseInt(i64, line[12..15], 10),
        };
    }

    file.close();

    for (0..history_length) |i| {
        var map: [height][width]u8 = .{.{' '} ** width} ** height;

        for (0..robots.len) |robot_index| {
            var robot = &robots[robot_index];
            robot.x += robot.x_velocity;
            robot.x = @mod(robot.x, width);

            robot.y += robot.y_velocity;
            robot.y = @mod(robot.y, height);

            map[@bitCast(robot.y)][@bitCast(robot.x)] = '*';
        }
        var contains_line_of_robots = false;

        for (map) |line| {
            for (0..line.len - 8) |j| {
                if (std.mem.eql(u8, line[j .. j + 8], "********")) {
                    contains_line_of_robots = true;
                    break;
                }
            }
            if (contains_line_of_robots) {
                break;
            }
        }

        if (contains_line_of_robots) {
            print("\n\n{d}\n\n", .{i + 1});
            for (map) |line| {
                print("\n{s}\n", .{line});
            }
        }
    }

    // print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
