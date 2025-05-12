///|
fn wrapped_main() -> Unit!Failure {
  let server_addr = @sw_socket.new_sockaddr_in!()
    ..set_family(@sw_socket.AddrFamily::AF_INET)
    ..set_addr_str!("0.0.0.0")
    ..set_port(18080)
  let server_socket = @sw_socket.new_socket!(
    @sw_socket.AddrFamily::AF_INET,
    @sw_socket.SocketType::SOCK_STREAM,
    @sw_socket.IpProtocol::IPPROTO_TCP,
  )
  server_socket.bind!(server_addr)
  println(
    "[*] Listening on \{server_addr.get_addr_str!()}:\{server_addr.get_port()}",
  )
  server_socket.listen!(3)
  println("[*] Waiting for connections...")
  while true {
    let client_addr = @sw_socket.new_sockaddr_in!()
    let client_socket = server_socket.accept!(client_addr)
    let client_addr_str = client_addr.get_addr_str!()
    println(
      "[*] Accepted connection from \{client_addr_str}:\{client_addr.get_port()}",
    )
    let resp_msg = "Heyyo, this is a TCP server from MoonBit!\nYou are \{client_addr_str}:\{client_addr.get_port()}, right?\n"
    let resp_msg_bytes = @ctypes.CString::from_string(resp_msg).as_bytes()
    // del null terminator
    let resp_msg_bytes = resp_msg_bytes[:-1].data()
    let _ = client_socket.send!(resp_msg_bytes, 0)
    client_socket.close!()
    println("[*] Connection closed")
  }
  server_socket.close!()
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
