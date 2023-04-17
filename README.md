# zig-uuid

This is a project implements UUID standard in Zig programming langauge.

Currently, this project implements:

* UUID v3 - name based
* UUID v4 - pseudo randomly generated

## Usage

### Build

```zig
libOrExe.addPackagePath("uuid", "/path/to/zig-uuid/src/uuid.zig");
```

### Example

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var i: usize = 0;
    while (i < 10) : (i += 1) {
        const u = uuid.UUID.v4();
        std.debug.print("{}\n", .{u});
    }
}
```
