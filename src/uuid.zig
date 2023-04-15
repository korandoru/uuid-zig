const std = @import("std");
const assert = std.debug.assert;

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub const UUID = struct {
    msb: u64,
    lsb: u64,

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

    pub fn get_msb(self: UUID) u64 {
        return self.msb;
    }

    pub fn get_lsb(self: UUID) u64 {
        return self.lsb;
    }
};
