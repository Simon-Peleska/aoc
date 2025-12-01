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
const size: u8 = 71;
var start = Coordinate{ .x = 0, .y = 0, .d = Direction.east };
var end = Coordinate{ .x = size - 1, .y = size - 1, .d = Direction.west };

const Coordinate = packed struct { x: u8, y: u8, d: Direction };
const Connection = struct { coordinate: Coordinate, cost: u64 };
var hash_map: Map(Coordinate, *Map(Coordinate, u64)) = undefined;
var array: [size][size]u8 = .{.{' '} ** size} ** size;
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

    var buf: [6]u8 = undefined;

    var i: u64 = 1;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        const x = try parseInt(u8, line[0..2], 10);
        const y = try parseInt(u8, line[3..5], 10);

        array[y][x] = '#';
        if (i > 2500) {
            const result: ?u64 = try aStar();
            print("\n{d}\n", .{i});
            if (result == null) {
                print("result {d} {d} {d}\n", .{ i, x, y });
                break;
            }
        }
    }

    for (0..size) |y| {
        print("{s}\n", .{array[y]});
    }

    file.close();

    // for (1..(size - 1)) |i| {
    //     for (1..(size - 1)) |j| {
    //         fill(.{ .x = @truncate(j), .y = @truncate(i), .d = Direction.east });
    //     }
    // }

    // for (array) |line| {
    //     print("{s}\n", .{line});
    // }

    // // buildGraph(start);

    // var iter = hash_map.iterator();
    // var i: u64 = 1;
    // while (iter.next()) |_| : (i += 1) {
    //     print("{d}", .{i});
    // }

    // removeNodes();

    // // const result = move(start_x, start_y, Direction.east);
    // // const result = move(start.x, start.y, Direction.east, 1);

    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn isChar(c: Coordinate, char: u8) bool {
    return array[c.y][c.x] == char;
}

fn setChar(c: Coordinate, char: u8) void {
    array[c.y][c.x] = char;
}

fn getSurrounding(c: Coordinate) [4]Coordinate {
    return [4]Coordinate{
        .{ .x = c.x, .y = c.y -% 1, .d = Direction.north },
        .{ .x = c.x + 1, .y = c.y, .d = Direction.east },
        .{ .x = c.x, .y = c.y + 1, .d = Direction.south },
        .{ .x = c.x -% 1, .y = c.y, .d = Direction.west },
    };
}

fn getWaysOut(c: Coordinate) []Coordinate {
    const surrounding = getSurrounding(c);

    var sides: List(Coordinate) = List(Coordinate).init(allocator);

    for (surrounding) |side| {
        if (side.x < size and side.y < size and !isChar(side, '#')) {
            sides.append(side) catch unreachable;
        }
    }

    return sides.items;
}

fn reconstructPath(cameFrom: Map(Coordinate, Coordinate), current: Coordinate) void { // []Coordinate {
    // var totalPath = List(Coordinate).init(allocator);
    // defer totalPath.deinit();

    // try totalPath.append(current);

    var cursor = current;

    while (cameFrom.get(cursor)) |cursor2| {
        cursor = cursor2;
        array[cursor.y][cursor.x] = '*';
        // try totalPath.prepend(cursor);
    }

    // return totalPath.toOwnedSlice();
}

var fScore: Map(Coordinate, u64) = undefined;
var gScore: Map(Coordinate, u64) = undefined;

fn order(_: void, r: Coordinate, l: Coordinate) std.math.Order {
    // const r_y: u64 = @intCast(r.y);
    // const r_x: u64 = @intCast(r.x);

    // const l_y: u64 = @intCast(l.y);
    // const l_x: u64 = @intCast(l.x);
    return std.math.order(fScore.get(r).?, fScore.get(l).?);
    // return std.math.order(fScore.get(r).?, fScore.get(l).?);
}

fn aStar() !?u64 {
    var cameFrom = Map(Coordinate, Coordinate).init(allocator);
    defer cameFrom.deinit();

    gScore = Map(Coordinate, u64).init(allocator);
    defer gScore.deinit();
    const start_value: u64 = 0;
    try gScore.put(start, start_value);

    fScore = Map(Coordinate, u64).init(allocator);
    defer fScore.deinit();
    try fScore.put(start, h(start));

    var openSet = std.PriorityQueue(Coordinate, void, order).init(allocator, {});
    defer openSet.deinit();
    try openSet.add(start);

    while (openSet.removeOrNull()) |current| {
        if (current.y == size - 1 and current.x == size - 1) {
            // reconstructPath(cameFrom, current);
            return gScore.get(current);
        }
        const gScoreCurrent = gScore.get(current).?;

        for (getWaysOut(current)) |neighbour| {
            // print("current: {any}\n", .{getWaysOut(current)});

            const tentativeGScore = gScoreCurrent + 1;

            if (gScore.get(neighbour)) |score| {
                if (tentativeGScore < score) {
                    // print("5\n", .{});
                    try gScore.put(neighbour, tentativeGScore);
                    try fScore.put(neighbour, tentativeGScore + h(neighbour));
                    try cameFrom.put(neighbour, current);

                    openSet.update(neighbour, neighbour) catch {
                        try openSet.add(neighbour);
                    };
                }
            } else {
                try gScore.put(neighbour, tentativeGScore);
                try fScore.put(neighbour, tentativeGScore + h(neighbour));
                try cameFrom.put(neighbour, current);

                try openSet.add(neighbour);
            }
        }
    }

    return null; // Failure: open set is empty but goal was never reached
}

// fn d(c: Coordinate, neighbour: Coordinate) u64 {
//     return if (c.d != neighbour.d) 1001 else 1;
// }

fn h(c: Coordinate) u64 {
    const y: u64 = @intCast(c.y);
    const x: u64 = @intCast(c.x);
    return size - 1 - y + size - 1 - x;
}
