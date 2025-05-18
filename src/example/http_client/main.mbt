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
  let socket = @sw_socket.new_socket!(AF_INET, SOCK_STREAM)
  let sockaddr_in = socket.connect!(hostent, port)
  let connected_addr = sockaddr_in.get_addr_str!()
  let connected_port = sockaddr_in.get_port()
  println("Connected to \{connected_addr}:\{connected_port}")
  let request = build_request_bytes(hostname, path)
  println("\n> \{request}")
  let request_bytes = @ctypes.CString::from_string(request).as_bytes()
  // del null terminator
  let request_bytes = request_bytes[:-1].data()
  ignore(socket.send!(request_bytes))
  println("\n< ")
  while true {
    let resp = socket.recv!(4096)
    if resp.is_empty() {
      break
    }
    let buffer = @buffer.new(size_hint=resp.length() + 1)
    buffer.write_bytes(Bytes::from_fixedarray(resp))
    buffer.write_byte(0) // add null terminator
    println(@ctypes.CString::from_bytes!(buffer.to_bytes()).to_string!())
  }
  println("")
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
