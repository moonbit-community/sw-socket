///|
fn wrapped_main() -> Unit raise Failure {
  let server_socket = @sw_socket.new_socket(AF_INET, SOCK_STREAM)
  let server_addr = server_socket.bind("0.0.0.0", 18080)
  println(
    "[*] Listening on \{server_addr.get_addr_str!()}:\{server_addr.get_port()}",
  )
  server_socket.listen(3)
  println("[*] Waiting for connections...")
  while true {
    let (client_socket, client_addr) = server_socket.accept()
    let client_addr_str = client_addr.get_addr_str()
    let client_addr_port = client_addr.get_port()
    println(
      "[*] Accepted connection from \{client_addr_str}:\{client_addr_port}",
    )
    let resp_msg = "Heyyo, this is a TCP server from MoonBit!\nYou are \{client_addr_str}:\{client_addr_port}, right?\n"
    let resp_msg_bytes = @ctypes.CString::from_string(resp_msg).as_bytes()
    // del null terminator
    let resp_msg_bytes = resp_msg_bytes[:-1].data()
    let _ = client_socket.send(resp_msg_bytes)
    client_socket.close()
    println("[*] Connection closed")
  }
  println("[*] Shutting down server...")
  server_socket.close()
}

///|
fn main {
  (try?(wrapped_main()))
  .map_err(fn(e) {
    println("Error: \{e}")
    e
  })
  .unwrap()
}
