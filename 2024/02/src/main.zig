const std = @import("std");

const print = std.debug.print;
const SplitIterator = std.mem.SplitIterator;

pub fn main() !void {
    // Create an allocator.
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);

    var is_2 = false;

    for (args) |arg| {
        if (std.mem.eql(u8, arg, "2")) {
            print("{s}\n", .{arg});
            is_2 = true;
            break;
        }
    }

    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100]u8 = undefined;
    var count_of_correct: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var entriesIterator = std.mem.splitSequence(u8, line, " ");
        var entries = std.ArrayList(i32).init(allocator);

        while (entriesIterator.next()) |entry| {
            try entries.append(try std.fmt.parseInt(i32, entry, 10));
        }

        var is_valid = checkLine(entries);

        if (is_2 and !is_valid) {
            for (0..entries.items.len) |i| {
                var filteredEntries = try entries.clone();
                _ = filteredEntries.orderedRemove(i);

                if (checkLine(filteredEntries)) {
                    is_valid = true;
                    break;
                }
            }
        }

        if (is_valid) {
            count_of_correct += 1;
        }
    }

    print("{d}\n", .{count_of_correct});
}

fn checkLine(entries: std.ArrayList(i32)) bool {
    switch (entries.items.len) {
        0 => return false,
        1 => return true,
        else => {
            const sign: i8 = if (entries.items[0] < entries.items[1]) 1 else -1;

            for (0..entries.items.len) |i| {
                if (i > 0) {
                    const difference = (entries.items[i] - entries.items[i - 1]) * sign;

                    if (difference < 1 or 3 < difference) {
                        return false;
                    }
                }
            }

            return true;
        },
    }
}
