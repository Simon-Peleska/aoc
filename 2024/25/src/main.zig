const std = @import("std");

pub fn main() !void {
    var t = try std.time.Timer.start();

    var file = try std.fs.cwd().openFile("input", .{});
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [36]u8 = undefined;
    var array: [250]u35 = undefined;

    var i: u8 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        if (line.len == 0) break;

        array[i] = try std.fmt.parseInt(u35, line, 2);
    }

    var count: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const key = try std.fmt.parseInt(u35, line, 2);

        for (array) |lock| {
            if (key & lock == 0) count += 1;
        }
    }

    file.close();

    std.debug.print("count {d}\n", .{count});
    std.debug.print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
