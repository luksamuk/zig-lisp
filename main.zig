const std = @import("std");
const vm = @import("vm.zig");

pub fn main() !void {
    std.debug.print("Lisp interpreter v0.0\n", .{});
    std.debug.print("Written by Lucas S. Vieira\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer _ = gpa.deinit();

    var vms = try allocator.alloc(vm.LispVM, 1);
    defer allocator.free(vms);

    var lispvm = &vms[0];
    std.debug.print("VM Ptr: {*}\n", .{lispvm});

    try lispvm.init();

    // const a_other = lispvm.table.make_atom("OTHER");
    // _ = try lispvm.table.bind(a_nil, a_nil);
    // const ret = try lispvm.table.bind(a_other, a_nil);

    // std.debug.print("Atom: {x}\nValue: {x}\nIs nil? {x}\n", .{ a_other, lispvm.table.get(a_other), @enumToInt(vm.ConstAtoms.Nil) });

    // Cons cells.
    // (T . T)
    _ = lispvm.lists.make_cons(vm.from_const_atom(vm.ConstAtoms.T), vm.from_const_atom(vm.ConstAtoms.T));

    lispvm.table.print();
    lispvm.lists.print();
    std.debug.print("VM Ptr: {*}\n", .{lispvm});
    lispvm.print();
}
