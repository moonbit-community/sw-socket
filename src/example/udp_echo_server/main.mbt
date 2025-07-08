///|
fn wrapped_main() -> Unit raise Failure {
  let server_socket = @sw_socket.new_socket(AF_INET, SOCK_DGRAM)
  let server_addr = server_socket.bind("0.0.0.0", 18080)
  println(
    "[*] Listening on \{server_addr.get_addr_str!()}:\{server_addr.get_port()}",
  )
  while true {
    let (resp_msg_bytes, client_addr) = server_socket.recv_from(1024)
    let client_addr_str = client_addr.get_addr_str()
    let client_addr_port = client_addr.get_port()
    println("[*] Received data from \{client_addr_str}:\{client_addr_port}")
    let _ = server_socket.send_to(resp_msg_bytes, client_addr)
    println("[*] Sent data back to \{client_addr_str}:\{client_addr_port}")
  }
  server_socket.close()
}

///|
fn main {
  (try? wrapped_main())
  .map_err(fn(e) {
    println("Error: \{e}")
    e
  })
  .unwrap()
}
