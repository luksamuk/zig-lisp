const std = @import("std");
const pointers = @import("lisp-pointers.zig");
const LispError = @import("errors.zig").LispError;

const LispDataType = pointers.LispDataType;
const LispUntypedPtr = pointers.LispUntypedPtr;
const LispTypedPtr = pointers.LispTypedPtr;

pub const SIZE = 16777216; // 16MB

pub const ConsCell = struct {
    car: LispTypedPtr,
    cdr: LispTypedPtr,

    pub fn default() ConsCell {
        return ConsCell{
            .car = 0,
            .cdr = 0,
        };
    }
};

pub const VMListArea = struct {
    last: LispUntypedPtr,
    ptr: [SIZE]ConsCell,

    pub fn init(self: *VMListArea) !void {
        self.last = 0;
        std.mem.set(ConsCell, &self.ptr, ConsCell.default());
    }

    pub fn make_cons(self: *VMListArea, car: LispTypedPtr, cdr: LispTypedPtr) LispTypedPtr {
        const current = self.last;
        var cell = &self.ptr[current];
        self.last += 1;

        cell.car = car;
        cell.cdr = cdr;

        return pointers.make_typed(LispDataType.Cons, current);
    }

    fn get_cell(self: *VMListArea, ptr: LispTypedPtr) !*ConsCell {
        if (pointers.get_tag(ptr) != LispDataType.Cons)
            return LispError.NotAConsCell;

        const cellptr = pointers.get_content(ptr);
        if (cellptr >= self.last)
            return LispError.UnknownConsCell;

        return &self.ptr[cellptr];
    }

    pub fn set_car(self: *VMListArea, ptr: LispTypedPtr, value: LispTypedPtr) !LispTypedPtr {
        var cell = try self.get_cell(ptr);
        cell.car = value;
        return value;
    }

    pub fn set_cdr(self: *VMListArea, ptr: LispTypedPtr, value: LispTypedPtr) !LispTypedPtr {
        var cell = try self.get_cell(ptr);
        cell.cdr = value;
        return value;
    }

    pub fn get_car(self: *VMListArea, ptr: LispTypedPtr) !LispTypedPtr {
        const cell = try self.get_cell(ptr);
        return cell.car;
    }

    pub fn get_cdr(self: *VMListArea, ptr: LispTypedPtr) !LispTypedPtr {
        const cell = try self.get_cell(ptr);
        return cell.cdr;
    }

    pub fn print(self: *VMListArea) void {
        var i: LispUntypedPtr = 0;
        while (i < self.last) {
            if (i % 100 == 0) {
                // Print header
                std.debug.print("\n{s:6} | {s:14} | {s:14}\n", .{ "ADDR", "CAR", "CDR" });
                var j: u32 = 0;
                while (j < 40) {
                    std.debug.print("-", .{});
                    j += 1;
                }
                std.debug.print("\n", .{});
            }

            const cell = &self.ptr[i];
            std.debug.print("{X:6} | {X:5} | {X:6} | {X:5} | {X:6}\n", .{
                i,
                @enumToInt(pointers.get_tag(cell.car)),
                pointers.get_content(cell.car),
                @enumToInt(pointers.get_tag(cell.cdr)),
                pointers.get_content(cell.cdr),
            });
            i += 1;
        }
    }
};
