const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const expectEqual = std.testing.expectEqual;

fn similarity(a: i32, b: i32) i64 {
    return a * b;
}

fn distance(a: i32, b: i32) u64 {
    return @abs(a - b);
}

fn parseLine(line: []const u8) !struct { left: i32, right: i32 } {
    var columns = std.mem.tokenizeScalar(u8, line, ' ');
    const left = try std.fmt.parseInt(i32, columns.next().?, 10);
    const right = try std.fmt.parseInt(i32, columns.next().?, 10);
    return .{ .left = left, .right = right };
}

fn part2(allocator: Allocator, input: []const u8) !i64 {
    var left = ArrayList(i32).init(allocator);
    defer left.deinit();
    var right = AutoHashMap(i32, i32).init(allocator);
    defer right.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const columns = try parseLine(line);

        try left.append(columns.left);

        const entry = try right.getOrPutValue(columns.right, 0);
        entry.value_ptr.* += 1;
    }

    var sum: i64 = 0;
    for (left.items) |l| {
        const occurences = right.get(l) orelse {
            continue;
        };
        sum += similarity(l, occurences);
    }

    return sum;
}

fn part1(allocator: Allocator, input: []const u8) !u64 {
    var left = ArrayList(i32).init(allocator);
    defer left.deinit();
    var right = ArrayList(i32).init(allocator);
    defer right.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const columns = try parseLine(line);
        try left.append(columns.left);
        try right.append(columns.right);
    }

    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var sum: u64 = 0;
    for (left.items, right.items) |l, r| {
        sum += distance(l, r);
    }

    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdout = std.io.getStdOut().writer();

    const input = @embedFile("day01.txt");
    try stdout.print("part1: {d}\n", .{try part1(allocator, input)});
    try stdout.print("part2: {d}\n", .{try part2(allocator, input)});
}

test "distance(3, 7) == 4" {
    try expectEqual(4, distance(3, 7));
}

test "distance(9, 3) == 6" {
    try expectEqual(6, distance(9, 3));
}

test "similarity(3, 7) == 21" {
    try expectEqual(21, similarity(3, 7));
}

test "parseLine()" {
    const line = try parseLine("47078   87818");
    try expectEqual(47078, line.left);
    try expectEqual(87818, line.right);
}

test "part1()" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    const res = try part1(std.testing.allocator, input);
    try expectEqual(11, res);
}

test "part2()" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    const res = try part2(std.testing.allocator, input);
    try expectEqual(31, res);
}
