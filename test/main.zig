const std = @import("std");
const testing = std.testing;

const uuid = @import("uuid");

test "uuid initialization" {
    const u = uuid.UUID.new(42, 0);
    try testing.expect(u.get_msb() == 42);
    try testing.expect(u.get_lsb() == 0);
}

test "uuid format and version" {
    const u = uuid.UUID.new(17461568127633409033, 11710601912988811980);
    try testing.expectFmt("f253f3b2-5cdf-4409-a284-6a64f9b542cc", "{s}", .{u});
    try testing.expectEqual(@intCast(u64, 4), u.version());
}
