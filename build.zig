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

pub fn build(b: *std.build.Builder) void {
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "uuid",
        .root_source_file = .{ .path = "src/uuid.zig" },
        .target = .{},
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "uuid-gen",
        .root_source_file = .{ .path = "bin/main.zig" },
        .target = .{},
        .optimize = optimize,
    });
    exe.addAnonymousModule("uuid", .{ .source_file = .{ .path = "src/uuid.zig" } });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{ .root_source_file = .{ .path = "test/main.zig" } });
    tests.addAnonymousModule("uuid", .{ .source_file = .{ .path = "src/uuid.zig" } });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&tests.step);
}
