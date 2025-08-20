///|
pub struct CString(Bytes)

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
  CString(bytes)
}

///|
pub fn CString::from_string(string : String) -> CString {
  let size_hint = string.length() * 4 // MoonBit String is UTF-16, so 4 bytes per char max
  let buf = @buffer.new(size_hint~)
  @encoding.encode_to(string, buf, encoding=UTF8)
  let bytes = buf.to_bytes()
  CString(bytes)
}

///|
pub fn CString::to_string(self : CString) -> String raise Failure {
  let CString(inner) = self
  (try? @encoding.decode(inner, encoding=UTF8))
  .map_err(fn(err) { Failure("Failed to decode CString: \{err}") })
  .unwrap_or_error()
}

///|
pub fn CString::strlen(self : CString) -> UInt64 {
  let CString(inner) = self
  _ffi_strlen(inner)
}
