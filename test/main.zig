const std = @import("std");
const testing = std.testing;

const uuid = @import("uuid");

test "basic add functionality" {
    try testing.expect(uuid.add(3, 7) == 10);
}
