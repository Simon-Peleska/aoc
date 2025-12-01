const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
var allocator: std.mem.Allocator = undefined;
// const input = "input2";
// const input = "input3";
// const size = 10;
// const instruction_size = 700;
const input = "input";
const size: u8 = 141;
var start = Coordinate{ .x = 49, .y = 53 };
var end = Coordinate{ .x = 27, .y = 59 };

const Coordinate = packed struct { x: u8, y: u8 };
var array: [size][size]u8 = undefined;
var steps_count: [size][size]u64 = .{.{0} ** size} ** size;
const Direction = enum(u2) {
    north = 0,
    east,
    south,
    west,
};

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

    var buf: [size + 10]u8 = undefined;

    for (0..size) |i| {
        var line = (try in_stream.readUntilDelimiterOrEof(&buf, '\n')).?;
        array[i] = line[0..size].*;
    }

    file.close();

    const count = fill(start, 0);

    for (array) |line| {
        print("{s}\n", .{line});
    }

    // buildGraph(start);

    // var iter = hash_map.iterator();
    // var i: u64 = 1;
    // while (iter.next()) |_| : (i += 1) {
    //     print("{d}", .{i});
    // }

    // removeNodes();

    // // const result = move(start_x, start_y, Direction.east);
    // // const result = move(start.x, start.y, Direction.east, 1);

    // // if (result) |count| {
    // //     print("\n{d}\n", .{count});
    // // } else {
    // //     unreachable;
    // // }

    print("time {d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

// fn removeNodes() void {
//     var iter = hash_map.iterator();
//     while (iter.next()) |kv| {
//         const key = kv.key_ptr.*;
//         var value = kv.value_ptr.*;

//         if (!std.meta.eql(key, start) and !std.meta.eql(key, end)) {
//             var value_iter = value.iterator();

//             while (value_iter.next()) |kv_value| {
//                 var value_iter2 = value.iterator();

//                 while (value_iter2.next()) |kv_value2| {
//                     _ = addConnenction(kv_value.key_ptr.*, kv_value2.key_ptr.*, kv_value.value_ptr.* + kv_value.value_ptr.*);

//                     _ = hash_map.get(kv_value.key_ptr.*).?.swapRemove(key);
//                     _ = hash_map.get(kv_value2.key_ptr.*).?.swapRemove(key);
//                     _ = value.swapRemove(kv_value.key_ptr.*);
//                     _ = value.swapRemove(kv_value2.key_ptr.*);
//                 }
//             }
//         }
//     }
// }

fn fill(c: Coordinate, steps: u64) u64 {
    if (isChar(c, '.')) {
        const sides = getSurrounding(c, 1);

        steps_count[c.y][c.x] = steps;
        setChar(c, '*');

        var shortcuts: u64 = getBigShortcutCount(c);

        for (sides) |side| {
            shortcuts += fill(side, steps + 1);
        }

        return shortcuts;
    } else return 0;
}

fn isChar(c: Coordinate, char: u8) bool {
    return array[c.y][c.x] == char;
}

fn setChar(c: Coordinate, char: u8) void {
    array[c.y][c.x] = char;
}

fn getSurrounding(c: Coordinate, distance: u8) [4]Coordinate {
    return [4]Coordinate{
        .{ .x = c.x, .y = c.y -| distance },
        .{ .x = if (c.x +| distance >= size) size - 1 else c.x +| distance, .y = c.y },
        .{ .x = c.x, .y = if (c.y +| distance >= size) size - 1 else c.y +| distance },
        .{ .x = c.x -| distance, .y = c.y },
    };
}

fn hasWaysOut(c: Coordinate) u8 {
    const surrounding = getSurrounding(c, 1);

    var ways_out: u8 = 0;

    for (surrounding) |side| {
        if (isChar(side, '.')) {
            ways_out += 1;
        }
    }

    return ways_out;
}

fn getBigShortcutCount(c: Coordinate) u64 {
    var shortcuts: u64 = 0;

    for (0..41) |i| {
        const new_i: i64 = @intCast(i);
        const y: i64 = new_i - 20;
        const positive_y = if (y < 0) -y else y;
        for (0..41) |j| {
            const new_j: i64 = @intCast(j);
            const x: i64 = new_j - 20;
            const positive_x: i64 = if (x < 0) -x else x;
            const distance: i64 = positive_y + positive_x;

            if (distance <= 20) {
                const c_y: i64 = @intCast(c.y);
                const c_x: i64 = @intCast(c.x);

                const new_y: u64 = @bitCast(c_y + y);
                const new_x: u64 = @bitCast(c_x + x);

                if (new_y < size and new_x < size and isChar(.{ .x = @truncate(new_x), .y = @truncate(new_y) }, '*') and steps_count[c.y][c.x] - steps_count[new_y][new_x] >= 100 + distance) {
                    shortcuts += 1;
                }
            }
        }
    }

    return shortcuts;
}

// fn buildGraph(c: Coordinate) void {
//     print("a {any}\n", .{c});
//     if ((isChar(c, '.') and hasWaysOut(c) > 2) or isChar(c, 'S') or isChar(c, 'E')) {
//         const sides = getSurrounding(c);

//         for (sides) |side| {
//             var origin = c;
//             origin.d = side.d;

//             for (sides) |other_side| {
//                 print("a {any} {any}\n", .{ side, other_side });
//                 if (isChar(side, '.') and isChar(other_side, '.') and side.d != other_side.d) {
//                     print("a {any} {any}", .{ side, other_side });
//                     var connection_cost: u64 = 0;
//                     if (@intFromEnum(side.d) != @intFromEnum(other_side.d) +% 2) {
//                         connection_cost = 100;
//                     }

//                     _ = addConnenction(side, other_side, connection_cost);
//                 }
//             }

//             searchNext(side, origin, 1);
//         }
//     }
// }

// fn addConnenction(left: Coordinate, right: Coordinate, cost: u64) bool {
//     var had_entry = false;

//     if (hash_map.get(left)) |connections| {
//         if (connections.get(right)) |connection_cost| {
//             if (connection_cost > cost) {
//                 connections.put(right, cost) catch unreachable;
//             }
//             had_entry = false;
//         } else {
//             connections.put(right, cost) catch unreachable;
//         }
//     } else {
//         var connections = Map(Coordinate, u64).init(allocator);

//         connections.put(right, cost) catch unreachable;

//         hash_map.put(left, &connections) catch |err| {
//             print("{any}", .{err});
//         };
//     }

//     if (hash_map.get(right)) |connections| {
//         connections.put(left, cost) catch unreachable;
//     } else {
//         var connections = Map(Coordinate, u64).init(allocator);

//         connections.put(left, cost) catch unreachable;

//         hash_map.put(right, &connections) catch unreachable;
//     }

//     return had_entry;
// }

// fn searchNext(c_current: Coordinate, c_origin: Coordinate, cost: u64) void {
//     setChar(c_current, '*');

//     if (hasWaysOut(c_current) > 1) {
//         print("b {any} {any}", .{ c_current, c_origin });
//         const already_has_connection = addConnenction(c_current, c_origin, cost);

//         if (!already_has_connection) {
//             buildGraph(c_current);
//         }
//     } else {
//         const sides = getSurrounding(c_current);

//         for (sides) |side| {
//             if (isChar(side, '.')) {
//                 var new_cost = cost + 1;

//                 if (c_current.d == side.d) {
//                     new_cost += 100;
//                 }

//                 searchNext(side, c_origin, cost + new_cost);

//                 break;
//             }
//         }
//     }
// }

// fn move(x: u8, y: u8, direction: Direction, count: u64) ?u64 {
//     print("move: {d} {d} {d}\n", .{ x, y, @intFromEnum(direction) });

//     switch (array[y][x]) {
//         'E' => return count,
//         '.', 'S' => {
//             array[y][x] = '*';

//             print("{d}\n", .{@intFromEnum(direction)});
//             for (array) |line| {
//                 print("{s}\n", .{line});
//             }

//             const count_add_north: u64 = @intCast(@intFromBool(direction != Direction.north));
//             const count_add_east: u64 = @intCast(@intFromBool(direction != Direction.east));
//             const count_add_south: u64 = @intCast(@intFromBool(direction != Direction.south));
//             const count_add_west: u64 = @intCast(@intFromBool(direction != Direction.west));

//             const results = [4]struct { Direction, ?u64 }{
//                 .{ Direction.north, move(x, y - 1, Direction.north, count + 1 + (1000 * count_add_north)) },
//                 .{ Direction.east, move(x + 1, y, Direction.east, count + 1 + (1000 * count_add_east)) },
//                 .{ Direction.south, move(x, y + 1, Direction.south, count + 1 + (1000 * count_add_south)) },
//                 .{ Direction.west, move(x - 1, y, Direction.west, count + 1 + (1000 * count_add_west)) },
//             };

//             var lowest_count: ?u64 = null;

//             for (results) |result| {
//                 if (result[1]) |result_count| {
//                     if (lowest_count == null or result_count < lowest_count.?) {
//                         lowest_count = result_count;
//                     }
//                 }
//             }

//             array[y][x] = '.';

//             return lowest_count;
//         },
//         '*' => return null,
//         else => return null,
//     }
// }
