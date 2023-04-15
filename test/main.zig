const std = @import("std");
const testing = std.testing;

const uuid = @import("uuid");

test "uuid initialization" {
    const u = uuid.UUID.new(42, 0);
    try testing.expect(u.get_msb() == 42);
    try testing.expect(u.get_lsb() == 0);
}
