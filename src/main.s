.section .data
  proj_name: .asciz "/teste"
  proj_dir: .space 256
  proj_src: .asciz "/src"
  proj_src_dir: .space 256
  proj_cmake: .asciz "/CMakeLists.txt"
  proj_cmake_dir: .space 256
  proj_cmake_src_dir: .space 256
  proj_main_file: .asciz "/main.cpp"
  proj_main_file_dir: .space 256

.section .bss
cwd: .space 256

.section .text
.globl _start

_start:
.get_cwd:
  movq $79, %rax
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
  movq $83, %rax
  movq $proj_dir, %rdi
  movq $0777, %rsi
  syscall

  movq $83, %rax
  movq $proj_src_dir, %rdi
  movq $0777, %rsi
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

.make_files:
  movq $85, %rax
  movq $proj_cmake_dir, %rdi
  movq $0222, %rsi
  syscall

  movq $85, %rax
  movq $proj_cmake_src_dir, %rdi
  movq $0222, %rsi
  syscall

  movq $85, %rax
  movq $proj_main_file_dir, %rdi
  movq $0222, %rsi
  syscall

.print_strings:
  movq $1, %rax
  movq $1, %rdi
  movq $proj_src_dir, %rsi
  movq $256, %rdx
  syscall

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
