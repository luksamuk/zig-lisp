const std = @import("std");
const pointers = @import("lisp-pointers.zig");
const LispError = @import("errors.zig").LispError;

const LispDataType = pointers.LispDataType;
const LispUntypedPtr = pointers.LispUntypedPtr;
const LispTypedPtr = pointers.LispTypedPtr;

pub const SIZE = 100000;

// Constant atoms
pub const ConstAtoms = enum(LispTypedPtr) {
    Nil = 0x08000000,
    T = 0x08000001,
    Quote = 0x08000002,
    Atom = 0x08000003,
    Eq = 0x08000004,
    Car = 0x08000005,
    Cdr = 0x08000006,
    Cons = 0x08000007,
    Cond = 0x08000008,
    Lambda = 0x08000009,
    Special = 0x0800000A,
    Setq = 0x0800000B,
    Undef = 0x0800000C,
};

pub fn from_const_atom(atom: ConstAtoms) LispTypedPtr {
    return @enumToInt(atom);
}

pub const AtomTableEntry = struct {
    name: []const u8,
    value: LispTypedPtr,

    pub fn default() AtomTableEntry {
        return AtomTableEntry{
            .name = undefined,
            .value = 0,
        };
    }
};

pub const VMAtomTable = struct {
    last: LispUntypedPtr,
    ptr: [SIZE]AtomTableEntry,

    pub fn init(self: *VMAtomTable) !void {
        self.last = 0;
        std.mem.set(AtomTableEntry, &self.ptr, AtomTableEntry.default());

        // Create and bind primitive self-evaluating atoms
        const a_nil = self.make_atom("NIL");
        const a_t = self.make_atom("T");
        _ = try self.bind(a_nil, a_nil);
        _ = try self.bind(a_t, a_t);

        // Create other atoms with undefined value
        var primitive_atoms = [_][]const u8{
            "QUOTE", "ATOM", "EQ", "CAR", "CDR", "CONS", "COND", "LAMBDA", "SPECIAL", "SETQ", "UNDEFINED",
        };

        for (primitive_atoms) |atom| {
            _ = self.make_atom(atom);
        }
    }

    pub fn make_atom(self: *VMAtomTable, name: []const u8) LispTypedPtr {
        const addr = self.last;
        self.last += 1;

        var entry = &self.ptr[addr];
        entry.name = name;
        entry.value = pointers.make_typed(LispDataType.Undefined, 0);
        return pointers.make_typed(LispDataType.Atom, addr);
    }

    pub fn bind(self: *VMAtomTable, atom: LispTypedPtr, value: LispTypedPtr) !LispTypedPtr {
        if (pointers.get_tag(atom) != LispDataType.Atom)
            return LispError.NotAnAtom;

        const tableptr = pointers.get_content(atom);
        if (tableptr >= self.last)
            return LispError.UnknownAtom;

        var entry = &self.ptr[tableptr];
        entry.value = value;
        return value;
    }

    pub fn get(self: *VMAtomTable, atom: LispTypedPtr) !LispTypedPtr {
        if (pointers.get_tag(atom) != LispDataType.Atom)
            return LispError.NotAnAtom;

        const tableptr = pointers.get_content(atom);
        if (tableptr >= self.last)
            return LispError.UnknownAtom;

        return self.ptr[tableptr].value;
    }

    pub fn print(self: *VMAtomTable) void {
        var i: LispUntypedPtr = 0;
        while (i < self.last) {
            if (i % 100 == 0) {
                // Print header
                std.debug.print("\n{s:6} | {s:21} | {s:14}\n", .{ "ADDR", "SYMBOL NAME", "VALUE" });
                var j: u32 = 0;
                while (j < 47) {
                    std.debug.print("-", .{});
                    j += 1;
                }
                std.debug.print("\n", .{});
            }

            const entry = &self.ptr[i];
            std.debug.print("{X:6} | {s:21} | {X:5} | {X:6}\n", .{ i, entry.name, @enumToInt(pointers.get_tag(entry.value)), pointers.get_content(entry.value) });
            i += 1;
        }
    }
};
