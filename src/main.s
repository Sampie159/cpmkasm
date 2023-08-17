.section .data
proj_name: .asciz "/teste"
proj_src: .asciz "/src"
proj_cmake: .asciz "/CMakeLists.txt"
proj_main_file: .asciz "/main.cpp"
cmake_content:
  .ascii "cmake_minimum_required(VERSION 3.10)\n\n"
  .ascii "project(teste)\n\n"
  .ascii "set(CMAKE_CXX_STANDARD 20)\n"
  .ascii "set(CMAKE_CXX_STANDARD_REQUIRED True)\n"
  .ascii "set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic -Werror\")\n\n"
  .ascii "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})\n\n"
  .ascii "add_subdirectory(src)"
cmake_content_len = . - cmake_content
main_content:
  .ascii "#include <iostream>\n\n"
  .ascii "int main() {\n"
  .ascii "  std::cout << \"Hello World!\\n\";\n"
  .ascii "  return 0;\n"
  .ascii "}"
main_content_len = . - main_content
cmake_main_content:
  .ascii "add_executable(\n"
  .ascii "  teste\n"
  .ascii "  main.cpp\n"
  .ascii ")"
cmake_main_content_len = . - cmake_main_content

.equ MODE, 0644
.equ O_CREAT, 0100
.equ O_WRONLY, 0001
.equ O_TRUNC, 01000
.equ WRITE, 1
.equ OPEN, 2
.equ CLOSE, 3
.equ GETCWD, 79
.equ MKDIR, 83
.equ DIR_PERMS, 0755

.section .bss
cwd: .space 256
fd: .int 0
proj_dir: .space 256
proj_src_dir: .space 256
proj_cmake_dir: .space 256
proj_cmake_src_dir: .space 256
proj_main_file_dir: .space 256

.section .text
.globl _start

_start:
.get_cwd:
  movq $GETCWD, %rax
  movq $cwd, %rdi
  movq $256, %rsi
  syscall

.make_proj_path:
  movq $cwd, %rsi
  movq $proj_dir, %rdi
  call copy_string

  movq $proj_name, %rsi
  movq $proj_dir, %rdi
  call append_string

.make_proj_src_path:
  movq $proj_dir, %rsi
  movq $proj_src_dir, %rdi
  call copy_string

  movq $proj_src, %rsi
  movq $proj_src_dir, %rdi
  call append_string

.make_dirs:
  movq $MKDIR, %rax
  movq $proj_dir, %rdi
  movq $DIR_PERMS, %rsi
  syscall

  movq $MKDIR, %rax
  movq $proj_src_dir, %rdi
  movq $DIR_PERMS, %rsi
  syscall

.make_file_paths:
  movq $proj_dir, %rsi
  movq $proj_cmake_dir, %rdi
  call copy_string

  movq $proj_cmake, %rsi
  movq $proj_cmake_dir, %rdi
  call append_string

  movq $proj_src_dir, %rsi
  movq $proj_cmake_src_dir, %rdi
  call copy_string

  movq $proj_cmake, %rsi
  movq $proj_cmake_src_dir, %rdi
  call append_string

  movq $proj_src_dir, %rsi
  movq $proj_main_file_dir, %rdi
  call copy_string

  movq $proj_main_file, %rsi
  movq $proj_main_file_dir, %rdi
  call append_string

.write_files:
  movq $OPEN, %rax
  movq $proj_cmake_dir, %rdi
  movq $O_CREAT | O_WRONLY | O_TRUNC, %rsi
  movq $MODE, %rdx
  syscall
  movq %rax, fd

  movq $WRITE, %rax
  movq fd, %rdi
  movq $cmake_content, %rsi
  movq $cmake_content_len, %rdx
  syscall

  movq $CLOSE, %rax
  movq $fd, %rdi
  syscall

  movq $OPEN, %rax
  movq $proj_main_file_dir, %rdi
  movq $O_CREAT | O_WRONLY | O_TRUNC, %rsi
  movq $MODE, %rdx
  syscall
  movq %rax, fd

  movq $WRITE, %rax
  movq fd, %rdi
  movq $main_content, %rsi
  movq $main_content_len, %rdx
  syscall

  movq $CLOSE, %rax
  movq fd, %rdi
  syscall

  movq $OPEN, %rax
  movq $proj_cmake_src_dir, %rdi
  movq $O_CREAT | O_WRONLY | O_TRUNC, %rsi
  movq $MODE, %rdx
  syscall
  movq %rax, fd

  movq $WRITE, %rax
  movq fd, %rdi
  movq $cmake_main_content, %rsi
  movq $cmake_main_content_len, %rdx
  syscall

  movq $CLOSE, %rax
  movq fd, %rdi
  syscall

.print_strings:

.exit:
  movq $60, %rax
  movq $0, %rdi
  syscall

copy_string:
  xorq %rcx, %rcx
.copy_loop:
  movb (%rsi, %rcx), %al
  movb %al, (%rdi, %rcx)
  incq %rcx
  cmpb $0, %al
  jnz .copy_loop
  ret

append_string:
  xorq %rcx, %rcx
.find_end:
  movb (%rdi, %rcx), %al
  cmpb $0, %al
  jz .append_loop
  incq %rcx
  jmp .find_end
.append_loop:
  movb (%rsi), %al
  movb %al, (%rdi, %rcx)
  incq %rcx
  incq %rsi
  cmpb $0, %al
  jnz .append_loop
  ret
