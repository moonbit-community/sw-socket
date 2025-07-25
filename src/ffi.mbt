///|
pub(all) enum AddrFamily {
  // Only IPv4 is supported for now
  AF_INET
  // AF_INET6 = 10
}

///|
fn AddrFamily::from_u16(value : UInt16) -> AddrFamily raise Failure {
  match value {
    2 => AddrFamily::AF_INET
    // 10 => AddrFamily::AF_INET6
    _ => fail("Unsupported address family: \{value}")
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
/// TODO: comment this code to ignore warning checking
// fn SocketType::from_u16(value : UInt16) -> SocketType raise Failure {
//   match value {
//     1 => SocketType::SOCK_STREAM
//     2 => SocketType::SOCK_DGRAM
//     _ => fail("Unsupported socket type: \{value}")
//   }
// }

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
// TODO: comment this code to ignore warning checking
// fn IpProtocol::from_u16(value : UInt16) -> IpProtocol raise Failure {
//   match value {
//     0 => IpProtocol::IPPROTO_IP
//     6 => IpProtocol::IPPROTO_TCP
//     17 => IpProtocol::IPPROTO_UDP
//     _ => fail("Unsupported IP protocol: \{value}")
//   }
// }

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
pub fn Hostent::get_addr_str(self : Hostent) -> String raise Failure {
  let addr = @internal._ffi_hostent_get_addr_str(self.inner)
  @ctypes.CString::from_bytes(addr).to_string()
}

///|
pub fn get_host_by_name(hostname : String) -> Hostent raise Failure {
  let cstr = @ctypes.CString::from_string(hostname)
  let hostent = @internal._ffi_gethostbyname(cstr)
  if hostent.is_null() {
    fail("gethostbyname failed, hostent is null")
  }
  Hostent::{ inner: hostent }
}

///|
pub fn Hostent::get_addr(self : Hostent) -> UInt {
  @internal._ffi_hostent_get_addr(self.inner)
}

///|
struct Socket {
  domain : AddrFamily
  inner : Int
}

///|
pub fn new_socket(
  domain : AddrFamily,
  type_ : SocketType,
  protocol~ : IpProtocol? = None
) -> Socket raise Failure {
  let protocol = match (protocol, type_) {
    (Some(p), _) => p
    (None, SocketType::SOCK_STREAM) => IpProtocol::IPPROTO_TCP
    (None, SocketType::SOCK_DGRAM) => IpProtocol::IPPROTO_UDP
  }
  let fd = @internal._ffi_socket(
    domain.to_u16().to_int(),
    type_.to_u16().to_int(),
    protocol.to_u16().to_int(),
  )
  if fd < 0 {
    if fd == -1 {
      let err = @internal._ffi_get_errno()
      let err_str = @internal._ffi_stderror(err)
      fail("socket failed: \{err_str}")
    }
    fail("socket failed: \{fd}")
  }
  Socket::{ domain, inner: fd }
}

///|
pub fn Socket::close(self : Socket) -> Unit raise Failure {
  let result = @internal._ffi_close(self.inner)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "close failed: \{err}"
    } else {
      "close failed: \{result}"
    }
    fail(err_str)
  }
}

///|
pub fn Socket::connect_addr(
  self : Socket,
  addr : SockaddrIn
) -> Unit raise Failure {
  let result = @internal._ffi_connect(self.inner, addr.inner)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "connect failed: \{err}"
    } else {
      "connect failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
}

///|
pub fn Socket::connect(
  self : Socket,
  addr : Hostent,
  port : UInt16
) -> SockaddrIn raise Failure {
  let sockaddr_in = new_sockaddr_in()
  sockaddr_in
  ..set_family(self.domain)
  ..set_addr(addr.get_addr())
  ..set_port(port)
  self.connect_addr(sockaddr_in)
  sockaddr_in
}

///|
pub fn Socket::bind_addr(
  self : Socket,
  addr : SockaddrIn
) -> Unit raise Failure {
  let result = @internal._ffi_bind(self.inner, addr.inner)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "bind failed: \{err}"
    } else {
      "bind failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
}

///|
pub fn Socket::bind(
  self : Socket,
  addr : String,
  port : UInt16
) -> SockaddrIn raise Failure {
  let sockaddr_in = new_sockaddr_in()
  sockaddr_in..set_family(self.domain)..set_addr_str(addr)..set_port(port)
  self.bind_addr(sockaddr_in)
  sockaddr_in
}

///|
pub fn Socket::listen(self : Socket, backlog : Int) -> Unit raise Failure {
  let result = @internal._ffi_listen(self.inner, backlog)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "listen failed: \{err}"
    } else {
      "listen failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
}

///|
pub fn Socket::accept(self : Socket) -> (Socket, SockaddrIn) raise Failure {
  let addr = new_sockaddr_in()
  let fd = @internal._ffi_accept(self.inner, addr.inner)
  if fd < 0 {
    let err_str = if fd == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "accept failed: \{err}"
    } else {
      "accept failed: \{fd}"
    }
    self.close()
    fail(err_str)
  }
  (Socket::{ domain: self.domain, inner: fd }, addr)
}

