///|
fn wrapped_main() -> Unit!Failure {
  let server_addr = @sw_socket.new_sockaddr_in!()
    ..set_family(@sw_socket.AddrFamily::AF_INET)
    ..set_addr_str!("0.0.0.0")
    ..set_port(18080)
  let server_socket = @sw_socket.new_socket!(
    @sw_socket.AddrFamily::AF_INET,
    @sw_socket.SocketType::SOCK_DGRAM,
    @sw_socket.IpProtocol::IPPROTO_UDP,
  )
  server_socket.bind!(server_addr)
  println(
    "[*] Listening on \{server_addr.get_addr_str!()}:\{server_addr.get_port()}",
  )
  while true {
    let buffer : FixedArray[Byte] = FixedArray::make(1024, 0)
    let client_addr = @sw_socket.new_sockaddr_in!()
    let received_data = server_socket.recv_from!(buffer, 0x100, client_addr) // 0x100 = MSG_WAITALL
    let client_addr_str = client_addr.get_addr_str!()
    println(
      "[*] Received data from \{client_addr_str}:\{client_addr.get_port()}",
    )
    let resp_msg_bytes = Bytes::from_fixedarray(buffer)[0:received_data.to_int()].data()
    let _ = server_socket.send_to!(resp_msg_bytes, 0x800, client_addr) // 0x800 = MSG_CONFIRM
    println(
      "[*] Sent data back to \{client_addr_str}:\{client_addr.get_port()}",
    )
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
