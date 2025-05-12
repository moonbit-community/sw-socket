///|
fn build_request_bytes(hostname : String, path : String) -> String {
  let request = StringBuilder::new()
  let newline = "\r\n"
  let request = request
    ..write_string("GET \{path} HTTP/1.0")
    ..write_string(newline)
    ..write_string("Host: \{hostname}")
    ..write_string(newline)
    ..write_string("Connection: close")
    ..write_string(newline)
    ..write_string(newline)
    .to_string()
  request
}

///|
fn wrapped_main() -> Unit!Failure {
  let hostname = "echo.free.beeceptor.com"
  let port : UInt16 = 80
  let path = "/never_gonna_give_you_up"
  let hostent = @sw_socket.get_host_by_name!(hostname)
  let socket = @sw_socket.new_socket!(
    @sw_socket.AddrFamily::AF_INET,
    @sw_socket.SocketType::SOCK_STREAM,
    @sw_socket.IpProtocol::IPPROTO_TCP,
  )
  let sockaddr_in = @sw_socket.new_sockaddr_in!()
    ..set_family(@sw_socket.AddrFamily::AF_INET)
    ..set_addr(hostent.get_addr())
    ..set_port(port)
  socket.connect!(sockaddr_in)
  let connected_addr = sockaddr_in.get_addr_str!()
  let connected_port = sockaddr_in.get_port()
  println("Connected to \{connected_addr}:\{connected_port}")
  let request = build_request_bytes(hostname, path)
  println("\n> \{request}")
  let request_bytes = @ctypes.CString::from_string(request).as_bytes()
  // del null terminator
  let request_bytes = request_bytes[:-1].data()
  ignore(socket.send!(request_bytes, 0))
  println("\n< ")
  let response = FixedArray::make(4096, (0).to_byte())
  let mut bytes_received : Int64 = 0
  while true {
    bytes_received = socket.recv!(response, 0)
    if bytes_received <= 0 {
      break
    }
    response[bytes_received.to_int()] = Byte::default() // add null terminator
    println(
      @ctypes.CString::from_bytes!(Bytes::from_fixedarray(response)).to_string!(),
    )
  }
  println("")
  if bytes_received < 0 {
    println("Error: cannot receive data")
  }
  socket.close!()
  println("Connection closed")
}

///|
fn main {
  wrapped_main?()
  .map_err(fn(e) {
    println("Error: \{e}")
    e
  })
  .unwrap()
}
