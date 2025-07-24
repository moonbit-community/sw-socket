///| `__socket_ffi_isnullptr` accepts a `void*` pointer
/// but MoonBit don't allow type param in extern function
#borrow(ptr)
pub extern "c" fn is_null_hostent(ptr : FFI_hostent) -> Bool = "__socket_ffi_isnullptr"

///| `__socket_ffi_isnullptr` accepts a `void*` pointer
/// but MoonBit don't allow type param in extern function
#borrow(ptr)
pub extern "c" fn is_null_sockaddr(ptr : FFI_sockaddr_in) -> Bool = "__socket_ffi_isnullptr"

///|
pub impl Nullptr for FFI_hostent with is_null(self : FFI_hostent) -> Bool {
  is_null_hostent(self)
}

///|
pub impl Nullptr for FFI_sockaddr_in with is_null(self : FFI_sockaddr_in) -> Bool {
  is_null_sockaddr(self)
}

///|
#borrow(host)
pub extern "c" fn _ffi_hostent_get_addr(host : FFI_hostent) -> UInt = "__socket_ffi_hostent_get_addr"

///|
#borrow(server)
#deprecated
pub extern "c" fn _ffi_build_sockaddr_in(
  server : FFI_hostent,
  port : Int,
) -> FFI_sockaddr_in = "__socket_ffi_build_sockaddr_in"

///|
pub extern "c" fn _ffi_new_sockaddr_in() -> FFI_sockaddr_in = "__socket_ffi_new_sockaddr_in"

///|
pub extern "c" fn _ffi_get_sockaddr_in_size() -> Int = "__socket_ffi_get_sockaddr_in_size"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_get_family(addr : FFI_sockaddr_in) -> UInt16 = "__socket_ffi_sockaddr_in_get_family"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_set_family(
  addr : FFI_sockaddr_in,
  family : UInt16,
) -> Unit = "__socket_ffi_sockaddr_in_set_family"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_get_addr(addr : FFI_sockaddr_in) -> UInt = "__socket_ffi_sockaddr_in_get_addr"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_set_addr(
  addr : FFI_sockaddr_in,
  addr_value : UInt,
) -> Unit = "__socket_ffi_sockaddr_in_set_addr"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_get_port(addr : FFI_sockaddr_in) -> UInt16 = "__socket_ffi_sockaddr_in_get_port"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_set_port(
  addr : FFI_sockaddr_in,
  port : UInt16,
) -> Unit = "__socket_ffi_sockaddr_in_set_port"

///|
#borrow(hostent)
pub extern "c" fn _ffi_hostent_get_addr_str(hostent : FFI_hostent) -> Bytes = "__socket_ffi_hostent_get_addr_str"

///|
#borrow(addr)
pub extern "c" fn _ffi_sockaddr_in_get_addr_str(
  addr : FFI_sockaddr_in,
) -> @ctypes.CString = "__socket_ffi_sockaddr_in_get_addr_str"

///|
#borrow(addr, addr_str)
pub extern "c" fn _ffi_sockaddr_in_set_addr_str(
  addr : FFI_sockaddr_in,
  addr_str : @ctypes.CString,
) -> UInt = "__socket_ffi_sockaddr_in_set_addr_str"

///|
#borrow(addr)
extern "c" fn __ffi_accept_internal(
  socket_fd : Int,
  addr : FFI_sockaddr_in,
  addr_len : UInt,
) -> Int = "__socket_ffi_accept_wrapper"

///|
pub fn _ffi_accept(socket_fd : Int, addr : FFI_sockaddr_in) -> Int {
  let addr_len = _ffi_get_sockaddr_in_size().reinterpret_as_uint()
  __ffi_accept_internal(socket_fd, addr, addr_len)
}

///|
pub extern "c" fn _ffi_get_errno() -> Int = "__socket_ffi_get_errno"

///|
extern "c" fn _ffi_stderror_internal(err : Int) -> Bytes = "__socket_ffi_stderror"

///|
pub fn _ffi_stderror(err : Int) -> String raise Failure {
  @ctypes.CString::from_bytes(_ffi_stderror_internal(err)).to_string()
}
