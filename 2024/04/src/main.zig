const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;

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

    const size = 140;

    var buf: [size + 1]u8 = undefined;
    var array: [size][size]u8 = undefined;

    var count_of_correct: u32 = 0;

    var line_index: u8 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (line_index += 1) {
        array[line_index] = line[0..140].*;
    }

    file.close();

    for (0..(size)) |i| {
        for (0..size) |j| {
            if (is_2) {
                if (i <= size - 3 and j <= size - 3 and array[i + 1][j + 1] == 'A' and ((array[i][j] == 'M' and array[i][j + 2] == 'M' and array[i + 2][j + 2] == 'S' and array[i + 2][j] == 'S') or (array[i][j] == 'S' and array[i][j + 2] == 'M' and array[i + 2][j + 2] == 'M' and array[i + 2][j] == 'S') or (array[i][j] == 'S' and array[i][j + 2] == 'S' and array[i + 2][j + 2] == 'M' and array[i + 2][j] == 'M') or (array[i][j] == 'M' and array[i][j + 2] == 'S' and array[i + 2][j + 2] == 'S' and array[i + 2][j] == 'M'))) {
                    count_of_correct += 1;
                }
            } else {
                if (j <= size - 4) {
                    if ((array[i][j] == 'X' and array[i][j + 1] == 'M' and array[i][j + 2] == 'A' and array[i][j + 3] == 'S') or (array[i][j] == 'S' and array[i][j + 1] == 'A' and array[i][j + 2] == 'M' and array[i][j + 3] == 'X')) {
                        count_of_correct += 1;
                    }
                    if (i <= size - 4) {
                        if ((array[i][j] == 'X' and array[i + 1][j + 1] == 'M' and array[i + 2][j + 2] == 'A' and array[i + 3][j + 3] == 'S') or (array[i][j] == 'S' and array[i + 1][j + 1] == 'A' and array[i + 2][j + 2] == 'M' and array[i + 3][j + 3] == 'X')) {
                            count_of_correct += 1;
                        }

                        if ((array[i + 3][j] == 'X' and array[i + 2][j + 1] == 'M' and array[i + 1][j + 2] == 'A' and array[i][j + 3] == 'S') or (array[i + 3][j] == 'S' and array[i + 2][j + 1] == 'A' and array[i + 1][j + 2] == 'M' and array[i][j + 3] == 'X')) {
                            count_of_correct += 1;
                        }
                    }
                }
                if (i <= size - 4) {
                    if ((array[i][j] == 'X' and array[i + 1][j] == 'M' and array[i + 2][j] == 'A' and array[i + 3][j] == 'S') or (array[i][j] == 'S' and array[i + 1][j] == 'A' and array[i + 2][j] == 'M' and array[i + 3][j] == 'X')) {
                        count_of_correct += 1;
                    }
                }
            }
        }
    }

    print("{d}\n", .{count_of_correct});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
