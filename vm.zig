const std = @import("std");
const atoms = @import("atoms.zig");
const list_area = @import("list-area.zig");
const register_area = @import("register-area.zig");
const stack = @import("stack.zig");
const pointers = @import("lisp-pointers.zig");

const VMAtomTable = atoms.VMAtomTable;
const VMListArea = list_area.VMListArea;
const VMRegisterArea = register_area.VMRegisterArea;
const VMStackArea = stack.VMStackArea;

// Reexport
pub const ConstAtoms = atoms.ConstAtoms;
pub const from_const_atom = atoms.from_const_atom;

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

    pub fn print(self: *LispVM) void {
        const used_atom_table = self.table.last * @sizeOf(atoms.AtomTableEntry);
        const used_list_area = self.lists.last * @sizeOf(list_area.ConsCell);
        const used_stack = self.stack.last * @sizeOf(pointers.LispTypedPtr);
        const total_size = @sizeOf(VMAtomTable) + @sizeOf(VMListArea) + @sizeOf(VMStackArea);

        std.debug.print("\nVM STATISTICS\n" ++
            "-------------\n" ++
            "ATOM TABLE: {d:10}B / {d:10}B ({d} atoms)\n" ++
            "LIST AREA:  {d:10}B / {d:10}B ({d} cells)\n" ++
            "STACK:      {d:10}B / {d:10}B ({d} elements)\n" ++
            "TOTAL SIZE: {d:10}B / {d:10}B\n\n", .{ used_atom_table, @sizeOf(VMAtomTable), self.table.last, used_list_area, @sizeOf(VMListArea), self.lists.last, used_stack, @sizeOf(VMStackArea), self.stack.last, used_atom_table + used_list_area + used_stack, total_size });
    }
};
