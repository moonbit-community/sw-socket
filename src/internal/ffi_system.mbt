///|
#external
type FFI_hostent

///|
#external
type FFI_sockaddr_in

///|
#borrow(hostname)
pub extern "c" fn _ffi_gethostbyname(hostname : @ctypes.CString) -> FFI_hostent = "gethostbyname"

///|
pub extern "c" fn _ffi_socket(domain : Int, type_ : Int, protocol : Int) -> Int = "socket"

///|
#borrow(addr)
extern "c" fn _ffi_connect_internal(
  socket_fd : Int,
  addr : FFI_sockaddr_in,
  addr_len : Int
) -> Int = "connect"

///|
pub fn _ffi_connect(socket_fd : Int, addr : FFI_sockaddr_in) -> Int {
  let addr_len = _ffi_get_sockaddr_in_size()
  _ffi_connect_internal(socket_fd, addr, addr_len)
}

///|
#borrow(addr)
extern "c" fn _ffi_bind_internal(
  socket_fd : Int,
  addr : FFI_sockaddr_in,
  addr_len : Int
) -> Int = "bind"

///|
pub fn _ffi_bind(socket_fd : Int, addr : FFI_sockaddr_in) -> Int {
  let addr_len = _ffi_get_sockaddr_in_size()
  _ffi_bind_internal(socket_fd, addr, addr_len)
}

///|
pub extern "c" fn _ffi_listen(socket_fd : Int, backlog : Int) -> Int = "listen"

///|
typealias UInt64 as SIZE_T

///|
typealias Int64 as SSIZE_T

///|
#borrow(buf)
extern "c" fn _ffi_send_byte_array_internal(
  fd : Int,
  buf : FixedArray[Byte],
  n : SIZE_T,
  flags : Int
) -> SSIZE_T = "send"

///|
#borrow(buf)
extern "c" fn _ffi_send_bytes_internal(
  fd : Int,
  buf : Bytes,
  n : SIZE_T,
  flags : Int
) -> SSIZE_T = "send"

///|
pub fn _ffi_send_byte_array(
  fd : Int,
  buf : FixedArray[Byte],
  flags : Int
) -> SSIZE_T {
  _ffi_send_byte_array_internal(fd, buf, buf.length().to_uint64(), flags)
}

///|
pub fn _ffi_send_bytes(fd : Int, buf : Bytes, flags : Int) -> SSIZE_T {
  _ffi_send_bytes_internal(fd, buf, buf.length().to_uint64(), flags)
}

///|
#borrow(buf)
extern "c" fn _ffi_recv_internal(
  fd : Int,
  buf : FixedArray[Byte],
  n : SIZE_T,
  flags : Int
) -> SSIZE_T = "recv"

///|
pub fn _ffi_recv(fd : Int, buf : FixedArray[Byte], flags : Int) -> SSIZE_T {
  _ffi_recv_internal(fd, buf, buf.length().to_uint64(), flags)
}

///|
#borrow(buf, addr)
extern "c" fn _ffi_sendto_bytes_internal(
  fd : Int,
  buf : Bytes,
  n : SIZE_T,
  flags : Int,
  addr : FFI_sockaddr_in,
  addr_len : Int
) -> SSIZE_T = "sendto"

///|
#borrow(buf, addr)
extern "c" fn _ffi_sendto_byte_array_internal(
  fd : Int,
  buf : FixedArray[Byte],
  n : SIZE_T,
  flags : Int,
  addr : FFI_sockaddr_in,
  addr_len : Int
) -> SSIZE_T = "sendto"

///|
pub fn _ffi_sendto_bytes(
  fd : Int,
  buf : Bytes,
  flags : Int,
  addr : FFI_sockaddr_in
) -> SSIZE_T {
  let addr_len = _ffi_get_sockaddr_in_size()
  _ffi_sendto_bytes_internal(
    fd,
    buf,
    buf.length().to_uint64(),
    flags,
    addr,
    addr_len,
  )
}

///|
pub fn _ffi_sendto_byte_array(
  fd : Int,
  buf : FixedArray[Byte],
  flags : Int,
  addr : FFI_sockaddr_in
) -> SSIZE_T {
  let addr_len = _ffi_get_sockaddr_in_size()
  _ffi_sendto_byte_array_internal(
    fd,
    buf,
    buf.length().to_uint64(),
    flags,
    addr,
    addr_len,
  )
}

///|
#borrow(buf, addr)
extern "c" fn _ffi_recvfrom_internal(
  fd : Int,
  buf : FixedArray[Byte],
  n : SIZE_T,
  flags : Int,
  addr : FFI_sockaddr_in,
  addr_len : Int
) -> SSIZE_T = "_ffi_recvfrom_internal_wrapper"

///|
pub fn _ffi_recvfrom(
  fd : Int,
  buf : FixedArray[Byte],
  flags : Int,
  addr : FFI_sockaddr_in
) -> SSIZE_T {
  let addr_len = _ffi_get_sockaddr_in_size()
  _ffi_recvfrom_internal(
    fd,
    buf,
    buf.length().to_uint64(),
    flags,
    addr,
    addr_len,
  )
}

///|
pub extern "c" fn _ffi_close(fd : Int) -> Int = "close"
