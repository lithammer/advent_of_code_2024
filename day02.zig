const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

const LevelsWindowIterator = struct {
    const Self = @This();

    levels: *LevelsIterator,

    pub fn next(self: *Self) ?[2]i8 {
        const a = self.levels.next() orelse return null;
        const b = self.levels.peek() orelse return null;
        return [_]i8{ a, b };
    }
};

const LevelsIterator = struct {
    const Self = @This();

    levels: std.mem.TokenIterator(u8, std.mem.DelimiterType.scalar),

    fn next(self: *Self) ?i8 {
        const value = self.levels.next() orelse return null;
        return std.fmt.parseInt(i8, value, 10) catch null;
    }

    fn peek(self: *Self) ?i8 {
        const value = self.levels.peek() orelse return null;
        return std.fmt.parseInt(i8, value, 10) catch null;
    }

    fn window(self: *Self) LevelsWindowIterator {
        return LevelsWindowIterator{
            .levels = self,
        };
    }
};

fn parseLine(line: []const u8) LevelsIterator {
    const iter = std.mem.tokenizeScalar(u8, line, ' ');
    return LevelsIterator{
        .levels = iter,
    };
}

const Direction = enum {
    positive,
    negative,
};

fn isSafe(line: []const u8) bool {
    var descending = true;
    var ascending = true;

    var iter = parseLine(line);
    var window = iter.window();
    while (window.next()) |w| {
        const a, const b = w;

        switch (a - b) {
            -3...-1, 1...3 => {
                descending = descending and a >= b;
                ascending = ascending and a <= b;
            },
            else => return false,
        }
    }

    return descending or ascending;
}

fn part1(input: []const u8) u64 {
    var safeReports: u64 = 0;

    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (isSafe(line)) {
            safeReports += 1;
        }
    }

    return safeReports;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator;

    const stdout = std.io.getStdOut().writer();

    const input = @embedFile("day02.txt");
    try stdout.print("part1: {d}\n", .{part1(input)});
}

test "parseLine()" {
    var iter = parseLine("7 6 4 2 1");
    try expectEqual(7, iter.next());
    try expectEqual(6, iter.next());
    try expectEqual(4, iter.next());
    try expectEqual(2, iter.next());
    try expectEqual(1, iter.next());
    try expectEqual(null, iter.next());
}

test "LevelsIterator.window()" {
    var iter = LevelsIterator{
        .levels = std.mem.tokenizeScalar(u8, "7 6 4 2 1", ' '),
    };
    var window = iter.window();
    try expectEqual([_]i8{ 7, 6 }, window.next());
    try expectEqual([_]i8{ 6, 4 }, window.next());
    try expectEqual([_]i8{ 4, 2 }, window.next());
    try expectEqual([_]i8{ 2, 1 }, window.next());
    try expectEqual(null, window.next());
}

test "isSafe()" {
    try expect(isSafe("7 6 4 2 1"));
    try expect(!isSafe("1 2 7 8 9"));
    try expect(!isSafe("9 7 6 2 1"));
    try expect(!isSafe("1 3 2 4 5"));
    try expect(!isSafe("8 6 4 4 1"));
    try expect(isSafe("1 3 6 7 9"));
}

test "part1()" {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    try expectEqual(2, part1(input));
}
