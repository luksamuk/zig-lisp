pub const LispError = error{
    NotAnAtom,
    UnknownAtom,
    NotAConsCell,
    UnknownConsCell,
    StackOverflow,
    StackUnderflow,
};
