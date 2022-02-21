const std = @import("std");
const pointers = @import("lisp-pointers.zig");
const LispUntypedPtr = pointers.LispUntypedPtr;
const LispTypedPtr = pointers.LispTypedPtr;
const LispError = @import("errors.zig").LispError;

const atoms = @import("atoms").ConstAtoms;

pub const SIZE = 8388608; // 8MB

pub const VMStackArea = struct {
    last: LispUntypedPtr,
    ptr: [SIZE]LispTypedPtr,

    pub fn init(self: *VMStackArea) !void {
        self.last = 0;
        std.mem.set(LispTypedPtr, &self.ptr, 0);
    }

    pub fn push(self: *VMStackArea, ptr: LispTypedPtr) !LispTypedPtr {
        if (self.last >= SIZE)
            return LispError.StackOverflow;
        self.ptr[self.last] = ptr;
        self.last += 1;
        return atoms.T;
    }

    pub fn peek(self: VMStackArea) !LispTypedPtr {
        if (self.last == 0)
            return LispError.StackUnderflow;
        return self.ptr[self.last - 1];
    }

    pub fn pop(self: *VMStackArea) !LispTypedPtr {
        if (self.last == 0)
            return LispError.StackUnderflow;
        self.last -= 1;
        return self.ptr[self.last];
    }

    pub fn unwind(self: *VMStackArea, base: LispTypedPtr) u32 {
        var popped = 0;
        while (self.ptr[self.last] != base) {
            if (self.last == 0)
                break;
            self.last -= 1;
            popped += 1;
        }
        if (self.last > 0)
            self.last -= 1;
        return popped;
    }
};
