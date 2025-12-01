const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
var allocator: std.mem.Allocator = undefined;
const input = "input";

const Coordinate = packed struct { x: u8, y: u8 };

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

    var buf: [5]u8 = undefined;

    var count: u64 = 0;
    const cache_init: [5]u8 = [5]u8{ '^', 'v', '>', '<', 'A' };
    var cache = Map(struct { start: u8, end: u8 }, u64).init(allocator);

    for (cache_init) |i| {
        for (cache_init) |j| {
            var result_list = List(u8).init(allocator);
            // try result_list.append(i);
            try result_list.append(j);
            var result = result_list.items;

            for (0..10) |k| {
                const start = if (k == 0) i else 'A';
                result = calculateInstFromInst(result, start);
            }
            print("iteration {c} {c} time {s}\n", .{ i, j, std.fmt.fmtDuration(t.read()) });

            try cache.put(.{ .start = i, .end = j }, result.len);
        }
    }

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // var result = calculateInstfromCode(line);
        const number = try parseInt(u64, line[0..3], 10);
        var result = calculateInstfromCode(line);

        for (0..15) |i| {
            result = calculateInstFromInst(result, 'A');
            print("interation {d} {s} time {s}\n", .{ i, result, std.fmt.fmtDuration(t.read()) });
        }

        // count += result.len * number;

        print("{s}: ", .{line});

        var count2: u64 = 0;
        count2 += cache.get(.{ .start = 'A', .end = result[0] }).?;
        // print("{s}", .{cache.get(.{ .start = 'A', .end = result[0] }).?.result});
        for (0..result.len - 1) |i| {
            const cached = cache.get(.{ .start = result[i], .end = result[i + 1] }).?;
            count2 += cached;
        }
        print(" {d} {d}\n", .{ count2, number });
        count += count2 * number;
    }
    file.close();

    print("count {d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn calculateInstfromCode(line: []u8) []u8 {
    var result = List(u8).init(allocator);
    var current = mapCodeToCoordinate('A');

    for (0..line.len) |i| {
        // print("1: {c}\n", .{line[i]});
        const next = mapCodeToCoordinate(line[i]);
        const inst_robot = calculateMoves(current, next, Coordinate{ .x = 0, .y = 3 });
        current = next;

        // print("--2: {s}\n", .{inst_robot});
        result.appendSlice(inst_robot) catch unreachable;
    }

    // print("{s}: {d} {s}\n", .{ line[0..3], result.items.len, result.items });
    return result.items;
}

fn calculateInstFromInst(line: []u8, start: u8) []u8 {
    var result = List(u8).init(allocator);
    var current = mapInstToCoordinate(start);

    for (0..line.len) |j| {
        const next = mapInstToCoordinate(line[j]);
        const inst_robot = calculateMoves(current, next, Coordinate{ .x = 0, .y = 0 });
        current = next;

        // print("----: {s}\n", .{inst_robot});
        result.appendSlice(inst_robot) catch unreachable;
    }

    return result.items;
}

fn mapCodeToCoordinate(c: u8) Coordinate {
    return switch (c) {
        '0' => Coordinate{ .x = 1, .y = 3 },
        '1' => Coordinate{ .x = 0, .y = 2 },
        '2' => Coordinate{ .x = 1, .y = 2 },
        '3' => Coordinate{ .x = 2, .y = 2 },
        '4' => Coordinate{ .x = 0, .y = 1 },
        '5' => Coordinate{ .x = 1, .y = 1 },
        '6' => Coordinate{ .x = 2, .y = 1 },
        '7' => Coordinate{ .x = 0, .y = 0 },
        '8' => Coordinate{ .x = 1, .y = 0 },
        '9' => Coordinate{ .x = 2, .y = 0 },
        'A' => Coordinate{ .x = 2, .y = 3 },
        else => unreachable,
    };
}

fn mapInstToCoordinate(inst: u8) Coordinate {
    return switch (inst) {
        '^' => Coordinate{ .x = 1, .y = 0 },
        '>' => Coordinate{ .x = 2, .y = 1 },
        'v' => Coordinate{ .x = 1, .y = 1 },
        '<' => Coordinate{ .x = 0, .y = 1 },
        'A' => Coordinate{ .x = 2, .y = 0 },
        else => unreachable,
    };
}

fn calculateMoves(start: Coordinate, next: Coordinate, dead_button: Coordinate) []u8 {
    var list = List(u8).init(allocator);
    const x_moves = switch (start.x -% next.x) {
        254 => ">>",
        255 => ">",
        0 => "",
        1 => "<",
        2 => "<<",
        else => unreachable,
    };

    const y_moves = switch (start.y -% next.y) {
        253 => "vvv",
        254 => "vv",
        255 => "v",
        0 => "",
        1 => "^",
        2 => "^^",
        3 => "^^^",
        else => unreachable,
    };

    if (start.x == dead_button.x and next.y == dead_button.y) {
        list.appendSlice(x_moves) catch unreachable;
        list.appendSlice(y_moves) catch unreachable; //
    } else if (start.y == dead_button.y and next.x == dead_button.x) {
        list.appendSlice(y_moves) catch unreachable; //
        list.appendSlice(x_moves) catch unreachable;
    } else if (std.mem.startsWith(u8, y_moves, "^") and std.mem.startsWith(u8, x_moves, "<")) {
        list.appendSlice(x_moves) catch unreachable; //
        list.appendSlice(y_moves) catch unreachable;
    } else if (std.mem.startsWith(u8, y_moves, "^") and std.mem.startsWith(u8, x_moves, ">")) {
        list.appendSlice(y_moves) catch unreachable;
        list.appendSlice(x_moves) catch unreachable; //
    } else if (std.mem.startsWith(u8, y_moves, "v") and std.mem.startsWith(u8, x_moves, "<")) {
        list.appendSlice(x_moves) catch unreachable;
        list.appendSlice(y_moves) catch unreachable;
    } else if (std.mem.startsWith(u8, y_moves, "v") and std.mem.startsWith(u8, x_moves, ">")) {
        list.appendSlice(y_moves) catch unreachable;
        list.appendSlice(x_moves) catch unreachable;
    } else {
        list.appendSlice(x_moves) catch unreachable; //
        list.appendSlice(y_moves) catch unreachable;
    }

    // std.mem.sort(u8, list.items, {}, std.sort.asc(u8));
    list.appendSlice("A") catch unreachable;
    return list.items;
}
