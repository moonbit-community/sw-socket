///|
pub type CString Bytes

///|
pub fn CString::as_bytes(self : CString) -> Bytes {
  let CString(inner) = self
  inner
}

///|
pub fn CString::from_bytes(bytes : Bytes) -> CString raise Failure {
  if bytes.length() == 0 {
    fail("CString cannot be empty")
  }
  if bytes[bytes.length() - 1] != 0 {
    fail("CString must be null terminated")
  }
  CString(bytes)
}

///|
pub fn CString::from_string(string : String) -> CString {
  let size_hint = string.length() * 4 + 1 // MoonBit String is UTF-16, so 4 bytes per char max, and add 1 for null terminator
  let buf = @buffer.new(size_hint~)
  @encoding.encode_to(string, buf, encoding=UTF8)
  buf.write_byte(0) // null terminator
  let bytes = buf.to_bytes()
  CString(bytes)
}

///|
pub fn CString::to_string(self : CString) -> String raise Failure {
  let CString(inner) = self
  @encoding.decode?(
    inner[:-1], // exclude the null terminator
    encoding=UTF8,
  )
  .map_err(fn(err) { Failure("Failed to decode CString: \{err}") })
  .unwrap_or_error()
}

///|
pub fn CString::strlen(self : CString) -> UInt64 {
  let CString(inner) = self
  _ffi_strlen(inner)
}
