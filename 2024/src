const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size: u8 = 140;
// const size = 6;

const ResultField = struct { character: u8 };

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
            if ('A' <= array[y][x] and array[y][x] <= 'Z') {
                const result = floodFill(&array, @truncate(x), @truncate(y), array[y][x]);
                // print("{:0>2}", .{result});
                count += result[0] * result[1];
            } else {
                // print("  ", .{});
            }

            print("{c}", .{array[y][x]});
        }
        print("\n", .{});
    }

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

const Result = struct { u64, u64 };

fn getCorners(array: *[size][size]u8, x: u8, y: u8, character: u8) u64 {
    var count: u64 = 0;

    if ((!isCharacter(array, y -% 1, x -% 1, character) and isCharacter(array, y -% 1, x, character) and isCharacter(array, y, x -% 1, character)) or (!isCharacter(array, y -% 1, x, character) and !isCharacter(array, y, x -% 1, character))) {
        count += 1;
    }

    if ((!isCharacter(array, y -% 1, x +% 1, character) and isCharacter(array, y -% 1, x, character) and isCharacter(array, y, x +% 1, character)) or (!isCharacter(array, y -% 1, x, character) and !isCharacter(array, y, x +% 1, character))) {
        count += 1;
    }

    if ((!isCharacter(array, y +% 1, x -% 1, character) and isCharacter(array, y +% 1, x, character) and isCharacter(array, y, x -% 1, character)) or (!isCharacter(array, y +% 1, x, character) and !isCharacter(array, y, x -% 1, character))) {
        count += 1;
    }

    if ((!isCharacter(array, y +% 1, x +% 1, character) and isCharacter(array, y +% 1, x, character) and isCharacter(array, y, x +% 1, character)) or (!isCharacter(array, y +% 1, x, character) and !isCharacter(array, y, x +% 1, character))) {
        count += 1;
    }

    return count;
}

fn isCharacter(array: *[size][size]u8, x: u8, y: u8, character: u8) bool {
    return !isWall(x, y) and (array[x][y] == character or array[x][y] == (character + 32));
}

fn isWall(x: u8, y: u8) bool {
    return x >= size or y >= size;
}

fn floodFill(array: *[size][size]u8, x: u8, y: u8, character: u8) Result {
    if (isWall(x, y)) {
        return .{ 0, 0 };
    } else if (array[y][x] == character) {
        array[y][x] += 32;

        const count1 = floodFill(array, x -% 1, y, character);
        const count2 = floodFill(array, x, y +% 1, character);
        const count3 = floodFill(array, x +% 1, y, character);
        const count4 = floodFill(array, x, y -% 1, character);

        return .{ getCorners(array, x, y, character) + count1[0] + count2[0] + count3[0] + count4[0], count1[1] + count2[1] + count3[1] + count4[1] + 1 };
    } else if (array[y][x] - 32 == character) {
        return .{ 0, 0 };
    } else {
        return .{ 0, 0 };
    }
}
