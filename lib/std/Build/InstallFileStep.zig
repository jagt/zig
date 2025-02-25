const std = @import("../std.zig");
const Step = std.Build.Step;
const FileSource = std.Build.FileSource;
const InstallDir = std.Build.InstallDir;
const InstallFileStep = @This();

pub const base_id = .install_file;

step: Step,
builder: *std.Build,
source: FileSource,
dir: InstallDir,
dest_rel_path: []const u8,
/// This is used by the build system when a file being installed comes from one
/// package but is being installed by another.
override_source_builder: ?*std.Build = null,

pub fn init(
    builder: *std.Build,
    source: FileSource,
    dir: InstallDir,
    dest_rel_path: []const u8,
) InstallFileStep {
    builder.pushInstalledFile(dir, dest_rel_path);
    return InstallFileStep{
        .builder = builder,
        .step = Step.init(.install_file, builder.fmt("install {s} to {s}", .{ source.getDisplayName(), dest_rel_path }), builder.allocator, make),
        .source = source.dupe(builder),
        .dir = dir.dupe(builder),
        .dest_rel_path = builder.dupePath(dest_rel_path),
    };
}

fn make(step: *Step) !void {
    const self = @fieldParentPtr(InstallFileStep, "step", step);
    const src_builder = self.override_source_builder orelse self.builder;
    const full_src_path = self.source.getPath(src_builder);
    const full_dest_path = self.builder.getInstallPath(self.dir, self.dest_rel_path);
    try self.builder.updateFile(full_src_path, full_dest_path);
}
