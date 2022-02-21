const LispPtrMod = @import("lisp-pointers.zig");

const LispDataType = LispPtrMod.LispDataType;
const LispUntypedPtr = LispPtrMod.LispUntypedPtr;
const LispTypedPtr = LispPtrMod.LispTypedPtr;

pub const VMRegisterArea = struct {
    exp: LispTypedPtr,
    env: LispTypedPtr,
    fun: LispTypedPtr,
    argl: LispTypedPtr,
    cont: LispTypedPtr,
    val: LispTypedPtr,
    unev: LispTypedPtr,
};
