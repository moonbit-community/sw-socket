///|
typealias UInt64 as SIZE_T

///|
#borrow(cstr)
extern "c" fn _ffi_strlen(cstr : Bytes) -> SIZE_T = "strlen"
