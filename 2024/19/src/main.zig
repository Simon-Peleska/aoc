const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
const StringMap = std.StringArrayHashMap;
var allocator: std.mem.Allocator = undefined;
// const input = "input2";
// const input = "input3";
// const size = 10;
// const instruction_size = 700;
var patterns: [447]List(u8) = undefined;

const input = "input";

var array: [100000000]bool = .{false} ** 100000000;
var cache: StringMap(u64) = undefined;

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

    var buf: [61]u8 = undefined;

    var i: u64 = 0;

    cache = StringMap(u64).init(allocator);
    defer _ = cache.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        if (line.len == 0) break;
        var list = List(u8).init(allocator);
        try list.appendSlice(line);
        patterns[i] = list;
        const number = try parseInt(usize, line, 10);

        array[number] = true;
    }

    var count: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        print("{s}\n", .{line});

        // var has_valid_end = false;
        // for (patterns) |pattern| {
        //     if (std.mem.endsWith(u8, line, pattern.items)) {
        //         has_valid_end = true;
        //         break;
        //     }
        // }

        // if (has_valid_end and try patternsFound(line[0..line.len], 0)) {
        count += try patternsFound(line[0..line.len], 0);
        print("count: {d}\n\n", .{count});
        print("\n\n", .{});
    }

    file.close();

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}

fn patternsFound(line: []u8, index: usize) !u64 {
    if (index >= line.len) return 1;
    if (cache.get(line[index..])) |cached_result| return cached_result;

    const slice_size = if (line.len - index > 8) 8 else line.len - index;

    var count: u64 = 0;

    for (1..slice_size + 1) |i| {
        const slice_number = try parseInt(usize, line[index .. index + i], 10);

        if (array[slice_number] == true) {
            count += try patternsFound(line, index + i);
        }
    }

    try cache.putNoClobber(line[index..], count);

    return count;
}
