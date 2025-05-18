///|
pub(all) enum AddrFamily {
  // Only IPv4 is supported for now
  AF_INET
  // AF_INET6 = 10
}

///|
fn AddrFamily::from_u16(value : UInt16) -> AddrFamily!Failure {
  match value {
    2 => AddrFamily::AF_INET
    // 10 => AddrFamily::AF_INET6
    _ => fail!("Unsupported address family: \{value}")
  }
}

///|
fn AddrFamily::to_u16(self : AddrFamily) -> UInt16 {
  match self {
    AddrFamily::AF_INET => 2
    // AddrFamily::AF_INET6 => 10
  }
}

///|
pub(all) enum SocketType {
  SOCK_STREAM
  SOCK_DGRAM
  // other types are not supported
}

///|
fn SocketType::from_u16(value : UInt16) -> SocketType!Failure {
  match value {
    1 => SocketType::SOCK_STREAM
    2 => SocketType::SOCK_DGRAM
    _ => fail!("Unsupported socket type: \{value}")
  }
}

///|
fn SocketType::to_u16(self : SocketType) -> UInt16 {
  match self {
    SocketType::SOCK_STREAM => 1
    SocketType::SOCK_DGRAM => 2
  }
}

///|
pub(all) enum IpProtocol {
  IPPROTO_IP
  IPPROTO_TCP
  IPPROTO_UDP
  // other protocols are not supported
}

///|
fn IpProtocol::from_u16(value : UInt16) -> IpProtocol!Failure {
  match value {
    0 => IpProtocol::IPPROTO_IP
    6 => IpProtocol::IPPROTO_TCP
    17 => IpProtocol::IPPROTO_UDP
    _ => fail!("Unsupported IP protocol: \{value}")
  }
}

///|
fn IpProtocol::to_u16(self : IpProtocol) -> UInt16 {
  match self {
    IpProtocol::IPPROTO_IP => 0
    IpProtocol::IPPROTO_TCP => 6
    IpProtocol::IPPROTO_UDP => 17
  }
}

// TODO: Protocol families

///|
struct Hostent {
  inner : @internal.FFI_hostent
}

///|
pub fn get_host_by_name(hostname : String) -> Hostent!Failure {
  let cstr = @ctypes.CString::from_string(hostname)
  let hostent = @internal.gethostbyname(cstr)
  if hostent.is_null() {
    fail!("gethostbyname failed, hostent is null")
  }
  Hostent::{ inner: hostent }
}

///|
pub fn Hostent::get_addr(self : Hostent) -> UInt {
  @internal._ffi_hostent_get_addr(self.inner)
}

///|
struct Socket {
  inner : Int
}

///|
pub fn new_socket(
  domain : AddrFamily,
  type_ : SocketType,
  protocol : IpProtocol
) -> Socket!Failure {
  let fd = @internal.socket(
    domain.to_u16().to_int(),
    type_.to_u16().to_int(),
    protocol.to_u16().to_int(),
  )
  if fd < 0 {
    fail!("socket failed: \{fd}")
  }
  Socket::{ inner: fd }
}

///|
pub fn Socket::close(self : Socket) -> Unit!Failure {
  let result = @internal._ffi_close(self.inner)
  if result < 0 {
    fail!("close failed: \{result}")
  }
}

///|
pub fn Socket::connect(self : Socket, addr : SockaddrIn) -> Unit!Failure {
  let result = @internal._ffi_connect(self.inner, addr.inner)
  if result < 0 {
    self.close!()
    fail!("connect failed: \{result}")
  }
}

///|
pub fn Socket::bind(self : Socket, addr : SockaddrIn) -> Unit!Failure {
  let result = @internal._ffi_bind(self.inner, addr.inner)
  if result < 0 {
    self.close!()
    fail!("bind failed: \{result}")
  }
}

///|
pub fn Socket::listen(self : Socket, backlog : Int) -> Unit!Failure {
  let result = @internal._ffi_listen(self.inner, backlog)
  if result < 0 {
    self.close!()
    fail!("listen failed: \{result}")
  }
}

///|
pub fn Socket::accept(self : Socket, addr : SockaddrIn) -> Socket!Failure {
  let fd = @internal._ffi_accept(self.inner, addr.inner)
  if fd < 0 {
    self.close!()
    fail!("accept failed: \{fd}")
  }
  Socket::{ inner: fd }
}

///|
trait Sendable {
  send(Self, socket : Socket, flags : Int) -> Int64!Failure
}

///|
pub impl Sendable for FixedArray[Byte] with send(
  self : FixedArray[Byte],
  socket : Socket,
  flags : Int
) -> Int64!Failure {
  @internal._ffi_send_byte_array(socket.inner, self, flags)
}

///|
pub impl Sendable for Bytes with send(
  self : Bytes,
  socket : Socket,
  flags : Int
) -> Int64!Failure {
  @internal._ffi_send_bytes(socket.inner, self, flags)
}

///|
pub fn Socket::send[Sendable : Sendable](
  self : Socket,
  sendable : Sendable,
  flags : Int
) -> Int64!Failure {
  let result = sendable.send!(self, flags)
  if result < 0 {
    self.close!()
    fail!("send failed: \{result}")
  }
  result
}

///|
pub fn Socket::recv(
  self : Socket,
  buf : FixedArray[Byte],
  flags : Int
) -> Int64!Failure {
  let result = @internal._ffi_recv(self.inner, buf, flags)
  if result < 0 {
    self.close!()
    fail!("recv failed: \{result}")
  }
  result
}

///|
struct SockaddrIn {
  inner : @internal.FFI_sockaddr_in
}

///|
pub fn new_sockaddr_in() -> SockaddrIn!Failure {
  let sockaddr = @internal._ffi_new_sockaddr_in()
  if sockaddr.is_null() {
    fail!("build_sockaddr_in failed, sockaddr is null")
  }
  SockaddrIn::{ inner: sockaddr }
}

///|
pub fn SockaddrIn::get_family(self : SockaddrIn) -> AddrFamily!Failure {
  AddrFamily::from_u16!(@internal._ffi_sockaddr_in_get_family(self.inner))
}

///|
pub fn SockaddrIn::set_family(self : SockaddrIn, family : AddrFamily) -> Unit {
  @internal._ffi_sockaddr_in_set_family(self.inner, family.to_u16())
}

///|
pub fn SockaddrIn::get_addr(self : SockaddrIn) -> UInt {
  @internal._ffi_sockaddr_in_get_addr(self.inner)
}

///|
pub fn SockaddrIn::set_addr(self : SockaddrIn, addr : UInt) -> Unit {
  @internal._ffi_sockaddr_in_set_addr(self.inner, addr)
}

///|
pub fn SockaddrIn::get_port(self : SockaddrIn) -> UInt16 {
  @internal._ffi_sockaddr_in_get_port(self.inner)
}

///|
pub fn SockaddrIn::set_port(self : SockaddrIn, port : UInt16) -> Unit {
  @internal._ffi_sockaddr_in_set_port(self.inner, port)
}

///|
pub fn SockaddrIn::get_addr_str(self : SockaddrIn) -> String!Failure {
  let addr = @internal._ffi_sockaddr_in_get_addr_str(self.inner)
  addr.to_string!()
}

///|
pub fn SockaddrIn::set_addr_str(
  self : SockaddrIn,
  addr : String
) -> Unit!Failure {
  let cstr = @ctypes.CString::from_string(addr)
  let retval = @internal._ffi_sockaddr_in_set_addr_str(self.inner, cstr)
  if retval != 0 {
    fail!("set_addr_str failed: \{retval}")
  }
}
