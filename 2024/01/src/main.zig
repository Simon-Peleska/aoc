const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    var t = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);

    var is_2 = false;

    for (args) |arg| {
        if (std.mem.eql(u8, arg, "-2")) {
            print("{s}\n", .{arg});
            is_2 = true;
            break;
        }
    }

    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var col1: [1000]u32 = undefined;
    var col2: [1000]u32 = undefined;

    const fileBuffer = try file.readToEndAlloc(allocator, 14000);

    for (0..1000) |i| {
        const offset = i * 14;

        print("{s}\n", .{fileBuffer[(offset)..(offset + 6)]});
        col1[i] = try std.fmt.parseInt(u32, fileBuffer[(offset)..(offset + 6)], 10);
        print("{s}\n", .{fileBuffer[(offset + 9)..(offset + 13)]});
        col2[i] = try std.fmt.parseInt(u32, fileBuffer[(offset + 9)..(offset + 13)], 10);
    }

    std.mem.sort(u32, &col1, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, &col2, {}, comptime std.sort.asc(u32));

    var overall_count: u32 = 0;

    for (col1, col2) |entry1, entry2| {
        var distance = entry1 - entry2;

        if (distance < 0) {
            distance *= -1;
        }

        overall_count += distance;
    }

    print("{d}\n", .{overall_count});
    print("time {}\n", .{std.fmt.fmtDuration(t.read())});
}
