const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const List = std.ArrayList;
const Map = std.AutoArrayHashMap;
const StringMap = std.StringArrayHashMap;
var allocator: std.mem.Allocator = undefined;

const input = "input";

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
    var graph_map = Map([2]u8, List([2]u8)).init(allocator);
    defer graph_map.clearAndFree();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const a: [2]u8 = line[0..2].*;
        const b: [2]u8 = line[3..5].*;

        var list_nullable = graph_map.get(a);
        if (list_nullable) |*list| {
            try list.*.append(b);
            try graph_map.put(a, list.*);
        } else {
            var new_list = List([2]u8).init(allocator);
            try new_list.append(b);

            try graph_map.put(a, new_list);
        }
        if (graph_map.get(a).?.items.len >= 11) {
            print("{s} {s} {s}\n", .{ a, b, graph_map.get(a).?.items });
        }
    }

    file.close();

    var count: u64 = 0;

    for (graph_map.keys()) |c1| {
        var new_c2list = graph_map.get(c1).?;

        var items: u64 = 0;

        print("{s},", .{c1});
        while (new_c2list.items.len > 1) {
            const c2 = new_c2list.items[0];

            if (graph_map.get(c2)) |c3list| {
                print("{s},", .{c2});
                items += 1;
                // print("{s} {s}: ", .{ c1, c2 });
                // for (new_c2list.items) |c2_2| {
                // print("{s} ", .{c2_2});
                // }
                // print("\n", .{});

                var new_list = List([2]u8).init(allocator);

                for (c3list.items) |c3| {
                    // print("{s}\n", .{c3});
                    for (new_c2list.items[1..]) |c2_2| {
                        // print("e: {s}\n", .{c2_2});
                        if (std.mem.eql(u8, &c2_2, &c3)) {
                            // print("f: {s}\n", .{c2_2});
                            try new_list.append(c3);
                            // print("g: {s}\n", .{c2_2});
                            break;
                        }
                        // print("h: {s}\n", .{c2_2});
                    }
                    // print("i: {s}\n", .{c3});
                }

                new_c2list.clearAndFree();
                // print("i: {s}\n", .{new_c2list.items});

                new_c2list = try new_list.clone();
                // print("i: {s}\n", .{new_list.items});
            } else {
                _ = new_c2list.orderedRemove(0);
            }
        }

        for (new_c2list.items) |c2| {
            print("{s},", .{c2});
        }
        print("\n", .{});

        if (items > count) {
            count = items;

            print("aaaa: {s}", .{c1});
            for (graph_map.get(c1).?.items) |c2| {
                print("{s}", .{c2});
            }

            print("\n", .{});
        }

        std.time.sleep(10 * std.time.ns_per_ms);
    }

    print("\n{d}\n", .{count});
    print("time {s}\n", .{std.fmt.fmtDuration(t.read())});
}
