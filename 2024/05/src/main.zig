const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const size = 100;

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

    var buf_rules: [6]u8 = undefined;
    var array: [size][size]bool = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf_rules, '\n')) |line| {
        if (line.len != 5) {
            break;
        }

        array[try parseInt(u8, line[0..2], 10)][try parseInt(u8, line[3..5], 10)] = true;
    }

    var count_of_correct: u32 = 0;
    var buf_input: [100]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf_input, '\n')) |line| {
        var line_iter = std.mem.split(u8, line, ",");
        var list = std.ArrayList(u8).init(allocator);

        var is_valid = true;

        while (line_iter.next()) |entry_string| {
            const entry = try parseInt(u8, entry_string, 10);

            for (list.items) |list_entry| {
                if (!isCorrect(array, list_entry, entry)) {
                    is_valid = false;
                    if (!is_2) {
                        break;
                    }
                }
            }

            if (!is_valid and !is_2) {
                break;
            }

            try list.append(entry);
        }

        if (is_valid != is_2) {
            if (is_2) {
                std.mem.sort(u8, list.items, array, isCorrect);
            }

            count_of_correct += list.items[(list.items.len - 1) / 2];
        }
    }

    file.close();

    print("{d}\n", .{count_of_correct});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn isCorrect(array: [size][size]bool, a: u8, b: u8) bool {
    return array[a][b];
}
