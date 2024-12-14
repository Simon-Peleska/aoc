const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size: u8 = 42;
// const size = 8;

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

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (line_index += 1) {
        array[line_index] = line[0..size].*;
    }

    file.close();

    var count: u64 = 0;

    for (0..size) |y| {
        for (0..size) |x| {
            if (array[y][x] == '0') {
                var result = std.AutoArrayHashMap(Coordinate, u8).init(allocator);
                try countPaths(&array, @truncate(x), @truncate(y), '0', &result);

                var iterator = result.iterator();
                while (iterator.next()) |_| {
                    count += 1;
                }

                result.clearAndFree();
            }
        }
    }

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn countPaths(array: *[size][size]u8, x: u8, y: u8, character: u8, results: *std.AutoArrayHashMap(Coordinate, u8)) !void {
    if (x >= size or y >= size or array[y][x] != character) {
        return;
    }

    if (character == '9') {
        try results.put(Coordinate{ .x = x, .y = y }, 0);
        return;
    }

    try countPaths(array, x -% 1, y, character + 1, results);
    try countPaths(array, x, y +% 1, character + 1, results);
    try countPaths(array, x +% 1, y, character + 1, results);
    try countPaths(array, x, y -% 1, character + 1, results);

    return;
}
