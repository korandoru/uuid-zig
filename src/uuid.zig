const std = @import("std");
const assert = std.debug.assert;

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub const UUID = struct {
    msb: u64,
    lsb: u64,

    const digits = "0123456789abcdefghijklmnopqrstuvwxyz";

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

    pub fn new(msb: u64, lsb: u64) UUID {
        return UUID{ .msb = msb, .lsb = lsb };
    }

    fn format_unsigned_long(value: u64, shift: u4, buf: *[36]u8, offset: u32, len: u32) void {
        var pos: u32 = offset + len;
        var val: u64 = value;
        const radix: u32 = @intCast(u32, 1) << shift;
        const mask: u32 = radix - 1;

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
};
