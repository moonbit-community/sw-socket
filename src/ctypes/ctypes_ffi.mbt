///|
typealias SIZE_T = UInt64

///|
#borrow(cstr)
extern "c" fn _ffi_strlen(cstr : Bytes) -> SIZE_T = "strlen"
