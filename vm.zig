const VMAtomTable = @import("atoms.zig").VMAtomTable;
const VMListArea = @import("list-area.zig").VMListArea;
const VMRegisterArea = @import("register-area.zig").VMRegisterArea;
const VMStackArea = @import("stack.zig").VMStackArea;

// Reexport
pub const ConstAtoms = @import("atoms.zig").ConstAtoms;
pub const from_const_atom = @import("atoms.zig").from_const_atom;

pub const LispVM = struct {
    registers: VMRegisterArea,
    stack: VMStackArea,
    table: VMAtomTable,
    lists: VMListArea,

    pub fn init(self: *LispVM) !void {
        try self.stack.init();
        try self.table.init();
        try self.lists.init();
    }
};