///|
trait Sendable {
  send(Self, socket : Socket, flags : Int) -> Int64 raise Failure
}

///|
pub impl Sendable for FixedArray[Byte] with send(
  self : FixedArray[Byte],
  socket : Socket,
  flags : Int
) -> Int64 raise Failure {
  @internal._ffi_send_byte_array(socket.inner, self, flags)
}

///|
pub impl Sendable for Bytes with send(
  self : Bytes,
  socket : Socket,
  flags : Int
) -> Int64 raise Failure {
  @internal._ffi_send_bytes(socket.inner, self, flags)
}

///|
pub fn[Sendable : Sendable] Socket::send(
  self : Socket,
  sendable : Sendable,
  flags~ : Int = 0
) -> Int64 raise Failure {
  let result = sendable.send(self, flags)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "send failed: \{err}"
    } else {
      "send failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
  result
}

///|
trait SendToAble {
  send_to(Self, socket : Socket, flags : Int, addr : SockaddrIn) -> Int64 raise Failure
}

///|
pub impl SendToAble for FixedArray[Byte] with send_to(
  self : FixedArray[Byte],
  socket : Socket,
  flags : Int,
  addr : SockaddrIn
) -> Int64 raise Failure {
  @internal._ffi_sendto_byte_array(socket.inner, self, flags, addr.inner)
}

///|
pub impl SendToAble for Bytes with send_to(
  self : Bytes,
  socket : Socket,
  flags : Int,
  addr : SockaddrIn
) -> Int64 raise Failure {
  @internal._ffi_sendto_bytes(socket.inner, self, flags, addr.inner)
}

///|
pub fn[S : SendToAble] Socket::send_to(
  self : Socket,
  sendable : S,
  addr : SockaddrIn,
  flags~ : Int = 0x800 // MSG_CONFIRM
) -> Int64 raise Failure {
  let result = sendable.send_to(self, flags, addr)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "sendto failed: \{err}"
    } else {
      "sendto failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
  result
}

///|
pub fn Socket::recv_buffer(
  self : Socket,
  buf : FixedArray[Byte],
  flags~ : Int = 0
) -> Int64 raise Failure {
  let result = @internal._ffi_recv(self.inner, buf, flags)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "recv failed: \{err}"
    } else {
      "recv failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
  result
}

///|
pub fn Socket::recv(
  self : Socket,
  buf_size : Int
) -> FixedArray[Byte] raise Failure {
  guard buf_size > 0 else { fail("recv: buf_size must be greater than 0") }
  let mut buf : FixedArray[Byte] = FixedArray::make(buf_size, (0).to_byte())
  let len = self.recv_buffer(buf)
  if len.to_int() != buf_size {
    buf = FixedArray::makei(len.to_int(), fn(i) { buf[i] })
  }
  buf
}

///|
pub fn Socket::recv_from_buffer(
  self : Socket,
  buf : FixedArray[Byte],
  flags~ : Int = 0x100 // MSG_WAITALL
) -> (Int64, SockaddrIn) raise Failure {
  let addr = new_sockaddr_in()
  let result = @internal._ffi_recvfrom(self.inner, buf, flags, addr.inner)
  if result < 0 {
    let err_str = if result == -1 {
      let err = @internal._ffi_get_errno()
      let err = @internal._ffi_stderror(err)
      "recvfrom failed: \{err}"
    } else {
      "recvfrom failed: \{result}"
    }
    self.close()
    fail(err_str)
  }
  (result, addr)
}

///|
pub fn Socket::recv_from(
  self : Socket,
  buf_size : Int
) -> (FixedArray[Byte], SockaddrIn) raise Failure {
  guard buf_size > 0 else { fail("recv_from: buf_size must be greater than 0") }
  let mut buf : FixedArray[Byte] = FixedArray::make(buf_size, 0)
  let (len, addr) = self.recv_from_buffer(buf)
  if len.to_int() != buf_size {
    buf = FixedArray::makei(len.to_int(), fn(i) { buf[i] })
  }
  (buf, addr)
}

///|
struct SockaddrIn {
  inner : @internal.FFI_sockaddr_in
}

///|
pub fn new_sockaddr_in() -> SockaddrIn raise Failure {
  let sockaddr = @internal._ffi_new_sockaddr_in()
  if sockaddr.is_null() {
    fail("build_sockaddr_in failed, sockaddr is null")
  }
  SockaddrIn::{ inner: sockaddr }
}

///|
pub fn SockaddrIn::get_family(self : SockaddrIn) -> AddrFamily raise Failure {
  AddrFamily::from_u16(@internal._ffi_sockaddr_in_get_family(self.inner))
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
pub fn SockaddrIn::get_addr_str(self : SockaddrIn) -> String raise Failure {
  let addr = @internal._ffi_sockaddr_in_get_addr_str(self.inner)
  addr.to_string()
}

///|
pub fn SockaddrIn::set_addr_str(
  self : SockaddrIn,
  addr : String
) -> Unit raise Failure {
  let cstr = @ctypes.CString::from_string(addr)
  let retval = @internal._ffi_sockaddr_in_set_addr_str(self.inner, cstr)
  if retval != 0 {
    fail("set_addr_str failed: \{retval}")
  }
}
