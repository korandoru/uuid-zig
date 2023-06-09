// Copyright 2023 Korandoru Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const std = @import("std");
const testing = std.testing;

const uuid = @import("uuid");

test "uuid initialization" {
    const u = uuid.UUID.new(42, 0);
    try testing.expect(u.get_msb() == 42);
    try testing.expect(u.get_lsb() == 0);
}

test "uuid given v3" {
    const u = uuid.UUID.v3("korandoru");
    try testing.expectFmt("8038f69c-f438-3396-90c9-32624ec5ee92", "{}", .{u});
    try testing.expectEqual(@as(u64, 3), u.version());
    try testing.expectEqual(@as(u64, 2), u.variant());
}

test "uuid given v4" {
    const u = uuid.UUID.new(17461568127633409033, 11710601912988811980);
    try testing.expectFmt("f253f3b2-5cdf-4409-a284-6a64f9b542cc", "{}", .{u});
    try testing.expectEqual(@as(u64, 4), u.version());
    try testing.expectEqual(@as(u64, 2), u.variant());
}

test "uuid random v4" {
    var i: u8 = 0;
    while (i < 100) : (i += 1) {
        const u = uuid.UUID.v4();
        try testing.expectEqual(@as(u64, 4), u.version());
        try testing.expectEqual(@as(u64, 2), u.variant());
        var buf: [36]u8 = undefined;
        _ = try std.fmt.bufPrint(&buf, "{}", .{u});
        try testing.expectEqual(u, uuid.UUID.parse(&buf));
    }
}
