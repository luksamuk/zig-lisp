const std = @import("std");
const assert = std.debug.assert;

pub const LispDataType = enum(u8) {
    Undefined = 0x00,
    Cons = 0x01,
    Atom = 0x08,
    Number = 0x09,
    BuiltInFunction = 0x0a,
    BuiltInSpecial = 0x0b,
    Function = 0x0c,
    Special = 0x0d,
};

pub const LispUntypedPtr = u32;
pub const LispTypedPtr = u32;
pub const LispPtrTag = u8;

const CLEAR_MASK = 0xff000000;

pub fn make_typed(tag: LispDataType, uptr: LispUntypedPtr) LispTypedPtr {
    const padded_tag = @as(LispTypedPtr, @enumToInt(tag)) << 24;
    const clean_uptr = uptr ^ (uptr & CLEAR_MASK);
    // TODO: Compensate number signum
    return padded_tag | clean_uptr;
}

pub fn get_tag(ptr: LispTypedPtr) LispDataType {
    const tag = @truncate(u8, ptr >> 24);
    return @intToEnum(LispDataType, tag ^ (tag & 0xf0));
}

pub fn get_content(ptr: LispTypedPtr) LispUntypedPtr {
    return ptr ^ (ptr & CLEAR_MASK);
}

test "typed pointers" {
    const atom = make_typed(LispDataType.Atom, 10);
    assert(atom == 0x0800000a);

    const cons = 0x01000010;
    assert(get_tag(cons) == LispDataType.Cons);
    assert(get_content(cons) == 16);
}
