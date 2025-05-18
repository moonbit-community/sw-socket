#include <arpa/inet.h>
#include <ctype.h>
#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "moonbit.h"

moonbit_bytes_t cstr_to_mbt_bytes(char* str) {
  size_t len = strlen(str);
  moonbit_bytes_t mbt_bytes =
      moonbit_make_bytes(len + 1, 0);  // +1 for null terminator
  memcpy(mbt_bytes, str, len);
  return mbt_bytes;
}

MOONBIT_FFI_EXPORT int __socket_ffi_isnullptr(struct moonbit_object* ptr) {
  return ptr == NULL;
}

void empty_function(void* self) {
  // no-op: empty function
}

MOONBIT_FFI_EXPORT uint32_t
__socket_ffi_hostent_get_addr(struct hostent* host) {
  uint32_t addr_value = 0;
  if (host->h_addrtype != AF_INET) {
    fprintf(stderr, "Error: Unsupported address type\n");
    return 0;
  }
  if (host->h_length > 4 || host->h_length < 0) {
    fprintf(stderr, "Error: Invalid address length\n");
    return 0;
  }
  memcpy(&addr_value, host->h_addr_list[0], host->h_length);
  return addr_value;
}

MOONBIT_FFI_EXPORT struct sockaddr_in* __socket_ffi_new_sockaddr_in() {
  struct sockaddr_in* addr =
      moonbit_make_external_object(empty_function, sizeof(struct sockaddr_in));
  memset(addr, 0, sizeof(struct sockaddr_in));
  return addr;
}

MOONBIT_FFI_EXPORT uint16_t
__socket_ffi_sockaddr_in_get_family(struct sockaddr_in* addr) {
  return addr->sin_family;
}

MOONBIT_FFI_EXPORT void __socket_ffi_sockaddr_in_set_family(
    struct sockaddr_in* addr, uint16_t family) {
  addr->sin_family = family;
}

MOONBIT_FFI_EXPORT uint32_t
__socket_ffi_sockaddr_in_get_addr(struct sockaddr_in* addr) {
  return addr->sin_addr.s_addr;
}

MOONBIT_FFI_EXPORT void __socket_ffi_sockaddr_in_set_addr(
    struct sockaddr_in* addr, uint32_t addr_value) {
  addr->sin_addr.s_addr = addr_value;
}

MOONBIT_FFI_EXPORT uint16_t
__socket_ffi_sockaddr_in_get_port(struct sockaddr_in* addr) {
  return ntohs(addr->sin_port);
}

MOONBIT_FFI_EXPORT void __socket_ffi_sockaddr_in_set_port(
    struct sockaddr_in* addr, uint16_t port) {
  addr->sin_port = htons(port);
}

MOONBIT_FFI_EXPORT int __socket_ffi_get_sockaddr_in_size() {
  return sizeof(struct sockaddr_in);
}

MOONBIT_FFI_EXPORT moonbit_bytes_t
__socket_ffi_sockaddr_in_get_addr_str(struct sockaddr_in* addr) {
  char* retval = inet_ntoa(addr->sin_addr);
  size_t retval_length = strlen(retval);
  uint8_t* moonbit_bytes = moonbit_make_bytes(retval_length + 1, 0);
  memcpy(moonbit_bytes, retval, retval_length + 1);  // +1 for null terminator
  moonbit_incref(moonbit_bytes);
  return moonbit_bytes;
}

MOONBIT_FFI_EXPORT uint32_t __socket_ffi_sockaddr_in_set_addr_str(
    struct sockaddr_in* addr, uint8_t* addr_str) {
  struct in_addr in_addr;
  if (inet_pton(AF_INET, (const char*)addr_str, &in_addr) <= 0) {
    return 1;
  }
  memcpy(&addr->sin_addr, &in_addr, sizeof(struct in_addr));
  return 0;
}

MOONBIT_FFI_EXPORT int __socket_ffi_accept_wrapper(int sockfd,
                                                   struct sockaddr_in* addr,
                                                   uint32_t addrlen) {
  uint32_t* addrlen_ptr = &addrlen;
  int new_sockfd = accept(sockfd, (struct sockaddr*)addr, addrlen_ptr);
  if (new_sockfd < 0) {
    perror("accept");
  }
  return new_sockfd;
}

MOONBIT_FFI_EXPORT ssize_t
_ffi_recvfrom_internal_wrapper(int sockfd, void* buf, size_t len, int flags,
                               struct sockaddr_in* addr, uint32_t addrlen) {
  u_int32_t* addrlen_ptr = &addrlen;
  ssize_t bytes_received =
      recvfrom(sockfd, buf, len, flags, (struct sockaddr*)addr, addrlen_ptr);
  return bytes_received;
}

MOONBIT_FFI_EXPORT int __socket_ffi_get_errno() { return errno; }

MOONBIT_FFI_EXPORT moonbit_bytes_t __socket_ffi_stderror(int err) {
  char* err_str = strerror(err);
  moonbit_bytes_t mbt_bytes = cstr_to_mbt_bytes(err_str);
  moonbit_incref(mbt_bytes);
  return mbt_bytes;
}
