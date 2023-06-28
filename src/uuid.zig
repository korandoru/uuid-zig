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
const assert = std.debug.assert;
const crypto = std.crypto;

pub const UUID = struct {
    msb: u64,
    lsb: u64,

    const digits = "0123456789abcdefghijklmnopqrstuvwxyz";
    const nibbles = init: {
        var bytes: [256]u8 = undefined;
        bytes['0'] = 0;
        bytes['1'] = 1;
        bytes['2'] = 2;
        bytes['3'] = 3;
        bytes['4'] = 4;
        bytes['5'] = 5;
        bytes['6'] = 6;
        bytes['7'] = 7;
        bytes['8'] = 8;
        bytes['9'] = 9;
        bytes['A'] = 10;
        bytes['B'] = 11;
        bytes['C'] = 12;
        bytes['D'] = 13;
        bytes['E'] = 14;
        bytes['F'] = 15;
        bytes['a'] = 10;
        bytes['b'] = 11;
        bytes['c'] = 12;
        bytes['d'] = 13;
        bytes['e'] = 14;
        bytes['f'] = 15;
        break :init bytes;
    };

    fn from_bytes(data: []const u8) UUID {
        assert(data.len == 16);
        var lsb: u64 = 0;
        var msb: u64 = 0;
        for (data[0..8]) |b| {
            msb = (msb << 8) | (b & 0xFF);
        }
        for (data[8..16]) |b| {
            lsb = (lsb << 8) | (b & 0xFF);
        }
        return UUID{ .msb = msb, .lsb = lsb };
    }

    fn parse_nibbles(name: []const u8, pos: usize) u64 {
        const ch1 = name[pos];
        const ch2 = name[pos + 1];
        const ch3 = name[pos + 2];
        const ch4 = name[pos + 3];
        if ((ch1 | ch2 | ch3 | ch4) > 0xFF) {
            return @bitCast(@as(i64, -1));
        } else {
            const n1: u64 = @intCast(nibbles[ch1]);
            const n2: u64 = @intCast(nibbles[ch2]);
            const n3: u64 = @intCast(nibbles[ch3]);
            const n4: u64 = @intCast(nibbles[ch4]);
            return n1 << 12 | n2 << 8 | n3 << 4 | n4;
        }
    }

    pub fn parse(name: []const u8) UUID {
        assert(name.len == 36);
        const msb1 = parse_nibbles(name, 0);
        const msb2 = parse_nibbles(name, 4);
        const msb3 = parse_nibbles(name, 9);
        const msb4 = parse_nibbles(name, 14);
        const lsb1 = parse_nibbles(name, 19);
        const lsb2 = parse_nibbles(name, 24);
        const lsb3 = parse_nibbles(name, 28);
        const lsb4 = parse_nibbles(name, 32);
        return new(msb1 << 48 | msb2 << 32 | msb3 << 16 | msb4, lsb1 << 48 | lsb2 << 32 | lsb3 << 16 | lsb4);
    }

    pub fn new(msb: u64, lsb: u64) UUID {
        return UUID{ .msb = msb, .lsb = lsb };
    }

    pub fn v3(name: []const u8) UUID {
        var bytes: [16]u8 = undefined;
        const options: crypto.hash.Md5.Options = undefined;
        crypto.hash.Md5.hash(name, bytes[0..], options);
        bytes[6] &= 0x0F; // clear version
        bytes[6] |= 0x30; // set version to 3
        bytes[8] &= 0x3F; // clear variant
        bytes[8] |= 0x80; // set to IETF variant 2
        return from_bytes(&bytes);
    }

    pub fn v4() UUID {
        var bytes: [16]u8 = undefined;
        crypto.random.bytes(&bytes);
        bytes[6] &= 0x0F; // clear version
        bytes[6] |= 0x40; // set version to 4
        bytes[8] &= 0x3F; // clear variant
        bytes[8] |= 0x80; // set to IETF variant 2
        return from_bytes(&bytes);
    }

    fn format_unsigned_long(value: u64, shift: u4, buf: *[36]u8, offset: u32, len: u32) void {
        var pos: u32 = offset + len;
        var val: u64 = value;
        const radix: u32 = @as(u32, 1) << shift;
        const mask: u32 = radix - 1;

        assert(pos > offset); // do-while
        while (pos > offset) {
            pos -= 1;
            buf[pos] = digits[val & mask];
            val >>= shift;
        }
    }

    pub fn format(self: UUID, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;

        var buf: [36]u8 = undefined;
        buf[8] = '-';
        buf[13] = '-';
        buf[18] = '-';
        buf[23] = '-';
        format_unsigned_long(self.lsb, 4, &buf, 24, 12);
        format_unsigned_long(self.lsb >> 48, 4, &buf, 19, 4);
        format_unsigned_long(self.msb, 4, &buf, 14, 4);
        format_unsigned_long(self.msb >> 16, 4, &buf, 9, 4);
        format_unsigned_long(self.msb >> 32, 4, &buf, 0, 8);

        try std.fmt.format(writer, "{s}", .{buf});
    }

    pub fn get_msb(self: UUID) u64 {
        return self.msb;
    }

    pub fn get_lsb(self: UUID) u64 {
        return self.lsb;
    }

    pub fn version(self: UUID) u64 {
        return (self.msb >> 12) & 0x0F;
    }

    pub fn variant(self: UUID) u64 {
        const ulsb: u64 = self.lsb;
        const ilsb: i64 = @bitCast(self.lsb);
        return (ulsb >> @intCast(64 - (ulsb >> 62))) & @as(u64, @bitCast((ilsb >> 63)));
    }
};
